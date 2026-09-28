# Multi-stage build: Maven downloads dependencies and compiles in the build
# stage (this needs real internet access to Maven Central — that's why the
# build happens here, in `docker compose up --build` on your machine,
# rather than something pre-built), then only the runtime JRE + the built
# jar are kept in the final image.

FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Cache dependencies in their own layer so a source-only change doesn't
# re-download the internet on every rebuild.
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /build/target/careerguide-api.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
