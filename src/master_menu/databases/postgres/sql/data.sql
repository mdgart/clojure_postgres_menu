-- :name find-root-by-account-id
-- :command :query
-- :result 1
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

-- :name get-branch-by-node-label
-- :command :query
-- :result n
-- :doc given the node_label, find the branch, if root node is provided get the whole tree
SELECT label::json, attributes::json, money::json, path::text, parent_id
FROM section_item
WHERE path <@ CAST(:node_label AS ltree)

-- :name insert-root :<!
-- :doc Insert a new root menu
INSERT INTO section_item (label)
VALUES (:label) returning id

-- :name insert-section-item :! :n
-- :doc Insert a new branch/leaf
INSERT INTO section_item
VALUES (
  parent_id = :parent_id,
  label = :label
)

-- :name update-section-item :! :n
-- :doc Update branch/leaf
UPDATE section_item
SET (
  parent_id = :parent_id,
  label = :label
) WHERE id = :id

-- :name delete-section-item-branch :! :n
-- :doc Delete branch/leaf
DELETE FROM section_item
WHERE id = :id

-- :name insert-location-item :! :n
-- :doc Insert a new specific location data in a leaf (or branch)
INSERT INTO location_section_item
VALUES (
  section_item_id = :section_item_id,
  mf_location_id = :mf_location_id,
  hide = :hide,
  money = :money
)

-- :name update-location-item :! :n
-- :doc Update specific location data in a leaf (or branch)
UPDATE location_section_item
SET (
  section_item_id = :section_item_id,
  mf_location_id = :mf_location_id,
  hide = :hide,
  money = :money
)
WHERE id = :id

-- :name delete-location-item-branch :! :n
-- :doc Delete specific location data in a leaf (or branch)
DELETE FROM location_section_item
WHERE id = :id
