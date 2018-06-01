#!/usr/bin/env bash
if [ -n "${VLO_DOCKER_RATING_COUCHDB_URL}" ]; then
	curl -u ${VLO_DOCKER_RATING_COUCHDB_USER}:${VLO_DOCKER_RATING_COUCHDB_PASSWORD} \
		-X POST \
		${VLO_DOCKER_RATING_COUCHDB_URL}/_find \
		-d '{"selector": {}}' \
		-H "Content-Type: application/json"
else
	echo "VLO_DOCKER_RATING_COUCHDB_URL not set"
	exit 1
fi
