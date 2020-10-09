#!/bin/bash
TEST_URL="${VLO_DOCKER_SOLR_URL}select?rows=0"
curl -s \
	--fail \
	--user "${VLO_DOCKER_SOLR_USER_READ_WRITE}:${VLO_DOCKER_SOLR_PASSWORD_READ_WRITE}" \
	"${TEST_URL}" > /dev/null \
	|| (echo "Could not reach Solr at ${TEST_URL}" && exit 1)
