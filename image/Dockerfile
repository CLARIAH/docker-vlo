FROM registry.gitlab.com/clarin-eric/docker-alpine-supervisor-java-tomcat-base:1.3.6

# General options
ENV	VLO_MAPPING_DEFINITIONS_DIST_URL="https://github.com/clarin-eric/VLO-mapping/archive/master.tar.gz" \
	VLO_MAPPING_DEFINITIONS_DIR="/srv/VLO-mapping" \
	VLO_DOCKER_WICKET_CONFIGURATION="deployment" \
	VLO_DOCKER_WICKET_BOTTOM_SNIPPET_URL="" \
	VLO_DOCKER_SOLR_USER_READ_ONLY="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_ONLY="secret" \
	VLO_DOCKER_SOLR_USER_READ_WRITE="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_WRITE="secret" \
	VLO_DOCKER_IMPORTER_JAVA_OPTS="" \
	VLO_DOCKER_TOMCAT_JAVA_OPTS="" \
	VLO_DOCKER_IMPORTER_LOG_LEVEL="INFO"

# VloConfig options
ENV	VLO_DOCKER_CONFIG_FILE="/opt/vlo/config/VloConfig.xml" \
	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping" \
	VLO_DOCKER_PUBLIC_HOME_URL="http://localhost:8080" \
	VLO_DOCKER_MAPPING_BASE_URI="file:/srv/VLO-mapping/" \
	VLO_DOCKER_VALUE_MAPPING_URI="file:/srv/VLO-mapping/value-maps/dist/master.xml" \
	VLO_DOCKER_FILE_PROCESSING_THREADS="-1" \
	VLO_DOCKER_SOLR_THREADS="2" \
	VLO_DOCKER_AVAILABILITY_STATUS_UPDATE_BATCH_SIZE="100" \
	VLO_DOCKER_DELETE_ALL_FIRST="false" \
	VLO_DOCKER_MAX_DAYS_IN_SOLR="7" \
	VLO_DOCKER_DATAROOTS_FILE="dataroots-production.xml" \
	VLO_MAPPING_DEFINITIONS_DIST_URL="https://github.com/clarin-eric/VLO-mapping/archive/master.tar.gz" \
	VLO_MAPPING_DEFINITIONS_DIR="/srv/VLO-mapping" \
	VLO_DOCKER_WICKET_CONFIGURATION="deployment" \
	VLO_DOCKER_WICKET_BOTTOM_SNIPPET_URL="" \
	VLO_DOCKER_SOLR_USER_READ_ONLY="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_ONLY="secret" \
	VLO_DOCKER_SOLR_USER_READ_WRITE="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_WRITE="secret" \
	VLO_DOCKER_IMPORTER_JAVA_OPTS="" \
	VLO_DOCKER_TOMCAT_JAVA_OPTS="" \
	VLO_DOCKER_VCR_MAXIMUM_ITEMS_COUNT="1000" \
	VLO_DOCKER_WEB_APP_LOCALE="en-GB" \
	VLO_DOCKER_CONCEPT_REGISTRY_URL="https://concepts.clarin.eu/ccr/api/find-concepts" \
	VLO_DOCKER_VOCABULARY_REGISTRY_URL="http://clavas.clarin.eu/clavas/public/api/find-concepts" \
	VLO_DOCKER_FEEDBACK_FORM_URL="http://www.clarin.eu/node/3759?url=" \
	VLO_DOCKER_FCS_BASE_URL="https://spraakbanken.gu.se/ws/fcs/2.0/aggregator/" \
	VLO_DOCKER_LRS_BASE_URL="https://switchboard.clarin.eu/" \
	VLO_DOCKER_LRS_POPUP_SCRIPT_URL="https://switchboard.clarin.eu/popup/switchboardpopup.js" \
	VLO_DOCKER_LRS_POPUP_STYLE_URL="https://switchboard.clarin.eu/popup/switchboardpopup.js" \
	VLO_DOCKER_VCR_SUBMIT_ENDPOINT="https://collections.clarin.eu/app/submit/extensional" \
	VLO_DOCKER_CENTRE_REGISTRY_CENTRES_LIST_JSON_URL="https://centres.clarin.eu/api/model/Centre" \
	VLO_DOCKER_CENTRE_REGISTRY_OAI_PMH_ENDPOINTS_LIST_JSON_URL="https://centres.clarin.eu/api/model/OAIPMHEndpoint" \
	VLO_DOCKER_OTHER_PROVIDERS_MARKUP_FILE="" \
	VLO_DOCKER_DATASET_STRUCTURED_DATA_ENABLED="true" \
	VLO_DOCKER_LINK_CHECKER_DB_CONNECTION_STRING="" \
	VLO_DOCKER_LINK_CHECKER_DB_USER="" \
	VLO_DOCKER_LINK_CHECKER_DB_PASSWORD="" \
	VLO_DOCKER_EXPOSURE_ENABLED="false" \
	VLO_DOCKER_EXPOSURE_DB_NAME="" \
	VLO_DOCKER_EXPOSURE_DB_HOST="" \
	VLO_DOCKER_EXPOSURE_DB_PORT="" \
	VLO_DOCKER_EXPOSURE_DB_USER="" \
	VLO_DOCKER_EXPOSURE_DB_PASSWORD="" 

