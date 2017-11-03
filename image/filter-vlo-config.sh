#!/bin/bash

# VloConfig.xml location
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
	# ugly eval call to allow looping through options/environment variables and assigning default values if set
	val=$(eval echo \${${v}\})
	if [ -z "$val" ]
	then
		echo "Error: ${v} not set"
		exit 1
	fi
	echo "\${$v} -> ${val}"
	SED_COMMAND+="s/\${${v}}/${val//\//\\/}/g;"
done

echo "Substituting placeholder values in ${CONFIG}"

sed -i -e $SED_COMMAND $CONFIG
