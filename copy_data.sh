#!/usr/bin/env bash
source "${DATA_ENV_FILE:-copy_data.env.sh}"

VLO_DISTR_DIR="webapp/vlo"
VLO_DISTR_FILE="vlo-distr.$(date +%Y%m%d%H%M%S).tar.gz"

init_data () { 
	export INIT_DATA_BUILD_DIR="${PWD}"
	if [ -e "${VLO_DISTR_DIR}" ]; then
		cleanup_data
	fi

#     LOCAL=0
#     if [ "$1" == "local" ]; then
#         LOCAL=1
#     fi

    echo -n "Fetching remote data from ${REMOTE_RELEASE_URL}... "
    (
		cd webapp
		wget -q -O "${VLO_DISTR_FILE}" "${REMOTE_RELEASE_URL}"
		tar -zxf "${VLO_DISTR_FILE}"
		(
			cd "${NAME}/war"
			sh unpack-wars.sh > /dev/null
		)
   		mv  "${NAME}" 'vlo'
   		rm "${VLO_DISTR_FILE}"
	)
}

cleanup_data () {
    if [ -d "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_DIR}" ]; then
		echo "Cleaning up data"
	    rm -r "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_DIR}"
    fi
}
