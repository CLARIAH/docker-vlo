#FROM registry.gitlab.com/clarin-eric/docker-tomcat8:1.3.1
FROM docker-tomcat8:1.2.2-12-g8316dab

ENV JAVA_OPTS="-Dwicket.configuration=deployment -Dsolr.data.dir=/opt/solr-data"

RUN mkdir -p /opt/solr-data
RUN rm -r /var/lib/tomcat8/webapps/ROOT

COPY webapp/vlo/ /opt/vlo
COPY webapp/sitemap-config.properties /opt/vlo/bin/sitemap-generator/config.properties
COPY webapp/statistics-config.properties /opt/vlo/bin/statistics/config.properties
COPY webapp/vlo-context.xml /etc/tomcat8/Catalina/localhost/ROOT.xml
COPY webapp/solr-context.xml /etc/tomcat8/Catalina/localhost/solr.xml
COPY importer.sh /opt/importer.sh
COPY filter-vlo-config.sh /opt/filter-vlo-config.sh
COPY init.sh /app/init.sh
COPY fluentd/vlo.conf /etc/fluentd/conf.d/vlo.conf

VOLUME ["/opt/sitemap", "/opt/statsd", "/srv/VLO-mapping"]

RUN chmod u+x /opt/importer.sh \
 && chmod u+x /app/init.sh
