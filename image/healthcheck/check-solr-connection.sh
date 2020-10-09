#!/bin/bash
curl -s \
	--fail \
	--user "${VLO_DOCKER_SOLR_USER_READ_WRITE}:${VLO_DOCKER_SOLR_PASSWORD_READ_WRITE}" \
	"${VLO_DOCKER_SOLR_URL}select?rows=0" > /dev/null \
	|| exit 1
