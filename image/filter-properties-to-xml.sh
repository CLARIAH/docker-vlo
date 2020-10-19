#!/bin/bash

##########################################################################################
# This script filters an XML file using environment variables and a 'rules' file
# that maps environment variables to paths (jq/xq style). This requires yq to be 
# installed. If Python and Pip are available, you can install it using 'pip install yq'.
#
# Typical usage: 
#
#	bash filter-properties-to-xml.sh config.xml < rules.txt
#
# Example rule to fill /VloConfig/deleteAllFirst from ${VLO_DOCKER_DELETE_ALL_FIRST:
#
# 	VLO_DOCKER_DELETE_ALL_FIRST .VloConfig.deleteAllFirst
##########################################################################################

TARGET_XML="$1"
if ! [ -e "$1" ]; then
	echo "Usage: $0 <file>"
	exit 1
fi

if ! command -v xq > /dev/null; then
	echo "Error: xq not found. Try: pip install yq"
	exit 1
fi

main() {
	cp "${TARGET_XML}" "${TARGET_XML}.orig"

	while read -r RULE; do
		if [ "${RULE}" ]; then
			read -ra RULEA <<< "$RULE"
			PROP="${RULEA[0]}"
			XQ_PATH="${RULEA[1]}"

			if [ "${PROP}" ] && [ "${XQ_PATH}" ]; then
				# shellcheck disable=SC2086
				PROP_VALUE="$(eval echo \"\$\{${PROP}\}\")"
				
				if [ "${PROP_VALUE}" ]; then
					echo "Setting value for ${PROP} in ${TARGET_XML}:${XQ_PATH}"
					XQ_COMMAND='.|('"${XQ_PATH}"'|="'"${PROP_VALUE}"'")'

					log_debug "Prop: ${PROP} - Path: ${XQ_PATH} - Command: ${XQ_COMMAND}"
			
					cp "${TARGET_XML}" "${TARGET_XML}.temp"
					xq --xml-output "${XQ_COMMAND}" <"${TARGET_XML}.temp" > "${TARGET_XML}"
				else
					echo "Not setting ${TARGET_XML}:${XQ_PATH} (no value found for ${PROP})"
				fi
			
			else
				echo "Warning: ignoring invalid rule '${RULE}'"
			fi
		fi
	done

	if [ -e  "${TARGET_XML}.temp" ]; then
		rm -- "${TARGET_XML}.temp"
	fi
}

log_debug() {
	if [ "${DEBUG}" = "true" ]; then
		echo "[DEBUG]" "$@"
	fi
}

main "$@"