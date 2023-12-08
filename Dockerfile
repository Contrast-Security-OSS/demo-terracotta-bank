#
# BUILD STAGE
# Build the app using a gradle image and run the included tests.
#
FROM gradle:4.10.2-jdk8-alpine as build
WORKDIR /home/gradle/src
COPY .git/ .git/
COPY build.gradle settings.gradle ./
COPY evil/ evil/
COPY src/ src/
RUN gradle build --stacktrace

#
# RUNTIME STAGE
# Take only the compilied application .war file form the build stage above and run it in a JRE container.
#
FROM openjdk:8-jre-alpine as runtime
COPY --from=build /home/gradle/src/build/libs/terracotta-bank-servlet-0.0.1-SNAPSHOT.war /app/terracotta-bank-servlet-0.0.1-SNAPSHOT.war
WORKDIR /app
EXPOSE 8080
CMD ["java", "-jar", "terracotta-bank-servlet-0.0.1-SNAPSHOT.war"]
