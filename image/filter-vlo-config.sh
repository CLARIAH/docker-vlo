#!/bin/bash
CONFIG=$1

if [ -z "$CONFIG" ]
then
	echo "Please provide the location of the VLO configuration file"
	exit 1
fi

if [ ! -f "$CONFIG" ]
then
	echo "$CONFIG: configuration file not found"
	exit 1
fi

SED_COMMAND=""

for v in VLO_DOCKER_SOLR_URL \
		VLO_DOCKER_PUBLIC_HOME_URL \
		VLO_DOCKER_MAPPING_BASE_URI \
		VLO_DOCKER_FILE_PROCESSING_THREADS \
		VLO_DOCKER_SOLR_THREADS
do
	echo $v
	val=$(eval echo \${$v})
	if [ -z "$val" ]
	then
		echo "Error: ${v} not set"
		exit 1
	fi
	echo "\${VLO_DOCKER_SOLR_URL} -> ${val}"
	SED_COMMAND+="s/\${${v}}/${val//\//\\/}/g;"
done

echo "Substituting placeholder values in ${CONFIG}"

sed -i -e $SED_COMMAND $CONFIG
