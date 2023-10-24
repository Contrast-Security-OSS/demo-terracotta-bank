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
RUN gradle build -x test --stacktrace --no-daemon

#
# TEST STAGE
# Add additional dependencies required for testing (selenium and the contrast.jar) and run testing
# TODO: Remove the dependancy on running with contrast from the build.gradle. 
# FIXME: Not working! 
# FROM build as test
# USER root
# RUN apk add --no-cache firefox-esr unzip wget curl xvfb dbus
# RUN wget -O /tmp/selenium-server-standalone.jar https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar
# COPY --from=contrast/agent-java:latest /contrast/contrast-agent.jar ./contrast.jar
# USER gradle
# ENTRYPOINT [ "gradle", "cleanTest", "test"]


#
# RUNTIME STAGE
# Take only the compilied application .war file form the build stage above and run it in a JRE container.
#
FROM openjdk:8-jre-alpine as runtime
COPY --from=build /home/gradle/src/build/libs/terracotta-bank-servlet-0.0.1-SNAPSHOT.war /app/terracotta-bank-servlet-0.0.1-SNAPSHOT.war
WORKDIR /app
EXPOSE 8080
CMD ["java", "-jar", "terracotta-bank-servlet-0.0.1-SNAPSHOT.war"]

#
# CONTRAST STAGE
# Take the runtime stage above and add the Contrast agent jar and set JAVA_TOOL_OPTIONS to enable it.
#
FROM runtime as contrast
COPY --from=contrast/agent-java:latest /contrast/contrast-agent.jar /opt/contrast/contrast.jar
ENV JAVA_TOOL_OPTIONS='-javaagent:/opt/contrast/contrast.jar -Dcontrast.application.name=terracotta-bank'
