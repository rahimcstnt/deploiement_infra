#!/bin/bash
ip route add 192.168.0.0/16 dev eth1 via 192.168.1.30 || true
set -e

apt update && apt-get install -y ansible nfs-kernel-server


mkdir -p /home/vagrant/.ssh
mv /tmp/id_rsa /home/vagrant/.ssh/id_rsa
mv /tmp/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub


chown vagrant:vagrant /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/id_rsa.pub
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub



