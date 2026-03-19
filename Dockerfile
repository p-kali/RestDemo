#FROM ubuntu:latest
#FROM openjdk:17-jdk-slim
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY target/rest-demo.jar app.jar

RUN useradd -ms /bin/bash springuser
USER springuser

ENTRYPOINT ["java","-jar","app.jar"]