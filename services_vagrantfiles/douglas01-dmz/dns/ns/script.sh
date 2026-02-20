#!/bin/bash
ip route add 192.168.0.0/16 dev eth1 via 192.168.1.126 || true
mkdir -p /home/vagrant
apt upgrade && apt update -y
apt install -y bind9
mv -f /tmp/dhcpupdate.key /etc/bind/
mv -f /tmp/named.conf.local /etc/bind/
mv -f /tmp/named.conf.options /etc/bind/
cp -a /tmp/db.blanc.iut /etc/bind/
cp -a /tmp/db.prive.blanc.iut /etc/bind/
cp -a /tmp/db.blanc.iut /var/cache/bind/
cp -a /tmp/db.prive.blanc.iut /var/cache/bind/
chown bind:bind /var/cache/bind/db.blanc.iut
chown bind:bind /var/cache/bind/db.prive.blanc.iut
chmod 640 /var/cache/bind/db.blanc.iut
chmod 640 /var/cache/bind/db.prive.blanc.iut
systemctl restart bind9

