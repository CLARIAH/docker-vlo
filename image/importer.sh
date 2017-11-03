#!/bin/sh
if [ ! -z "${STATSD_PREFIX}" ]; then
    echo "Adjusting with statsd prefix (${STATSD_PREFIX}) override"
    sed -i "s/report\.statsd\.prefix\=.*/report\.statsd\.prefix\=${STATSD_PREFIX}/g" /opt/vlo/bin/statistics/config.properties
fi

#Update mapping definitions
if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "${VLO_MAPPING_DEFINITIONS_DIR}" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving (updated) VLO mapping definitions!"
fi

#Run importer
touch /opt/vlo/log/vlo-importer.log
ln -sf /dev/stdout /opt/vlo/log/vlo-importer.log
cd /opt/vlo/bin/ && \
sh vlo_solr_importer.sh

#Generate statistics
cd /opt/vlo/bin/statistics/ && \
sh start.sh /opt/vlo/bin/statistics/config.properties

#Generate sitemap
cd /opt/vlo/bin/sitemap-generator/ && \
sh start.sh


