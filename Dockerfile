FROM tomcat:9.0

RUN rm -rf /usr/local/tomcat/webapps/ROOT
ADD build/libs/terracotta-bank-servlet-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war


#Add Contrast
RUN mkdir /opt/contrast
RUN apt-get update; apt-get install curl
RUN curl --fail --silent --location "https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.contrastsecurity&a=contrast-agent&v=LATEST" -o /opt/contrast/contrast.jar

#Enable Contrast
ENV JAVA_OPTS='-javaagent:/opt/contrast/contrast.jar -Dcontrast.standalone.appname=terracotta-bank'

EXPOSE 8080

CMD ["catalina.sh", "run"]