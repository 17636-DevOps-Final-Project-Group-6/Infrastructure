# Stage 1: Build with Maven (updated image tag)
FROM maven:3.8.7-eclipse-temurin-17 AS builder
WORKDIR /app

# Clone and build (add --depth 1 to minimize clone size)
RUN git clone https://github.com/17636-DevOps-Final-Project-Group-6/spring-petclinic . \
    && git checkout main \  
    && mvn clean package -DskipTests

# Stage 2: Runtime (official Eclipse Temurin image)
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/spring-petclinic-*.jar /app/spring-petclinic.jar

EXPOSE 8080
CMD ["java", "-jar", "/app/spring-petclinic.jar"]