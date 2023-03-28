FROM registry.gitlab.com/clarin-eric/docker-alpine-supervisor-java-tomcat-base:9.0.72-java17_1.2.0

ARG JQ_VERSION=1.6
ARG YQ_VERSION=2.13.0

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
	VLO_DOCKER_WICKET_CONFIGURATION="deployment" \
	VLO_DOCKER_WICKET_BOTTOM_SNIPPET_URL="" \
	VLO_DOCKER_SOLR_USER_READ_ONLY="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_ONLY="secret" \
	VLO_DOCKER_SOLR_USER_READ_WRITE="user_read" \
	VLO_DOCKER_SOLR_PASSWORD_READ_WRITE="secret" \
	VLO_DOCKER_IMPORTER_JAVA_OPTS="" \
	VLO_DOCKER_TOMCAT_JAVA_OPTS="" \
	VLO_DOCKER_VCR_MAXIMUM_ITEMS_COUNT="100" \
	VLO_DOCKER_WEB_APP_LOCALE="en-GB" \
	VLO_DOCKER_CONCEPT_REGISTRY_URL="https://concepts.clarin.eu/ccr/api/find-concepts" \
	VLO_DOCKER_VOCABULARY_REGISTRY_URL="http://clavas.clarin.eu/clavas/public/api/find-concepts" \
	VLO_DOCKER_FEEDBACK_FORM_URL="http://www.clarin.eu/node/3759?url=" \
	VLO_DOCKER_FCS_BASE_URL="https://spraakbanken.gu.se/ws/fcs/2.0/aggregator/" \
	VLO_DOCKER_LRS_BASE_URL="https://switchboard.clarin.eu/" \
	VLO_DOCKER_LRS_POPUP_SCRIPT_URL="https://switchboard.clarin.eu/popup/switchboardpopup.js" \
	VLO_DOCKER_LRS_POPUP_STYLE_URL="https://switchboard.clarin.eu/popup/switchboardpopup.css" \
	VLO_DOCKER_LRS_POPUP_ENABLED="true" \
	VLO_DOCKER_VCR_SUBMIT_ENDPOINT="https://collections.clarin.eu/submit/extensional" \
	VLO_DOCKER_CENTRE_REGISTRY_CENTRES_LIST_JSON_URL="https://centres.clarin.eu/api/model/Centre" \
	VLO_DOCKER_CENTRE_REGISTRY_OAI_PMH_ENDPOINTS_LIST_JSON_URL="https://centres.clarin.eu/api/model/OAIPMHEndpoint" \
	VLO_DOCKER_OTHER_PROVIDERS_MARKUP_FILE="" \
	VLO_DOCKER_DATASET_STRUCTURED_DATA_ENABLED="true" \
	VLO_DOCKER_LINK_CHECKER_DB_CONNECTION_STRING="" \
	VLO_DOCKER_LINK_CHECKER_DB_USER="" \
	VLO_DOCKER_LINK_CHECKER_DB_PASSWORD="" \
	VLO_DOCKER_LINK_CHECKER_DB_POOL_SIZE="20" \
	VLO_DOCKER_LINK_CHECKER_MAX_DAY_SINCE_CHECKED="100" \
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
	
# VLO monitor settings
ENV VLO_DOCKER_MONITOR_RULES_FILE="/opt/vlo/config/vlo-monitor-rules.properties" \
	VLO_DOCKER_MONITOR_DB_PATH="/opt/vlo-monitoring/vlo-monitoring" \
	VLO_DOCKER_MONITOR_PRUNE_AFTER_DAYS="100"
	
# This should match the Solr image
ENV SOLR_USER="solr" \
    SOLR_UID="8983"
    
ENV VLO_BASE="/opt/vlo"

