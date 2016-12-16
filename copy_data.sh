#!/bin/bash

REMOTE_RELEASE_URL="https://github.com/clarin-eric/VLO/releases/download/vlo-4.0.2-beta1/vlo-4.0.2-beta1-Distribution.tar.gz"
NAME="vlo-4.0.2-beta1"

init_data () {
    LOCAL=0
    if [ "$1" == "local" ]; then
        LOCAL=1
    fi

#    if [ "${LOCAL}" -eq 0 ]; then
    echo -n "Fetching remote data"
    cd webapp && \
    echo $(pwd) && \
    curl -s -S -J -L -O "${REMOTE_RELEASE_URL}" && \
    tar -xf *.tar.gz && \
    cd ${NAME}/war && \
    sh unpack-wars.sh > /dev/null && \
    cd ../.. && \
    cp VloConfig.xml ${NAME}/config && \
    cd ..
    echo $(pwd)

#   else
#   fi
}

cleanup_data () {
    cd image
    if [ -d "webapp/${NAME}" ]; then
	    echo "\tRemoving webapp/${NAME}*"
	    rm -r webapp/${NAME}*
    fi
    cd ..
}