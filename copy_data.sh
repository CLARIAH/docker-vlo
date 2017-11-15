#!/bin/bash
VLO_VERSION=4.3.0-alpha5
REMOTE_RELEASE_URL="https://github.com/clarin-eric/VLO/releases/download/vlo-${VLO_VERSION}/vlo-${VLO_VERSION}-docker.tar.gz"
NAME="vlo-${VLO_VERSION}-docker"

init_data () {
    LOCAL=0
    if [ "$1" == "local" ]; then
        LOCAL=1
    fi

#    if [ "${LOCAL}" -eq 0 ]; then
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

#   else
#   fi
}

cleanup_data () {
    if [ -f "webapp/vlo-${VLO_VERSION}-docker.tar.gz" ]; then
        rm "webapp/vlo-${VLO_VERSION}-docker.tar.gz"
    fi
    if [ -d "webapp/vlo" ]; then
	    rm -r webapp/vlo
    fi
}