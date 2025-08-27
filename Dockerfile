# Stage 1: build with Maven (includes tests)
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first for caching
COPY pom.xml ./


# Copy source
COPY src ./src

# Run tests and package
RUN mvn -B -e -T1C test package

# Stage 2: runtime
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Copy built artifact (adjust name if different)
# If pom produces a war in target/*.war or jar, adapt accordingly
COPY --from=build /app/target/*.war /app/app.war

# If the project is a servlet WAR, use embedded Tomcat/Jetty or run via java -jar if executable jar
# The HelloServlet repo is a simple servlet packaged as a war; use an embedded Tomcat image:
FROM tomcat:10.1-jdk17
# Remove default webapps and copy ours
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
