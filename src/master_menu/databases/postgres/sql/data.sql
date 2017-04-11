-- :name find-roots-by-account-id
-- :command :query
-- :result n
-- :doc Find the root section_item with using mf account_id.
SELECT *
FROM account_section_item
WHERE mf_account_id = :id

-- :name get-branch-by-node
-- :command :query
-- :result n
-- :doc given the node_labels, find the branch, if root node is provided get the whole tree
SELECT section_item.id, labels::json, attributes::json, section_item.price::json, path::text, parent_id
FROM section_item
WHERE
  path <@ CAST(:node_labels AS ltree)
  --~ (when (contains? params :level) "AND nlevel(path) = :level")
ORDER BY path

-- :name get-branch-by-node-with-location-data
-- :command :query
-- :result n
-- :doc given the node_labels, find the branch, if root node is provided get the whole tree
SELECT section_item.id, labels::json, attributes::json, section_item.price::json, path::text, parent_id,
       location_data.hide, location_data.price::json AS location_price, location_data.status, location_data.timestamp
FROM section_item
LEFT JOIN (
  SELECT * FROM location_section_item WHERE mf_location_id = :mf_location_id) location_data ON section_item.id = location_data.section_item_id
WHERE
  path <@ CAST(:node_labels AS ltree)
  --~ (when (contains? params :level) "AND nlevel(path) = :level")

-- :name location-section-item-by-node
-- :command :query
-- :result n
-- :doc Find all locations specific data for a node. (not in use)
SELECT *
FROM location_section_item
WHERE section_item_id = :id

-- :name section-item-by-location
-- :command :query
-- :result 1
-- :doc Find location specific data. (not in use)
SELECT *
FROM location_section_item
WHERE mf_location_id = :mf_location_id

-- :name insert-root :<!
-- :doc Insert a new root menu
INSERT INTO section_item (labels, attributes)
VALUES (:labels, :attributes) returning id

-- :name insert-root-relations :<!
-- :doc After inserting a new root menu, insert the relation with it and mf_account_id plus the provider
INSERT INTO account_section_item (section_item_id, mf_account_id, provider)
VALUES (:section_item_id, :mf_account_id, :provider) returning id

-- :name insert-section-item :<!
-- :doc Insert a new branch/leaf
INSERT INTO section_item (
  parent_id,
  labels
  --~ (when (contains? params :attributes) ", attributes ")
  --~ (when (contains? params :price) ", price ")
)
VALUES (
  :parent_id,
  :labels
  --~ (when (contains? params :attributes) ", :attributes ")
  --~ (when (contains? params :price) ", :price ")
) returning id

-- :name update-section-item :<!
-- :doc Update branch/leaf
UPDATE section_item
SET
  labels = :labels
  --~ (when (contains? params :attributes) ", attributes = :attributes ")
  --~ (when (contains? params :price) ", price = :price ")
WHERE id = :id
returning id

-- :name delete-section-item-branch :! :n
-- :doc Delete branch/leaf
DELETE FROM section_item
WHERE id = CAST(:id AS int8)

-- :name upsert-location-section-item :<!
-- :doc Insert a new specific location data in a leaf (or branch)
INSERT INTO location_section_item (section_item_id, mf_location_id, hide, price, timestamp)
VALUES (
  :section_item_id,
  :mf_location_id,
  :hide,
  :price,
  now()
) ON CONFLICT (section_item_id, mf_location_id)
DO UPDATE SET
  hide = :hide,
  price = :price,
  timestamp = now()
returning id

-- :name delete-location-section-item :! :n
-- :doc Delete specific location data in a leaf (or branch)
DELETE FROM location_section_item
WHERE id = :id
