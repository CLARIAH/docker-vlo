FROM registry.gitlab.com/clarin-eric/docker-tomcat8:1.3.2

ENV JAVA_OPTS="-Dwicket.configuration=deployment" \
	VLO_MAPPING_DEFINITIONS_DIST_URL="https://github.com/clarin-eric/VLO-mapping/archive/master.tar.gz" \
	VLO_MAPPING_DEFINITIONS_DIR="/srv/VLO-mapping" \
	STATSD_PREFIX=vlo.docker

# VloConfig options
ENV	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping" \
	VLO_DOCKER_PUBLIC_HOME_URL="https://vlo.clarin.eu" \
	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping/" \
	VLO_DOCKER_FILE_PROCESSING_THREADS="-1" \
	VLO_DOCKER_SOLR_THREADS="2" \
	VLO_DOCKER_DELETE_ALL_FIRST="false" \
	VLO_DOCKER_MAX_DAYS_IN_SOLR="7" \
	VLO_DOCKER_DATAROOTS_FILE="dataroots-production.xml"

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
