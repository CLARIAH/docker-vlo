#!/bin/bash

# Context fragment location
CONTEXT_FILE=$1

if [ -z "$CONTEXT_FILE" ]
then
	echo "Please provide the location of the VLO context fragment file"
	exit 1
fi

if [ ! -f "$CONTEXT_FILE" ]
then
	echo "$CONTEXT_FILE: file not found"
	exit 1
fi

SED_COMMAND=""

for v in VLO_DOCKER_CONFIG_FILE \
		VLO_DOCKER_PIWIK_ENABLE_TRACKER \
		VLO_DOCKER_PIWIK_SITE_ID \
		VLO_DOCKER_PIWIK_HOST \
		VLO_DOCKER_PIWIK_DOMAINS
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

echo "Substituting placeholder values in ${CONTEXT_FILE}"

sed -i -e $SED_COMMAND $CONTEXT_FILE
