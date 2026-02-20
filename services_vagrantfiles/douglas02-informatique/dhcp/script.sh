#!/bin/bash

ip route add 192.168.0.0/16 dev eth1 via 192.168.1.30 || true
apt update && apt-get install -y isc-dhcp-server
cp -rf /tmp/isc-dhcp-server /etc/default/
cp -rf /tmp/dhcp/. /etc/dhcp

systemctl restart isc-dhcp-server


