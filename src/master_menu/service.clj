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


;; Define handles
(defn get-branch
  [request]
  (ring-resp/response {:result
                          (sql/get-branch-by-node-label db {:node_label "2"})}))

(defn insert-root
  [request]
  (ring-resp/response (sql/insert-root db {:label {:EN {:displayName "Title Menu"}}})))


;; Routes
(def routes #{["/getbranch" :get (conj json-common-interceptors `get-branch)]
              ["/addroot" :get (conj json-common-interceptors `insert-root)]})


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
              ::http/port 8080
              ;; Options to pass to the container (Jetty)
              ::http/container-options {:h2c? true
                                        :h2? false
                                        ;:keystore "test/hp/keystore.jks"
                                        ;:key-password "password"
                                        ;:ssl-port 8443
                                        :ssl? false}})
