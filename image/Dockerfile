FROM registry.gitlab.com/clarin-eric/docker-alpine-supervisor-java-tomcat-base:1.0.6

ENV VLO_DOCKER_SOLR_USER_READ_ONLY="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_ONLY="secret" \
	VLO_DOCKER_SOLR_USER_READ_WRITE="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_WRITE="secret" \
	VLO_MAPPING_DEFINITIONS_DIST_URL="https://github.com/clarin-eric/VLO-mapping/archive/master.tar.gz" \
	VLO_MAPPING_DEFINITIONS_DIR="/srv/VLO-mapping" \
	VLO_DOCKER_STATSD_HOST="" \
	VLO_DOCKER_STATSD_PORT="8125" \
	STATSD_PREFIX=""
	
# VloConfig general options
ENV	VLO_DOCKER_CONFIG_FILE="/opt/vlo/config/VloConfig.xml" \
	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping" \
	VLO_DOCKER_PUBLIC_HOME_URL="http://localhost:8080" \
	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping/" \
	VLO_DOCKER_VALUE_MAPPING_URI="file:/srv/VLO-mapping/value-maps/dist/master.xml" \
	VLO_DOCKER_FILE_PROCESSING_THREADS="-1" \
	VLO_DOCKER_SOLR_THREADS="2" \
	VLO_DOCKER_DELETE_ALL_FIRST="false" \
	VLO_DOCKER_MAX_DAYS_IN_SOLR="7" \
	VLO_DOCKER_DATAROOTS_FILE="dataroots-production.xml" \
	VLO_DOCKER_WICKET_CONFIGURATION="deployment" \
	VLO_DOCKER_WICKET_BOTTOM_SNIPPET_URL=""
	
# VloConfig Piwik options
ENV VLO_DOCKER_PIWIK_ENABLE_TRACKER="false" \
	VLO_DOCKER_PIWIK_SITE_ID="3" \
	VLO_DOCKER_PIWIK_HOST="https://stats.clarin.eu/" \
	VLO_DOCKER_PIWIK_DOMAINS="*.vlo.clarin.eu"
	
# This should match the Solr image
ENV SOLR_USER="solr" \
    SOLR_UID="8983"

RUN	apk add --update \
 		jq

RUN rm -r /srv/tomcat8/webapps/ROOT

COPY webapp/vlo/ /opt/vlo
COPY webapp/sitemap-config.properties /opt/vlo/bin/sitemap-generator/config.properties
COPY webapp/statistics-config.properties /opt/vlo/bin/statistics/config.properties
COPY webapp/vlo-context.xml /srv/tomcat8/conf/Catalina/localhost/ROOT.xml
COPY importer.sh /opt/importer.sh
COPY filter-config-file.sh /opt/filter-config-file.sh
COPY vlo-init.sh /init/vlo-init.sh

COPY fluentd/vlo.conf /etc/fluentd/conf.d/vlo.conf


RUN chmod u+x /opt/importer.sh \
 && chmod u+x /opt/filter-config-file.sh \
 && chmod u+x /init/vlo-init.sh

# Solr home should be sharable with Solr image, which uses the 'solr' user...
RUN adduser -D -u $SOLR_UID $SOLR_USER \
 && chown -R -L $SOLR_USER /opt/vlo/solr/vlo-solr-home

VOLUME ["/opt/sitemap", "/opt/statsd", "/srv/VLO-mapping", "/srv/vlo-solr-home", "/opt/vlo/solr/vlo-solr-home"]
