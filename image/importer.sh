#!/bin/sh
IMPORTER_SCRIPT_LOG_FILE="/var/log/vlo-import-script.log"

touch $IMPORTER_SCRIPT_LOG_FILE

# Filter sitemap properties
sed -e "s@^VLO_URL\=.*@VLO_URL\=${VLO_DOCKER_PUBLIC_HOME_URL}\/@g" \
		-e "s@^SOLR_QUERY_URL\=.*@SOLR_QUERY_URL\=${VLO_DOCKER_SOLR_URL}select\?@g" \
		-i /opt/vlo/bin/sitemap-generator/config.properties

#Update mapping definitions
if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "${VLO_MAPPING_DEFINITIONS_DIR}" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving (updated) VLO mapping definitions!" > $IMPORTER_SCRIPT_LOG_FILE
fi

#Run importer
cd /opt/vlo/bin/ && \
nice sh vlo_solr_importer.sh > $IMPORTER_SCRIPT_LOG_FILE 2>&1

#Solr index statistics
if [ ! -z "${VLO_DOCKER_STATSD_HOST}" ] && [ ! -z "${VLO_DOCKER_STATSD_PORT}" ] && [ ! -z "${STATSD_PREFIX}" ]; then
	# Filter properties in statics configuration
	cp "/opt/vlo/bin/statistics/config.properties" "/opt/vlo/bin/statistics/config.filtered.properties"
	/bin/bash "/opt/filter-config-file.sh" "/opt/vlo/bin/statistics/config.filtered.properties" \
		VLO_DOCKER_STATSD_HOST \
		VLO_DOCKER_STATSD_PORT \
		STATSD_PREFIX
	# Generate statistics
	cd /opt/vlo/bin/statistics/ && \
	nice sh start.sh /opt/vlo/bin/statistics/config.filtered.properties >> $IMPORTER_SCRIPT_LOG_FILE 2>&1
else
	echo "Not generating statistics - one or more required environment variables (VLO_DOCKER_STATSD_HOST, VLO_DOCKER_STATSD_PORT, STATSD_PREFIX) not set" \
		| tee -a >> $IMPORTER_SCRIPT_LOG_FILE
fi

#Generate sitemap
cd /opt/vlo/bin/sitemap-generator/ && \
nice sh start.sh >> $IMPORTER_SCRIPT_LOG_FILE 2>&1
