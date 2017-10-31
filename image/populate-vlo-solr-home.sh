#!/bin/sh
#
# This script provisions Solr home content to a mounted 'vlo-solr-home' volume.
#
# The purpose of this is to prepare a volume that can be used by a container started from
# a (vanilla) Solr image.
set -e

# Where the Solr home configuration can be found... (Source)
SORL_HOME_SOURCE_DIR="/opt/vlo/solr/vlo-solr-home"
# Where the Solr home configuration should be copied to... (Target)
SOLR_HOME_VOLUME_DIR="/srv/vlo-solr-home"

DO_POPULATE=0

if [ "${FORCE_POPULATE_VLO_SOLR_HOME}" = "true" ] || [ "$1" = "-f" ]
then
	echo "Force populating Solr home volume directory (${SOLR_HOME_VOLUME_DIR})"
	DO_POPULATE=1
else
	# If Solr home volume empty, populate with Solr home
	if ! [ -e "${SOLR_HOME_VOLUME_DIR}/solr.xml" ]
	then
		echo "Found no Solr home directory in volume (${SOLR_HOME_VOLUME_DIR}). Populating..."
		DO_POPULATE=1
	else
		echo "Found Solr home volume content in directory (${SOLR_HOME_VOLUME_DIR}). Not touching it!"
		DO_POPULATE=0
	fi
fi

if [ "$DO_POPULATE" -eq "1" ]
then
	cp -rv "$SORL_HOME_SOURCE_DIR"/* "${SOLR_HOME_VOLUME_DIR}"
fi
