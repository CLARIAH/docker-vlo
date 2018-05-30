#!/usr/bin/env bash
set -e

AUTH=":"
if [ -n "$VLO_DOCKER_RATING_COUCHDB_USER" ]; then
	AUTH="$VLO_DOCKER_RATING_COUCHDB_USER"
	if [ -n "$VLO_DOCKER_RATING_COUCHDB_PASSWORD" ]; then
		AUTH="${AUTH}:$VLO_DOCKER_RATING_COUCHDB_PASSWORD"
	fi
fi

function waitForServer {
	ATTEMPTS=60
	SLEEP_INTERVAL=2
	COUNT=0

	echo "Checking CouchDB connection at $VLO_DOCKER_RATING_COUCHDB_URL"
	while ! curl -u ${AUTH} --output /dev/null --silent --head --fail "$VLO_DOCKER_RATING_COUCHDB_URL/.."; do
		if [ $((++COUNT)) -ge ${ATTEMPTS} ]; then
			echo "Giving up trying to connect to CouchDB after ${ATTEMPTS} attempts"
			exit 1
		fi
		echo "Waiting for CouchDB... (${COUNT}/${ATTEMPTS})"
		sleep $SLEEP_INTERVAL
	done
}

function initServer {
	createResourceIfDoesNotExist "$VLO_DOCKER_RATING_COUCHDB_URL"/../_users
	createResourceIfDoesNotExist "$VLO_DOCKER_RATING_COUCHDB_URL"/../_replicator
	createResourceIfDoesNotExist "$VLO_DOCKER_RATING_COUCHDB_URL"/../_global_changes
	createResourceIfDoesNotExist "$VLO_DOCKER_RATING_COUCHDB_URL"
}

function createResourceIfDoesNotExist {
	URL=$1
	if curl -u ${AUTH} --output /dev/null --silent --head --fail "$URL"; then
		echo "Resource $URL found, will not touch"
	else
		echo "Creating resource $URL"
		curl -u ${AUTH} --output /dev/null --silent -X PUT "$URL"
	fi
}

function main {
	if [ "$VLO_DOCKER_RATING_COUCHDB_INIT" != "true" ]; then
		echo "Not initialising CouchDB (set VLO_DOCKER_RATING_COUCHDB_INIT to 'true' if you do want this)"
		exit 0
	fi
	
	if [ -n "$VLO_DOCKER_RATING_COUCHDB_URL" ]; then
		waitForServer
		initServer
	else
		echo "VLO_DOCKER_RATING_COUCHDB_URL not set, cannot initialise"
		exit 1
	fi
}

main