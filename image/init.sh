#!/bin/sh

SOLR_DATA=${_SOLR_DATA:-"/opt/solr-data"}
VLO_DOCKER_SOLR_URL=${_VLO_DOCKER_SOLR_URL:-"http://localhost:8080/solr/core0/"}
VLO_DOCKER_PUBLIC_HOME_URL=${_VLO_DOCKER_PUBLIC_HOME_URL:-"http://localhost"}
VLO_DOCKER_MAPPING_BASE_URI=${_VLO_DOCKER_MAPPING_BASE_URI:-"file:/srv/VLO-mapping/"}
VLO_DOCKER_FILE_PROCESSING_THREADS=${_VLO_DOCKER_FILE_PROCESSING_THREADS:-"-1"}
VLO_DOCKER_SOLR_THREADS=${_VLO_DOCKER_SOLR_THREADS:-"4"}

export "VLO_DOCKER_SOLR_URL=${VLO_DOCKER_SOLR_URL}"
export "VLO_DOCKER_PUBLIC_HOME_URL=${VLO_DOCKER_PUBLIC_HOME_URL}"
export "VLO_DOCKER_MAPPING_BASE_URI=${VLO_DOCKER_MAPPING_BASE_URI}"
export "VLO_DOCKER_FILE_PROCESSING_THREADS=${VLO_DOCKER_FILE_PROCESSING_THREADS}"
export "VLO_DOCKER_SOLR_THREADS=${VLO_DOCKER_SOLR_THREADS}"

/bin/bash /opt/filter-vlo-config.sh /opt/vlo/config/VloConfig.xml

#Update mapping definitions
cd /srv/VLO-mapping/ && \
curl -L "https://github.com/clarin-eric/VLO-mapping/archive/beta.tar.gz" | tar zxvf - --strip-components=1
