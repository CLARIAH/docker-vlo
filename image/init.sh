#!/bin/sh
set -e

# Filter VLO configuration
/bin/bash /opt/filter-vlo-config.sh ${VLO_DOCKER_CONFIG_FILE}
/bin/bash /opt/filter-vlo-context.sh /srv/tomcat8/conf/Catalina/localhost/ROOT.xml

# Update mapping definitions
if [ ! -z "${VLO_MAPPING_DEFINITIONS_DIST_URL}" ]; then
	cd "$VLO_MAPPING_DEFINITIONS_DIR" && \
	curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
else
	echo "Not retrieving VLO mapping definitions!"
fi
