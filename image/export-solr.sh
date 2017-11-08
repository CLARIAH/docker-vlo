#!/bin/sh

# Script to export a Solr index
#
# Requires 'jq', see <https://stedolan.github.io/jq>
#
# Parameters:
#   name: Name to be used for the export, must not already exist
# Environment variables:
#   SOLR_EXPORT_URL: Base URL of Solr index (e.g. http://localhost:8983/solr/my-index/)
#   SOLR_EXPORT_DEST: Target parent directory of export

function main() {
	check_vars
	check_jq
	check_params $@

	start_export
	echo "Export started. Waiting for completion..."
	wait_for_completion
	
	exit 0
}

function start_export() {
	OUTPUT="${TMPDIR}/solr-export-$(date +'%s').out"
	curl -s "${REPLICATION_BASE_URL}?command=backup&location=${SOLR_EXPORT_DEST}&name=${NAME}" > $OUTPUT

	EXCEPTION="$(jq -r '.exception' < $OUTPUT)"
	STATUS="$(jq -r '.status' < $OUTPUT)"
	rm $OUTPUT
	
	if ! [ null = "$EXCEPTION" ]
	then
		echo "Exception while starting: $EXCEPTION"
		exit 100
	fi
	
	if ! [ "OK" = "$STATUS" ]
	then
		echo "Status: $STATUS"
		exit 101
	fi
}

function wait_for_completion() {
	OUTPUT="${TMPDIR}/solr-export-$(date +'%s').out"
	
	DONE=0
	while [ $DONE -eq 0 ]
	do
		curl -s "${REPLICATION_BASE_URL}?command=details" > $OUTPUT
		SUCCESS=$(jq '(.details|has("backup")) and (.details.backup|contains(["success"]))' < $OUTPUT)
		HAS_EXCEPTION=$(jq '(.details|has("backup")) and (.details.backup|contains(["exception"]))' < $OUTPUT)
		
		if [ "true" = "$SUCCESS" ] && [ "false" = "$HAS_EXCEPTION" ]
		then
			DONE=1
		else
			if ! [ "false" = "$HAS_EXCEPTION" ]
			then
				echo "Exception while waiting for completion: $EXCEPTION"
				cat $OUTPUT
				rm $OUTPUT
				exit 102
			else
				echo "Waiting... Details: $(jq '.details.backup' < $OUTPUT)"
				sleep 2
			fi
		fi
	done

	echo "Done! Details: $(jq '.details.backup' < $OUTPUT)"
	rm $OUTPUT
}

function check_vars() {
	if [ -z "${SOLR_EXPORT_URL}" ] || [ -z "${SOLR_EXPORT_DEST}" ]
	then
		echo "One or more of the required variables not set: SOLR_EXPORT_URL, SOLR_EXPORT_DEST"
		exit 1
	fi
	
	REPLICATION_BASE_URL="${SOLR_EXPORT_URL}replication"
}

function check_jq() {
	if ! which jq > /dev/null
	then
		echo "Could not find jq. Please install before running this script!"
		exit 2
	fi
}

function check_params() {
	export NAME=$1
	if [ -z "${NAME}" ]
	then
		usage
		exit 3
	fi
}

usage() {
	echo "Make an export of the Solr index"
	echo ""
	echo "Usage:"
	echo "  $0 name"
	echo ""
	echo "Parameters:"
	echo "  name        Name to be used for the export, must not already exist"
}

main $@


