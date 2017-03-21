(ns master-menu.databases.postgres.sql
  (:require [hugsql.core :as hugsql]
            [hugsql.adapter.clojure-jdbc :as cj-adapter]))

(hugsql/def-db-fns "master_menu/databases/postgres/sql/data.sql"
 {:adapter (cj-adapter/hugsql-adapter-clojure-jdbc)})
(hugsql/def-sqlvec-fns "master_menu/databases/postgres/sql/data.sql"
 {:adapter (cj-adapter/hugsql-adapter-clojure-jdbc)})
