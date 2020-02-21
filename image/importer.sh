#!/bin/sh
IMPORTER_SCRIPT_LOG_FILE="/var/log/vlo-import-script.log"

touch $IMPORTER_SCRIPT_LOG_FILE

STATS_CONFIG_BASE="/opt/vlo/bin/statistics/config"
STATS_CONFIG_FILE="${STATS_CONFIG_BASE}.properties"
STATS_CONFIG_FILTERED="${STATS_CONFIG_BASE}.filtered.properties"

SITEMAP_CONFIG_FILE="/opt/vlo/bin/sitemap-generator/config.properties"
SITEMAP_CONFIG_BACKUP="${SITEMAP_CONFIG_FILE}.orig"

#Update mapping definitions
if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "${VLO_MAPPING_DEFINITIONS_DIR}" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving (updated) VLO mapping definitions!" > "${IMPORTER_SCRIPT_LOG_FILE}"
fi

#Run importer
export IMPORTER_JAVA_OPTS="{{VLO_DOCKER_IMPORTER_JAVA_OPTS}}"
export IMPORTER_LOG_LEVEL="${VLO_DOCKER_IMPORTER_LOG_LEVEL}"
cd /opt/vlo/bin/ && \
nice sh vlo_solr_importer.sh -c ${VLO_DOCKER_CONFIG_FILE} > "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1

#Solr index statistics
if [ ! -z "${VLO_DOCKER_STATSD_HOST}" ] && [ ! -z "${VLO_DOCKER_STATSD_PORT}" ] && [ ! -z "${STATSD_PREFIX}" ]; then
	# Filter properties in statics configuration
	cp "${STATS_CONFIG_FILE}" "${STATS_CONFIG_FILTERED}"
	replaceVarInFile "VLO_DOCKER_STATSD_HOST" "${VLO_DOCKER_STATSD_HOST}" "${STATS_CONFIG_FILTERED}"
	replaceVarInFile "VLO_DOCKER_STATSD_PORT" "${VLO_DOCKER_STATSD_PORT}" "${STATS_CONFIG_FILTERED}"
	replaceVarInFile "STATSD_PREFIX" "${STATSD_PREFIX}" "${STATS_CONFIG_FILTERED}"
	# Generate statistics
	(cd /opt/vlo/bin/statistics/ \
		&& nice sh start.sh "${STATS_CONFIG_FILTERED}" >> "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1)
else
	echo "WARNING: Not generating statistics - one or more required environment variables (VLO_DOCKER_STATSD_HOST, VLO_DOCKER_STATSD_PORT, STATSD_PREFIX) not set" \
		| tee -a "${IMPORTER_SCRIPT_LOG_FILE}"
fi

#Sitemap
if [ ! -z "${VLO_DOCKER_PUBLIC_HOME_URL}" ] && [ ! -z "${VLO_DOCKER_SOLR_URL}" ]; then
	# Filter properties in sitemap generator configuraiton
	cp "${SITEMAP_CONFIG_FILE}" "${SITEMAP_CONFIG_BACKUP}"
	replaceVarInFile "VLO_DOCKER_PUBLIC_HOME_URL" "${VLO_DOCKER_PUBLIC_HOME_URL}" "${SITEMAP_CONFIG_FILE}"
	replaceVarInFile "VLO_DOCKER_SOLR_URL" "${VLO_DOCKER_SOLR_URL}" "${SITEMAP_CONFIG_FILE}"
	replaceVarInFile "VLO_DOCKER_SOLR_USER_READ_ONLY" "${VLO_DOCKER_SOLR_USER_READ_ONLY}" "${SITEMAP_CONFIG_FILE}"
	replaceVarInFile "VLO_DOCKER_SOLR_PASSWORD_READ_ONLY" "${VLO_DOCKER_SOLR_PASSWORD_READ_ONLY}" "${SITEMAP_CONFIG_FILE}"

	# Generate sitemap
	(cd /opt/vlo/bin/sitemap-generator/ \
		&& nice sh start.sh >> "${IMPORTER_SCRIPT_LOG_FILE}" 2>&1)

	# Undo filtering
	cp "${SITEMAP_CONFIG_BACKUP}" "${SITEMAP_CONFIG_FILE}"
else
	echo "WARNING: Not generating sitemap - one or more required environment variables (VLO_DOCKER_PUBLIC_HOME_URL, VLO_DOCKER_SOLR_URL not set" \
		| tee -a "${IMPORTER_SCRIPT_LOG_FILE}"
fi
