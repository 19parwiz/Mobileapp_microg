# Multi-stage build for Spring Boot application
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN apk add --no-cache wget

# Copy the built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Default; Railway overrides with PORT at runtime
EXPOSE 8080

# Health check (uses PORT when Railway sets it; shell form so env expands)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD sh -c 'wget -q -O /dev/null "http://127.0.0.1:$${PORT:-8080}/api/health" || exit 1'

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

