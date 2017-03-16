#!/bin/bash

REMOTE_RELEASE_URL="https://github.com/clarin-eric/VLO/releases/download/vlo-4.1.0-beta1/vlo-4.1.0-beta1-Distribution.tar.gz"
NAME="vlo-4.1.0-beta1"

init_data () {
    LOCAL=0
    if [ "$1" == "local" ]; then
        LOCAL=1
    fi

#    if [ "${LOCAL}" -eq 0 ]; then
    echo -n "Fetching remote data"
    cd webapp
    curl -s -S -J -L -O "${REMOTE_RELEASE_URL}"
    tar -xf *.tar.gz
    cd ${NAME}/war
    sh unpack-wars.sh > /dev/null
    cd ../..
    cp VloConfig.xml ${NAME}/config
    mv  ${NAME} vlo
    cd ..
    echo $(pwd)

#   else
#   fi
}

cleanup_data () {
    if [ -f "webapp/vlo-4.1.0-beta1-Distribution.tar.gz" ]; then
        rm "webapp/vlo-4.1.0-beta1-Distribution.tar.gz"
    fi
    if [ -d "webapp/vlo" ]; then
	    rm -r webapp/vlo
    fi
}