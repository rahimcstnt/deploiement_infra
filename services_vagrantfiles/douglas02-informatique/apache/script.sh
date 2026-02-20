#!/bin/bash
ip route add 192.168.0.0/16 dev eth1 via 192.168.1.30 || true
apt-get update
apt-get install -y apache2

a2enmod proxy proxy_http proxy_connect

mv /tmp/forward-proxy.conf /etc/apache2/sites-available/

a2ensite forward-proxy.conf
a2dissite 000-default.conf
systemctl reload apache2
