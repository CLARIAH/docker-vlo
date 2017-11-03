#!/bin/sh
set -e

# Filter VLO configuration
/bin/bash /opt/filter-vlo-config.sh /opt/vlo/config/VloConfig.xml

# Update mapping definitions
cd "$VLO_MAPPING_DEFINITIONS_DIR" && \
curl -L "${VLO_MAPPING_DEFINITIONS_DIST_URL}" | tar zxvf - --strip-components=1
