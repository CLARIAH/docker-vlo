#!/bin/sh

/bin/bash /opt/filter-vlo-config.sh /opt/vlo/config/VloConfig.xml

#Update mapping definitions
cd /srv/VLO-mapping && \
curl -L "https://github.com/clarin-eric/VLO-mapping/archive/beta.tar.gz" | tar zxvf - --strip-components=1
