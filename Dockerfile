#FROM ubuntu:latest
#FROM openjdk:17-jdk-slim
# Use official OpenJDK 17 as base image
FROM eclipse-temurin:17-jdk-jammy

# Set working directory inside container
WORKDIR /app

# Copy the JAR file into the container
COPY target/rest-demo.jar app.jar

# Expose the port your app runs on
EXPOSE 8080

RUN useradd -ms /bin/bash springuser
USER springuser

# Command to run the app
ENTRYPOINT ["java","-jar","/app/app.jar"]