# VloConfig Statsd reporting options
ENV VLO_DOCKER_STATSD_HOST="" \
	VLO_DOCKER_STATSD_PORT="8125" \
	STATSD_PREFIX=""
	
# VloConfig Piwik options
ENV VLO_DOCKER_PIWIK_ENABLE_TRACKER="false" \
	VLO_DOCKER_PIWIK_SITE_ID="3" \
	VLO_DOCKER_PIWIK_HOST="https://stats.clarin.eu/" \
	VLO_DOCKER_PIWIK_DOMAINS="*.vlo.clarin.eu"
	
# This should match the Solr image
ENV SOLR_USER="solr" \
    SOLR_UID="8983"
    
ENV VLO_BASE="/opt/vlo"

RUN	apk add --no-cache \
 		jq=1.6-r0 \
 	&& pip install yq==2.10.0

RUN rm -r "${CATALINA_BASE}/webapps/ROOT"

COPY webapp/vlo/ ${VLO_BASE}
COPY webapp/sitemap-config.properties ${VLO_BASE}/bin/sitemap-generator/config.properties
COPY webapp/statistics-config.properties ${VLO_BASE}/bin/statistics/config.properties
COPY webapp/vlo-context.xml ${CATALINA_BASE}/conf/Catalina/localhost/ROOT.xml
COPY tomcat/setenv.sh ${CATALINA_BASE}/bin/setenv.sh
COPY importer.sh /opt/importer.sh
COPY filter-properties-to-xml.sh /opt/filter-properties-to-xml.sh
COPY querysolr.sh /opt/querysolr.sh
COPY vlo-init.sh /init/vlo-init.sh
COPY VloConfig-filter-rules.txt /init/VloConfig-filter-rules.txt

COPY fluentd/vlo.conf /etc/fluentd/conf.d/vlo.conf


RUN chmod u+x /opt/importer.sh \
 && chmod u+x /opt/filter-properties-to-xml.sh \
 && chmod u+x /init/vlo-init.sh \
 && chmod u+x /opt/querysolr.sh

# Solr home should be sharable with Solr image, which uses the 'solr' user...
RUN adduser -D -u $SOLR_UID $SOLR_USER \
 && chown -R -L $SOLR_USER ${VLO_BASE}/solr/vlo-solr-home

VOLUME ["/opt/sitemap", "/opt/statsd", "/srv/VLO-mapping", "/srv/vlo-solr-home", "${VLO_BASE}/solr/vlo-solr-home"]