# Tomcat jars to skip
ENV TOMCAT_JARS_TO_SKIP="bootstrap-*.jar,checker-qual-*.jar,cnriutil-*.jar,error_prone_annotations-*.jar,failureaccess-*.jar,FastInfoset-*.jar,gson-*.jar,guava-*-jre.jar,handle-*.jar,http2-client-*.jar,http2-common-*.jar,http2-hpack-*.jar,http2-http-client-transport-*.jar,httpcore-*.jar,httpmime-*.jar,istack-commons-runtime-*.jar,j2objc-annotations-*.jar,jackson-annotations-*.jar,jackson-core-*.jar,jackson-databind-*.jar,javax.activation-api-*.jar,javax.annotation-api-*.jar,javax.inject-1.jar,jcl-over-slf4j-*.jar,jdk-serializable-functional-*.jar,jersey-client-*.jar,jersey-core-*.jar,jettison-*.jar,joda-time-*.jar,jquery-*.jar,jquery-selectors-*.jar,json-????????.jar,json-simple-*.jar,jsr305-*.jar,jsr311-api-*.jar,listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar,modernizr-*.jar,mysql-connector-java-*.jar,netty-buffer-*.jar,netty-codec-*.jar,netty-common-*.jar,netty-handler-*.jar,netty-resolver-*.jar,netty-transport-*.jar,netty-transport-native-epoll-*.jar,netty-transport-native-unix-common-*.jar,openjson-*.jar,postgresql-*.jar,Saxon-HE-*.jar,snappy-java-1.*.jar,solr-solrj-*.jar,spring-aop-*.jar,spring-beans-*.jar,spring-context-*.jar,spring-core-*.jar,spring-expression-*.jar,spring-jcl-*.jar,spring-web-*.jar,stax-ex-*.jar,stax2-api-*.jar,txw2-*.jar,vlo-commons-*.jar,vlo-exposure-*.jar,vtd-xml-*.jar,wicket-bootstrap-core-*.jar,wicket-core-*.jar,wicket-extensions-*.jar,wicket-ioc-*.jar,wicket-jquery-ui-*.jar,wicket-jquery-ui-core-*.jar,wicket-request-*.jar,wicket-spring-*.jar,wicket-util-*.jar,wicket-webjars-*.jar,woodstox-core-*.jar,zookeeper-*.jar,zookeeper-jute-*.jar"

RUN	apk add --no-cache \
 		"jq=~${JQ_VERSION}" \
 	&& pip --no-cache-dir install "yq==${YQ_VERSION}"

RUN rm -r "${CATALINA_BASE}/webapps/ROOT"

WORKDIR /
COPY webapp/vlo/ ${VLO_BASE}
COPY config/sitemap-config.properties.tmpl ${VLO_BASE}/bin/sitemap-generator/config.properties.tmpl
COPY config/statistics-config.properties.tmpl ${VLO_BASE}/bin/statistics/config.properties.tmpl
COPY config/vlo-monitor.properties.tmpl ${VLO_BASE}/bin/monitor/vlo-monitor.properties.tmpl
COPY webapp/vlo-context.xml ${CATALINA_BASE}/conf/Catalina/localhost/ROOT.xml
COPY tomcat/setenv.sh ${CATALINA_BASE}/bin/setenv.sh
COPY importer.sh /opt/importer.sh
COPY filter-properties-to-xml.sh /opt/filter-properties-to-xml.sh
COPY querysolr.sh /opt/querysolr.sh
COPY vlo-init.sh /init/vlo-init.sh
COPY VloConfig-filter-rules.txt /init/VloConfig-filter-rules.txt

COPY fluentd/vlo.conf /etc/fluentd/conf.d/vlo.conf

COPY healthcheck/check-solr-connection.sh /etc/healthcheck.d/check-solr-connection.sh

RUN chmod u+x /opt/importer.sh \
 && chmod u+x /opt/filter-properties-to-xml.sh \
 && chmod u+x /init/vlo-init.sh \
 && chmod u+x /opt/querysolr.sh
 
# VLO logging in /var/log/vlo
RUN rmdir "${VLO_BASE}/log" \
	&& mkdir '/var/log/vlo' \
	&& ln -s '/var/log/vlo' "${VLO_BASE}/log"

# Solr home should be sharable with Solr image, which uses the 'solr' user...
RUN adduser -D -u $SOLR_UID $SOLR_USER \
 && chown -R -L $SOLR_USER ${VLO_BASE}/solr/vlo-solr-home

VOLUME ["/srv/VLO-mapping", "/srv/vlo-solr-home", "${VLO_BASE}/solr/vlo-solr-home", "/opt/sitemap", "/opt/vlo-monitoring", "/opt/statsd"]

WORKDIR /opt/vlo
