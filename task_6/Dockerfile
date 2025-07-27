
FROM amazoncorretto:17-alpine-jdk

# Set the working directory
WORKDIR /app

# Copy the compiled JAR file into the container
COPY target/spring-app-1.0.0.jar app.jar

# Expose the port the application runs on
EXPOSE 8081


ENTRYPOINT ["java", "-jar", "app.jar"]