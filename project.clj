(defproject master_menu "0.0.1-SNAPSHOT"
  :description "A generic microservice menu manager."
  :url "https://github.com/MomentFeedInc/master_menu"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [io.pedestal/pedestal.service "0.5.2"]

                 ;; Remove this line and uncomment one of the next lines to
                 ;; use Immutant or Tomcat instead of Jetty:
                 [io.pedestal/pedestal.jetty "0.5.2"]
                 ;; [io.pedestal/pedestal.immutant "0.5.2"]
                 ;; [io.pedestal/pedestal.tomcat "0.5.2"]

                 [ch.qos.logback/logback-classic "1.1.8" :exclusions [org.slf4j/slf4j-api]]
                 [org.slf4j/jul-to-slf4j "1.7.22"]
                 [org.slf4j/jcl-over-slf4j "1.7.22"]
                 [org.slf4j/log4j-over-slf4j "1.7.22"]
                 [cheshire "5.7.0"]
                 [com.novemberain/monger "3.1.0"]
                 [org.postgresql/postgresql "9.4-1201-jdbc41"]
                 [com.layerware/hugsql-core "0.4.7"]
                 [com.layerware/hugsql-adapter-clojure-jdbc "0.4.7"]
                 [funcool/clojure.jdbc "0.9.0"]]

  :min-lein-version "2.0.0"
  :resource-paths ["config", "resources"]
  ;; If you use HTTP/2 or ALPN, use the java-agent to pull in the correct alpn-boot dependency
  ;:java-agents [[org.mortbay.jetty.alpn/jetty-alpn-agent "2.0.5"]]
  :profiles {:dev {:aliases {"run-dev" ["trampoline" "run" "-m" "master-menu.server/run-dev"]}
                   :dependencies [[io.pedestal/pedestal.service-tools "0.5.2"]]}
             :uberjar {:aot [master-menu.server]}}
  :main ^{:skip-aot true} master-menu.server)
