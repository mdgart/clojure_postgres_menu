(ns master-menu.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]
            [master-menu.databases.postgres.db :refer [db]]
            [master-menu.databases.postgres.sql :as sql]))


;; Defines common interceptors for json
(def json-common-interceptors [(body-params/body-params) http/json-body])

;; Define other specific interceptors
;;
;; Empty

;; insert section_item entries, both root or normal
(defn create-root [json-params]
  (let [provider (:provider json-params)
        mf_account_id (:mf_account_id json-params)]
    (ring-resp/response
      (let [result (sql/insert-root db json-params)]
        (do
         (sql/insert-root-relations db
            { :section_item_id (:id (first result))
              :mf_account_id mf_account_id
              :provider provider})
         result)))))

(defn create-section-item [json-params]
 (ring-resp/response
   (sql/insert-section-item db json-params)))

(defn create-entry
  [{:keys [json-params] :as request}]
  (cond
    (clojure.string/blank? (str (:parent_id json-params))) (create-root json-params)
    :else (create-section-item json-params)))

;; update section_item entries
(defn update-entry
  [{:keys [json-params] :as request}]
  (ring-resp/response
    (sql/update-section-item db json-params)))

;; delete section_item entries
(defn delete-entry
  [{:keys [path-params] :as request}]
  (ring-resp/response
    (do
     (sql/delete-section-item-branch db path-params)
     path-params)))

(defn delete-location-section-item
 [{:keys [path-params] :as request}]
 (ring-resp/response
   (do
    (sql/delete-location-section-item db path-params)
    path-params)))

;; Retrieve node
(defn get-entry
 [{:keys [path-params] :as request}]
 (ring-resp/response {:result
                         (sql/get-branch-by-node db {:node_labels (:node path-params)})}))

;; Retrieve node with location specific data
(defn get-entry-location
  [{:keys [path-params] :as request}]
  (ring-resp/response {:result
                          (sql/get-branch-by-node-with-location-data db {
                                                                          :node_labels (:node path-params) :mf_location_id (:mf_location_id path-params)})}))

(defn find-roots-by-account-id
  [{:keys [path-params] :as request}]
  (ring-resp/response {:result
                          (sql/find-roots-by-account-id db path-params)}))

;; upsert section_item entries
(defn upsert-location-section-item
  [{:keys [json-params] :as request}]
  (ring-resp/response
    (sql/upsert-location-section-item db json-params)))

;; Routes
(def routes #{["/get-entry/:node" :get (conj json-common-interceptors `get-entry)]
              ["/get-entry/:node/:mf_location_id" :get (conj json-common-interceptors `get-entry-location)]
              ["/find-roots-by-account-id/:id" :get (conj json-common-interceptors `find-roots-by-account-id)]
              ["/create-entry" :post (conj json-common-interceptors `create-entry)]
              ["/update-entry" :put (conj json-common-interceptors `update-entry)]
              ["/delete-entry/:id" :delete (conj json-common-interceptors `delete-entry)]
              ["/upsert-location-section-item" :put (conj json-common-interceptors `upsert-location-section-item)]
              ["/delete-location-section-item" :delete (conj json-common-interceptors `delete-location-section-item)]})


;; Boilerplate
;; Consumed by master-menu.server/create-server
;; See http/default-interceptors for additional options you can configure
(def service {:env :prod
              ;; You can bring your own non-default interceptors. Make
              ;; sure you include routing and set it up right for
              ;; dev-mode. If you do, many other keys for configuring
              ;; default interceptors will be ignored.
              ;; ::http/interceptors []
              ::http/routes routes

              ;; Uncomment next line to enable CORS support, add
              ;; string(s) specifying scheme, host and port for
              ;; allowed source(s):
              ;;
              ;; "http://localhost:8080"
              ;;
              ;;::http/allowed-origins ["scheme://host:port"]

              ;; Root for resource interceptor that is available by default.
              ::http/resource-path "/public"

              ;; Either :jetty, :immutant or :tomcat (see comments in project.clj)
              ::http/type :jetty
              ;;::http/host "localhost"
              ::http/port 8890
              ;; Options to pass to the container (Jetty)
              ::http/container-options {:h2c? true
                                        :h2? false
                                        ;:keystore "test/hp/keystore.jks"
                                        ;:key-password "password"
                                        ;:ssl-port 8443
                                        :ssl? false}})
