FROM openjdk:13-jdk-alpine AS build

RUN apk add maven

COPY . /app

RUN cd /app && mvn clean package

FROM openjdk:13-jdk-alpine

RUN addgroup spring && \
    adduser -D -G spring spring

USER spring:spring

COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app.jar"]