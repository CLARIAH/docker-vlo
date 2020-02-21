#!/bin/sh
set -e

SOLR_PORT_WAIT_TIMEOUT="300"
SOLR_CHECK_INTERVAL="5"
SOLR_CHECK_PATH="fast?q=*:*&rows=0"

VLO_DOCKER_CONFIG_MAPPING_RULES_FILE="/init/VloConfig-filter-rules.txt"

main () {
	# Filter VLO configuration
	filter_file "${VLO_DOCKER_CONFIG_FILE}" \
		VLO_DOCKER_DATAROOTS_FILE \
		VLO_DOCKER_MAPPING_BASE_URI

	filter_xml_file "${VLO_DOCKER_CONFIG_FILE}" "${VLO_DOCKER_CONFIG_MAPPING_RULES_FILE}"

	filter_file ${CATALINA_BASE}/conf/Catalina/localhost/ROOT.xml \
		VLO_DOCKER_CONFIG_FILE \
		VLO_DOCKER_WICKET_CONFIGURATION \
		VLO_DOCKER_WICKET_BOTTOM_SNIPPET_URL \
		VLO_DOCKER_PIWIK_ENABLE_TRACKER \
		VLO_DOCKER_PIWIK_SITE_ID \
		VLO_DOCKER_PIWIK_HOST \
		VLO_DOCKER_PIWIK_DOMAINS

	# Tomcat env
	filter_file ${CATALINA_BASE}/bin/setenv.sh \
		VLO_DOCKER_TOMCAT_JAVA_OPTS
	
	# Importer
	filter_file /opt/importer.sh \
		VLO_DOCKER_IMPORTER_JAVA_OPTS

	# Update mapping definitions
	if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
		cd "$VLO_MAPPING_DEFINITIONS_DIR" && \
		curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
	else
		echo "Not retrieving VLO mapping definitions!"
	fi

	if [ "${VLO_DOCKER_SKIP_WAIT_FOR_SOLR}" = 'true' ]; then
		echo "NOT waiting for Solr (VLO_DOCKER_SKIP_WAIT_FOR_SOLR=${VLO_DOCKER_SKIP_WAIT_FOR_SOLR})"
	else
		wait_for_solr
	fi
}

wait_for_solr() {
	if ! [ "${VLO_DOCKER_SOLR_URL}" ]; then
		echo "FATAL: Solr URL not configured"
		exit 1
	fi
	
	HOST_PORT="$(echo "${VLO_DOCKER_SOLR_URL}" | sed -E 's_https?://([^/:]+:[0-9]+).*_\1_g')"
	echo "Checking/waiting for Solr service at ${HOST_PORT} (extracted from ${VLO_DOCKER_SOLR_URL}). Timeout: ${SOLR_PORT_WAIT_TIMEOUT}s"
	wait-for "${HOST_PORT}"  -t "${SOLR_PORT_WAIT_TIMEOUT}"
	
	SOLR_TEST_URL="${VLO_DOCKER_SOLR_URL}${SOLR_CHECK_PATH}"
	echo "Checking/wating for Solr response at ${SOLR_TEST_URL} (user: ${VLO_DOCKER_SOLR_USER_READ_ONLY})"
	while ! curl -lfs -u "${VLO_DOCKER_SOLR_USER_READ_ONLY}:${VLO_DOCKER_SOLR_PASSWORD_READ_ONLY}" "${SOLR_TEST_URL}" > /dev/null 2>&1; do
		echo "REST not available (yet). Exit code: $?"
		sleep "${SOLR_CHECK_INTERVAL}"
	done
	
	echo "Confirmed availability of REST service at ${SOLR_TEST_URL}"
}

filter_file() {
	TARGET_FILE=$1
	shift
	if [ -e "$TARGET_FILE" ]; then
		for PROP in $@; do
			PROP_VALUE="$(eval echo \"\${${PROP}}\")"
			replaceVarInFile "${PROP}" "${PROP_VALUE}" "${TARGET_FILE}"
		done
	else
		echo "ERROR: file not found, cannot filter: $TARGET_FILE"
		exit 1
	fi
}

filter_xml_file() {
	TARGET_FILE=$1
	RULES_FILE=$2
	
	if [ -e "$TARGET_FILE" ] && [ -e "$RULES_FILE" ] ; then
		/bin/bash "/opt/filter-properties-to-xml.sh" "${TARGET_FILE}" < "$RULES_FILE"
	else
		echo "ERROR: file not found, cannot filter: $TARGET_FILE"
		exit 1
	fi
}

main $@