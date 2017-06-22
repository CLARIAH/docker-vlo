#!/bin/sh
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

if [ -z "$VLO_DOCKER_SOLR_URL" ]
then
	echo "Error: VLO_DOCKER_SOLR_URL not set"
	exit 1
fi

if [ -z "$VLO_DOCKER_PUBLIC_HOME_URL" ]
then
	echo "Error: VLO_DOCKER_PUBLIC_HOME_URL not set"
	exit 1
fi

if [ -z "$VLO_DOCKER_MAPPING_BASE_URI" ]
then
	echo "Error: VLO_DOCKER_MAPPING_BASE_URI not set"
	exit 1
fi

echo "Substituting placeholder values in ${CONFIG}"

#VLO_DOCKER_SOLR_URL
echo "\${VLO_DOCKER_SOLR_URL} -> ${VLO_DOCKER_SOLR_URL}"
SED_COMMAND="s/\${VLO_DOCKER_SOLR_URL}/${VLO_DOCKER_SOLR_URL//\//\\/}/g;"

#VLO_DOCKER_PUBLIC_HOME_URL
echo "\${VLO_DOCKER_PUBLIC_HOME_URL} -> ${VLO_DOCKER_PUBLIC_HOME_URL}"
SED_COMMAND+="s/\${VLO_DOCKER_PUBLIC_HOME_URL}/${VLO_DOCKER_PUBLIC_HOME_URL//\//\\/}/g;"

#VLO_DOCKER_MAPPING_BASE_URI
echo "\${VLO_DOCKER_MAPPING_BASE_URI} -> ${VLO_DOCKER_MAPPING_BASE_URI}"
SED_COMMAND+="s/\${VLO_DOCKER_MAPPING_BASE_URI}/${VLO_DOCKER_MAPPING_BASE_URI//\//\\/}/g;"

sed -i -e $SED_COMMAND $CONFIG
