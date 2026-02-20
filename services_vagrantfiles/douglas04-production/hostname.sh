#!/bin/bash
cat > /etc/hosts << EOF
# localhost OBLIGATOIRE (pour sudo)
127.0.0.1       localhost
127.0.1.1       $(hostname)

# Serveurs statiques 192.168.1.x
192.168.1.2     dhcp
192.168.1.4     nfs
192.168.1.5     rproxy
192.168.1.8     ldap
192.168.1.98    ns.blanc.iut          ns
192.168.1.100   mail.blanc.iut        mail
192.168.1.101   www.blanc.iut         web

# Clients dynamiques (DNS résout via BIND)
userinfo.prive.blanc.iut     userinfo
useradmin1.prive.blanc.iut  useradmin1
useradmin2.prive.blanc.iut  useradmin2
userprod.prive.blanc.iut    userprod

# IPv6 standard
::1     localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

