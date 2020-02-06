FROM openjdk:15-alpine AS build

USER root

RUN apk add maven

COPY . /app

RUN cd /app && mvn clean package

FROM openjdk:15-alpine

COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app.jar"]