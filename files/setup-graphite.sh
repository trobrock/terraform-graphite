#!/usr/bin/env bash

add_attachment() {
  volume_name="$1"
  mount_point="$2"

  while ! (lsblk | grep $volume_name) ; do
    sleep 1 # Wait for the volume to be attached
  done
  mkdir -p $mount_point
  if ! (file -s /dev/$volume_name | grep -i 'xfs' > /dev/null); then
    mkfs -t xfs /dev/$volume_name
  fi
  uuid=$(lsblk -o +UUID | awk "/$volume_name/{ print \$7 }")
  echo "UUID=$uuid  $mount_point xfs defaults,nofail 0 2" >> /etc/fstab
}

set -e

# Attach external volumes
add_attachment ${graphite_web_data_volume} /var/lib/graphite-web
add_attachment ${grafana_data_volume} /var/lib/grafana
add_attachment ${carbon_data_volume} /var/lib/carbon

mount -a

# Install graphite
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y python-whisper python-carbon graphite-web

pushd /usr/lib/python2.7/site-packages/graphite
echo '${graphite_web_config_content}' > local_settings.py
django-admin syncdb --settings=graphite.settings --noinput
chown -R apache:apache /var/lib/graphite-web
chown -R apache:apache /usr/share/graphite/webapp/content/
popd

mv /etc/httpd/conf.d/welcome.conf{,.backup}
echo "${apache_config_content}" > /etc/httpd/conf.d/graphite-web.conf
chkconfig httpd on
systemctl start httpd

echo '${carbon_storage_schemas_content}' > /etc/carbon/storage-schemas.conf
echo '${carbon_storage_aggregations_content}' > /etc/carbon/storage-aggregation.conf

curl -L https://raw.githubusercontent.com/graphite-project/carbon/master/distro/redhat/init.d/carbon-cache > /etc/init.d/carbon-cache
chmod 0755 /etc/init.d/carbon-cache
systemctl enable carbon-cache
systemctl start carbon-cache

curl -L https://raw.githubusercontent.com/graphite-project/carbon/master/distro/redhat/init.d/carbon-aggregator > /etc/init.d/carbon-aggregator
chmod 0755 /etc/init.d/carbon-aggregator
systemctl enable carbon-aggregator
systemctl start carbon-aggregator

# curl -L https://raw.githubusercontent.com/graphite-project/carbon/master/distro/redhat/init.d/carbon-relay > /etc/init.d/carbon-relay
# chmod 0755 /etc/init.d/carbon-relay
# chkconfig carbon-relay on
# systemctl start carbon-relay

# Install statsd
yum install -y nodejs npm git
cd /opt
git clone git://github.com/etsy/statsd.git
cd statsd
echo '${statsd_config_content}' > /opt/statsd/local.js

wget -O /etc/init.d/statsd https://gist.githubusercontent.com/kaa/3652720/raw/4481532f7c4ffaeb207202ab591b9a5e47ed0320/statsd.init.sh
chmod 0755 /etc/init.d/statsd
chkconfig --add statsd
systemctl start statsd

# Install Grafana
wget https://dl.grafana.com/oss/release/grafana-6.6.2-1.x86_64.rpm
yum localinstall -y grafana-6.6.2-1.x86_64.rpm
rm grafana-6.6.2-1.x86_64.rpm
echo "${grafana_config_content}" > /etc/grafana/grafana.ini
echo "${grafana_datasources_content}" > /etc/grafana/provisioning/datasources/datasources.yaml
systemctl enable grafana-server.service
systemctl start grafana-server.service

# Install Collectd
yum install -y collectd collectd-
echo '${collectd_config_content}' > /etc/collectd.d/graphite.conf
systemctl enable collectd
systemctl start collectd
