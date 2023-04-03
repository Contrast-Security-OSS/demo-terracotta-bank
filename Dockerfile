FROM tomcat:9.0

RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY build/libs/terracotta-bank-servlet-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

#Add Contrast
ADD https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.contrastsecurity&a=contrast-agent&v=LATEST /opt/contrast/contrast.jar

#Enable Contrast
ENV JAVA_OPTS='-javaagent:/opt/contrast/contrast.jar -Dcontrast.application.name=terracotta-bank'

EXPOSE 8080

CMD ["catalina.sh", "run"]