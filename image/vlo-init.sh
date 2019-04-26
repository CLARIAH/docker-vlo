#!/bin/sh
set -e

filter_file() {
	TARGET_FILE=$1
	shift
	if [ -e "$TARGET_FILE" ]; then
		/bin/bash /opt/filter-config-file.sh  $TARGET_FILE $@
	else
		echo "ERROR: file not found, cannot filter: $TARGET_FILE"
		exit 1
	fi
}

# Filter VLO configuration
filter_file ${VLO_DOCKER_CONFIG_FILE} \
	VLO_DOCKER_SOLR_URL \
	VLO_DOCKER_SOLR_USER_READ_ONLY \
	VLO_DOCKER_SOLR_PASSWORD_READ_ONLY \
	VLO_DOCKER_SOLR_USER_READ_WRITE \
	VLO_DOCKER_SOLR_PASSWORD_READ_WRITE \
	VLO_DOCKER_PUBLIC_HOME_URL \
	VLO_DOCKER_MAPPING_BASE_URI \
	VLO_DOCKER_VALUE_MAPPING_URI \
	VLO_DOCKER_FILE_PROCESSING_THREADS \
	VLO_DOCKER_SOLR_THREADS \
	VLO_DOCKER_DELETE_ALL_FIRST \
	VLO_DOCKER_MAX_DAYS_IN_SOLR \
	VLO_DOCKER_DATAROOTS_FILE \
	VLO_DOCKER_VCR_MAXIMUM_ITEMS_COUNT \
	VLO_DOCKER_CONCEPT_REGISTRY_URL \
	VLO_DOCKER_VOCABULARY_REGISTRY_URL \
	VLO_DOCKER_FEEDBACK_FORM_URL \
	VLO_DOCKER_FCS_BASE_URL \
	VLO_DOCKER_LRS_BASE_URL \
	VLO_DOCKER_VCR_SUBMIT_ENDPOINT \
	VLO_DOCKER_LINK_CHECKER_MONGO_DB_NAME \
	VLO_DOCKER_LINK_CHECKER_MONGO_DB_CONNECTION_STRING

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

