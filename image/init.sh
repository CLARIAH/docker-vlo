#!/bin/sh
set -e

# Filter VLO configuration
/bin/bash /opt/filter-config-file.sh ${VLO_DOCKER_CONFIG_FILE} \
	VLO_DOCKER_SOLR_URL \
	VLO_DOCKER_PUBLIC_HOME_URL \
	VLO_DOCKER_MAPPING_BASE_URI \
	VLO_DOCKER_FILE_PROCESSING_THREADS \
	VLO_DOCKER_SOLR_THREADS \
	VLO_DOCKER_DELETE_ALL_FIRST \
	VLO_DOCKER_MAX_DAYS_IN_SOLR \
	VLO_DOCKER_DATAROOTS_FILE

/bin/bash /opt/filter-config-file.sh /srv/tomcat8/conf/Catalina/localhost/ROOT.xml \
	VLO_DOCKER_CONFIG_FILE \
	VLO_DOCKER_PIWIK_ENABLE_TRACKER \
	VLO_DOCKER_PIWIK_SITE_ID \
	VLO_DOCKER_PIWIK_HOST \
	VLO_DOCKER_PIWIK_DOMAINS \
	VLO_DOCKER_WICKET_CONFIGURATION

# Update mapping definitions
if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "$VLO_MAPPING_DEFINITIONS_DIR" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving VLO mapping definitions!"
fi
