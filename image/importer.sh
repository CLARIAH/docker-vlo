#!/bin/sh
IMPORTER_SCRIPT_LOG_FILE="/var/log/vlo/import-script.log"

touch $IMPORTER_SCRIPT_LOG_FILE

STATS_CONFIG_FILE="/opt/vlo/bin/statistics/config.properties"
SITEMAP_CONFIG_FILE="/opt/vlo/bin/sitemap-generator/config.properties"
VLO_MONITOR_PROPERTIES_FILE="/opt/vlo/bin/monitor/vlo-monitor.properties"

#Update mapping definitions
if [ -n "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "${VLO_MAPPING_DEFINITIONS_DIR}" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving (updated) VLO mapping definitions!" > "${IMPORTER_SCRIPT_LOG_FILE}"
fi

#Run importer
export IMPORTER_JAVA_OPTS="{{.env.VLO_DOCKER_IMPORTER_JAVA_OPTS}}"
export IMPORTER_LOG_LEVEL="${VLO_DOCKER_IMPORTER_LOG_LEVEL}"
cd /opt/vlo/bin/ && \
nice sh vlo_solr_importer.sh -c "${VLO_DOCKER_CONFIG_FILE}" > "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1

#Solr index statistics
if [ -n "${VLO_DOCKER_STATSD_HOST}" ] && [ -n "${VLO_DOCKER_STATSD_PORT}" ] && [ -n "${STATSD_PREFIX}" ]; then
	# Filter properties in statics configuration
	(renderizer "${STATS_CONFIG_FILE}.tmpl" > "${STATS_CONFIG_FILE}" \
		&& cd /opt/vlo/bin/statistics/ \
		&& nice sh start.sh "${STATS_CONFIG_FILE}" >> "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1)
else
	echo "WARNING: Not generating statistics - one or more required environment variables (VLO_DOCKER_STATSD_HOST, VLO_DOCKER_STATSD_PORT, STATSD_PREFIX) not set" \
		| tee -a "${IMPORTER_SCRIPT_LOG_FILE}"
fi

# VLO change monitor
if [ -n "${VLO_DOCKER_MONITOR_RULES_FILE}" ]; then
	# Filter properties in monitor configuration
	(renderizer "${VLO_MONITOR_PROPERTIES_FILE}.tmpl" > "${VLO_MONITOR_PROPERTIES_FILE}" \
		&& cd /opt/vlo/bin/monitor \
		&& nice sh start.sh >> "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1)
else
	echo "Warning: not running VLO monitor because required environment variable 'VLO_DOCKER_MONITOR_RULES_FILE' has not beeen set" \
		| tee -a "${IMPORTER_SCRIPT_LOG_FILE}"
fi

#Sitemap
if [ -n "${VLO_DOCKER_PUBLIC_HOME_URL}" ] && [ -n "${VLO_DOCKER_SOLR_URL}" ]; then
	# Filter properties in sitemap generator configuraiton
	(renderizer "${SITEMAP_CONFIG_FILE}.tmpl" > "${SITEMAP_CONFIG_FILE}" \
		&& cd /opt/vlo/bin/sitemap-generator/ \
		&& nice sh start.sh >> "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1)
else
	echo "WARNING: Not generating sitemap - one or more required environment variables (VLO_DOCKER_PUBLIC_HOME_URL, VLO_DOCKER_SOLR_URL not set" \
		| tee -a "${IMPORTER_SCRIPT_LOG_FILE}"
fi
