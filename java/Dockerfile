FROM maven:3.9-eclipse-temurin-23 AS build

WORKDIR /app

COPY java/pom.xml .
RUN mvn dependency:go-offline

COPY java/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:23-jre

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar
COPY shared /shared

EXPOSE 5003

ENTRYPOINT ["java", "-jar", "app.jar"]
