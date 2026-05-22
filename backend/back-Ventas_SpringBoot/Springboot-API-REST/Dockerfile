# Build stage
FROM maven:3.8.8-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and download dependencies to cache the layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn package -DskipTests

# Run stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Ventas backend runs on default port 8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
