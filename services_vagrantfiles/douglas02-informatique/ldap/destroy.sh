#!/bin/bash
set -e

echo "=== ARRÊT DE SLAPD ==="
sudo systemctl stop slapd

echo "=== SUPPRESSION DES DONNÉES LDAP (MDB) ==="
sudo rm -rf /var/lib/ldap/*

echo "=== SUPPRESSION DE LA CONFIG DE LA BASE ==="
sudo rm -f /etc/ldap/slapd.d/cn=config/olcDatabase\=\{1\}mdb.ldif

echo "=== REDÉMARRAGE DE SLAPD ==="
sudo systemctl start slapd

sleep 2

echo "=== VÉRIFICATION ==="
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(olcDatabase=*)" || true

echo "✅ Base LDAP SUPPRIMÉE — prête pour un script de création"


