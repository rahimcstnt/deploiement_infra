#!/bin/bash
ip route add 192.168.0.0/16 dev eth1 via 192.168.1.126 
set -e

mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh

if [ -f /tmp/ssh_key ]; then
  cat /tmp/ssh_key >> /home/vagrant/.ssh/authorized_keys
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
fi
export DEBIAN_FRONTEND=noninteractive


cat <<EOF | debconf-set-selections
roundcube-core roundcube/dbconfig-install boolean true
roundcube-core roundcube/database-type select sqlite
roundcube-core roundcube/install-error select abort
roundcube-core roundcube/purge boolean false
roundcube-core roundcube/upgrade-error select abort
EOF

apt update && apt install roundcube sqlite3 roundcube-plugins roundcube-sqlite3 dovecot-core dovecot-imapd apache2 postfix -y

mv /tmp/dovecot.conf  /etc/dovecot/
mv /tmp/main.cf  /etc/postfix/
mv /tmp/roundcube.conf /etc/apache2/conf-available/
mv /tmp/config.inc.php  /etc/roundcube/
cp -a /etc/resolv.conf /var/spool/postfix/etc/
systemctl restart apache2
systemctl restart dovecot
useradd -m -s /bin/false rahim && echo "rahim:rahim" | chpasswd
useradd -m -s /bin/false useradmin1 && echo "useradmin1:useradmin1" | chpasswd
useradd -m -s /bin/false useradmin2 && echo "useradmin2:useradmin2" | chpasswd
useradd -m -s /bin/false userprod1 && echo "userprod1:userprod1" | chpasswd
useradd -m -s /bin/false userprod2 && echo "userprod1:userprod2" | chpasswd
useradd -m -s /bin/false userinfo && echo "userinfo:userinfo" | chpasswd

