#!/bin/sh
IMPORTER_SCRIPT_LOG_FILE="/var/log/vlo-import-script.log"

touch $IMPORTER_SCRIPT_LOG_FILE

if [ ! -z "${STATSD_PREFIX}" ]; then
    echo "Adjusting with statsd prefix (${STATSD_PREFIX}) override" > $IMPORTER_SCRIPT_LOG_FILE
    sed -i "s/report\.statsd\.prefix\=.*/report\.statsd\.prefix\=${STATSD_PREFIX}/g" /opt/vlo/bin/statistics/config.properties
fi

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
sh vlo_solr_importer.sh > $IMPORTER_SCRIPT_LOG_FILE 2>&1

#Generate statistics
cd /opt/vlo/bin/statistics/ && \
sh start.sh /opt/vlo/bin/statistics/config.properties >> $IMPORTER_SCRIPT_LOG_FILE 2>&1

#Generate sitemap
cd /opt/vlo/bin/sitemap-generator/ && \
sh start.sh >> $IMPORTER_SCRIPT_LOG_FILE 2>&1
