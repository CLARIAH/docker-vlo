#!/usr/bin/env bash
source "${ENV_FILE:-copy_data.env.sh}"

init_data () { 
	export INIT_DATA_BUILD_DIR="${PWD}"
	if [ -e "${VLO_DISTR_FILE}" ] || [ -e "${VLO_DISTR_DIR}" ]; then
		cleanup_data
	fi

#     LOCAL=0
#     if [ "$1" == "local" ]; then
#         LOCAL=1
#     fi

    echo -n "Fetching remote data from ${REMOTE_RELEASE_URL}... "
    cd webapp
    curl -s -S -J -L -O "${REMOTE_RELEASE_URL}"
    tar -zxf *.tar.gz
    cd ${NAME}/war
    sh unpack-wars.sh > /dev/null
    cd ../..
    mv  ${NAME} vlo
    cd ..
    echo $(pwd)
}

cleanup_data () {
	echo "Cleaning up data"
    if [ -f "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_FILE}" ]; then
        rm "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_FILE}"
    fi
    if [ -d "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_DIR}" ]; then
	    rm -r "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_DIR}"
    fi
}
