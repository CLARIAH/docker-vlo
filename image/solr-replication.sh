#!/bin/sh

# Script to export a Solr index
#
# Requires 'jq', see <https://stedolan.github.io/jq>
#
# Parameters:
#   name: Name to be used for the export, must not already exist
# Environment variables:
#   SOLR_EXPORT_URL: Base URL of Solr index (e.g. http://localhost:8983/solr/my-index/)
#   SOLR_EXPORT_DIR: Target parent directory of export ON THE SOLR HOST

function main() {
	check_vars
	check_jq
	check_params $@

	start
	echo "Started. Waiting for completion..."
	wait_for_completion
	
	exit 0
}

function start() {
	OUTPUT="${TMPDIR}/solr-export-$(date +'%s').out"
	if [ "EXPORT" = "$MODE" ]; then
		echo "Starting export..."
		curl -s "${REPLICATION_BASE_URL}?command=backup&location=${SOLR_EXPORT_DIR}&name=${NAME}" > $OUTPUT
	elif [ "IMPORT" = "$MODE" ]; then
		echo "Starting import..."
		curl -s "${REPLICATION_BASE_URL}?command=restore&location=${SOLR_EXPORT_DIR}&name=${NAME}" > $OUTPUT
	fi

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
	if [ "EXPORT" = "$MODE" ]; then
		wait_for_export_completion
	elif [ "IMPORT" = "$MODE" ]; then
		wait_for_import_completion
	fi
}

function wait_for_export_completion() {
	OUTPUT="${TMPDIR}/solr-export-$(date +'%s').out"
	
	DONE=0
	while [ $DONE -eq 0 ]
	do
		curl -s "${REPLICATION_BASE_URL}?command=details" > $OUTPUT
		SUCCESS=$(jq '(.details|has("backup")) and (.details.backup|contains(["success"]))' < $OUTPUT)
		FAILED=$(jq '(.details|has("backup")) and (.details.backup|contains(["failed"]))' < $OUTPUT)
		HAS_EXCEPTION=$(jq '(.details|has("backup")) and (.details.backup|contains(["exception"]))' < $OUTPUT)
		
		if [ "true" = "$SUCCESS" ] && [ "false" = "$HAS_EXCEPTION" ]; then
			DONE=1
		else
			if [ "false" = "$FAILED" ] && [ "false" = "$HAS_EXCEPTION" ]
			then
				echo "Waiting... Details: $(jq '.details.backup' < $OUTPUT)"
				sleep 2
			else
				echo "Failed to complete!"
				cat $OUTPUT
				rm $OUTPUT
				exit 102
			fi
		fi
	done

	echo "Done! Details: $(jq '.details.backup' < $OUTPUT)"
	rm $OUTPUT
}

function wait_for_import_completion() {
	OUTPUT="${TMPDIR}/solr-export-$(date +'%s').out"
	
	DONE=0
	while [ $DONE -eq 0 ]
	do
		curl -s "${REPLICATION_BASE_URL}?command=restorestatus" > $OUTPUT
		EXCEPTION="$(jq -r '.restorestatus.exception' < $OUTPUT)"
		STATUS="$(jq -r '.restorestatus.status' < $OUTPUT)"		

		if [ "success" = "$STATUS" ]; then
			DONE=1
		else
			if [ null = "$EXCEPTION" ]; then
				echo "Waiting... Details: $(jq '.restorestatus' < $OUTPUT)"
				sleep 2
			else
				echo "Failed to complete!"
				cat $OUTPUT
				rm $OUTPUT
				exit 102
			fi
		fi
	done

	echo "Done! Details: $(jq '.restorestatus' < $OUTPUT)"
	rm $OUTPUT
}

function check_vars() {
	if [ -z "${SOLR_EXPORT_URL}" ] || [ -z "${SOLR_EXPORT_DIR}" ]
	then
		echo "One or more of the required variables not set: SOLR_EXPORT_URL, SOLR_EXPORT_DIR"
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
	export MODE_OPT=$1
	export NAME=$2
	
	if [ -z "${NAME}" ]
	then
		usage
		exit 3
	fi
	
	if [ "--export" = "$MODE_OPT" ]; then
		export MODE="EXPORT"
	elif [ "--import" = "$MODE_OPT" ]; then
		export MODE="IMPORT"
	else
		usage
		exit 3
	fi
}

usage() {
	echo "Make an export of the Solr index"
	echo ""
	echo "Usage:"
	echo "  $0 --export|--import NAME"
	echo ""
	echo "Options:"
	echo "  --export:   Export data"
	echo "  --import:   Import data"
	echo ""
	echo "Parameters:"
	echo "  NAME        Name to be used for the export, must not already exist"
}

main $@


