# Multi-stage Dockerfile for Spring Boot on Railway
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build jar
COPY src ./src
RUN mvn clean package -DskipTests

# Production runtime stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Create unprivileged user
RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

# Copy built jar from build stage
COPY --from=build /app/target/*.jar app.jar

ENV PORT=8002
EXPOSE 8002

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

