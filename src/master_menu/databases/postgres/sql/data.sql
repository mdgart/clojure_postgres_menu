-- :name find-roots-by-account-id
-- :command :query
-- :result n
-- :doc Find the root section_item with using mf account_id.
SELECT *
FROM account_section_item
WHERE mf_account_id = :id

-- :name find-schema-by-provider
-- :command :query
-- :result 1
-- :doc Find the schema definition for a specific provider.
SELECT *
FROM provider_schema
WHERE provider = :provider

-- :name get-branch-by-node
-- :command :query
-- :result n
-- :doc given the node_labels, find the branch, if root node is provided get the whole tree
SELECT id, labels::json, attributes::json, price::json, path::text, parent_id
FROM section_item
WHERE
  path <@ CAST(:node_labels AS ltree)
  --~ (when (contains? params :level) "AND nlevel(path) = :level")
ORDER BY path

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
  --~ (when (contains? params :price) ", :price ")
WHERE id = :id
returning id

-- :name delete-section-item-branch :! :n
-- :doc Delete branch/leaf
DELETE FROM section_item
WHERE id = CAST(:id AS int8)

-- :name upsert-location-section-item :! :n
-- :doc Insert a new specific location data in a leaf (or branch)
INSERT INTO location_section_item
VALUES (
  section_item_id = :section_item_id,
  mf_location_id = :mf_location_id,
  hide = :hide,
  price = :price
) ON CONFLICT (section_item_id, mf_location_id)
UPDATE location_section_item
SET
  hide = :hide,
  price = :price


-- :name delete-location-item-branch :! :n
-- :doc Delete specific location data in a leaf (or branch)
DELETE FROM location_section_item
WHERE id = :id
