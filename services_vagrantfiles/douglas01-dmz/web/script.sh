#!/bin/bash
ip route add 192.168.0.0/16 dev eth1 via 192.168.1.126 || true
set -e

mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh

if [ -f /tmp/ssh_key ]; then
  cat /tmp/ssh_key >> /home/vagrant/.ssh/authorized_keys
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
fi

apt update && apt install apache2 curl -y
mv /tmp/index.php /var/www/html/
rm /var/www/html/index.html
systemctl restart apache2

