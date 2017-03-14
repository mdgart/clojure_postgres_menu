FROM java:8-alpine
MAINTAINER Your Name <you@example.com>

ADD target/master_menu-0.0.1-SNAPSHOT-standalone.jar /master_menu/app.jar

EXPOSE 8080

CMD ["java", "-jar", "/master_menu/app.jar"]
