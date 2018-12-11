#!/usr/bin/env sh
QUERY=$@
PASSWORD=`grep solrUserReadOnlyPass /opt/vlo/config/VloConfig.xml|sed -e 's/.*solrUserReadOnlyPass>\(.*\)<.solrUserReadOnlyPass.*/\1/'`
curl -u docker_user_read:${PASSWORD} "${VLO_DOCKER_SOLR_URL}select?${QUERY}"

