FROM registry.gitlab.com/clarin-eric/docker-tomcat8:1.3.2

ENV JAVA_OPTS="-Dwicket.configuration=deployment"

RUN rm -r /var/lib/tomcat8/webapps/ROOT

COPY webapp/vlo/ /opt/vlo
COPY webapp/sitemap-config.properties /opt/vlo/bin/sitemap-generator/config.properties
COPY webapp/statistics-config.properties /opt/vlo/bin/statistics/config.properties
COPY webapp/vlo-context.xml /etc/tomcat8/Catalina/localhost/ROOT.xml
COPY importer.sh /opt/importer.sh
COPY filter-vlo-config.sh /opt/filter-vlo-config.sh
COPY populate-vlo-solr-home.sh /opt/populate-vlo-solr-home.sh
COPY init.sh /app/init.sh

VOLUME ["/opt/sitemap", "/opt/statsd", "/srv/VLO-mapping", "/srv/vlo-solr-home"]

RUN chmod u+x /opt/importer.sh \
 && chmod u+x /app/init.sh
