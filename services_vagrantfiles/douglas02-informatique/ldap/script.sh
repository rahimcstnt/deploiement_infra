#!/bin/bash

ip route add 192.168.0.0/16 dev eth1 via 192.168.1.30 || true
sudo apt update && sudo apt-get install -y slapd ldap-utils

mkdir -p /root/ldap/blanc
cd /root/ldap/blanc
cp /vagrant/ldap/*.ldif /root/ldap/blanc/ | echo bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
sudo ldapadd -x -D cn=admin,dc=blanc,dc=iut -W -f /root/ldap/blanc/base.ldif | echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
sudo ldapadd -x -D cn=admin,dc=blanc,dc=iut -W -f /root/ldap/blanc/groups.ldif | echo groups
sudo ldapadd -x -D cn=admin,dc=blanc,dc=iut -W -f /root/ldap/blanc/user.ldif | echo user
sudo ldapadd -x -D cn=admin,dc=blanc,dc=iut -W -f /root/ldap/blanc/addintogroups.ldif | echo add

