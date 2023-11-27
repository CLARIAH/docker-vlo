#!/usr/bin/env bash
# shellcheck source=copy_data.env.sh
source "${DATA_ENV_FILE:-copy_data.env.sh}"

VLO_DISTR_DIR="webapp/vlo"
VLO_DISTR_FILE="vlo-distr.$(date +%Y%m%d%H%M%S).tar.gz"

init_data () { 
	echo "Preparing to copy data for VLO image build"

	export INIT_DATA_BUILD_DIR="${PWD}"
	if [ -e "${VLO_DISTR_DIR}" ]; then
		cleanup_data
	fi

	(
		cd webapp || exit 1
		
		if [[ "${REMOTE_RELEASE_URL}" =~ ^file.* ]]; then
			# shellcheck disable=SC2001
			SRC_FILE="$(echo "${REMOTE_RELEASE_URL}" | sed 's/^file://')"
			echo "Copying data from ${SRC_FILE}"
			if ! [ -e "${SRC_FILE}" ]; then
				echo "FATAL: source file does not exist"
				exit 1
			fi
			cp "${SRC_FILE}" "${VLO_DISTR_FILE}"
		else		
		    echo -n "Fetching remote data from ${REMOTE_RELEASE_URL}... "
			wget -q -O "${VLO_DISTR_FILE}" "${REMOTE_RELEASE_URL}"
		fi
		
		tar -zxf "${VLO_DISTR_FILE}"
		(
			cd "${NAME}/war" || exit 1
			sh unpack-wars.sh > /dev/null
		)
		mv  "${NAME}" 'vlo' || exit 1
		rm "${VLO_DISTR_FILE}"
	)
}

cleanup_data () {
    if [ -d "${INIT_DATA_BUILD_DIR}/${VLO_DISTR_DIR}" ]; then
		echo "Cleaning up data"
	    rm -r "${INIT_DATA_BUILD_DIR:?}/${VLO_DISTR_DIR:?}"
    fi
}
