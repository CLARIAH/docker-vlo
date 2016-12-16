#!/bin/sh
sed -i "s/localhost/172\.17\.0\.1/g" /opt/vlo/config/VloConfig.xml

if [ ! -z ${STATSD_PREFIX} ]; then
    echo "Adjusting with statsd prefix (${STATSD_PREFIX}) override"
    sed -i "s/report\.statsd\.prefix\=vlo\.test/report\.statsd\.prefix\=${STATSD_PREFIX}/g" /opt/vlo/bin/statistics/config.properties
fi

#Run importer
touch /opt/vlo/log/vlo-importer.log
ln -sf /dev/stdout /opt/vlo/log/vlo-importer.log
cd /opt/vlo/bin/ && \
sh vlo_solr_importer.sh

#Generate statistics
cd /opt/vlo/bin/statistics/ && \
sh start.sh /opt/vlo/bin/statistics/config.properties

#Generate sitemap
cd /opt/vlo/bin/sitemap-generator/ && \
sh start.sh


