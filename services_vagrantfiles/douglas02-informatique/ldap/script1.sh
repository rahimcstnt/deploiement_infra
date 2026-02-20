#!/bin/bash
set -e


ip route add 192.168.0.0/16 dev eth1 via 192.168.1.30 2>/dev/null || true


echo "Préconfiguration de slapd..."

# Force le mode non-interactif globalement
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

debconf-set-selections <<EOF
slapd slapd/no_configuration boolean false
slapd slapd/domain string blanc.iut
slapd shared/organization string Equipe Blanc
slapd slapd/password1 password ldap
slapd slapd/password2 password ldap
slapd slapd/backend select MDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
EOF


echo "Installation de slapd et ldap-utils..."
apt update
apt install -y slapd ldap-utils


echo "Slapd installé avec préconfiguration debconf..."


sleep 3


echo "Détection de la base LDAP..."

DB_DN=$(ldapsearch -Y EXTERNAL -H ldapi:/// \
  -b cn=config '(objectClass=olcMdbConfig)' dn | grep '^dn:' | cut -d' ' -f2)

if [ -z "$DB_DN" ]; then
  echo "ERREUR: Base MDB introuvable"
  exit 1
fi

echo "Base trouvée : $DB_DN"


ldapmodify -Y EXTERNAL -H ldapi:/// <<EOF
dn: $DB_DN
changetype: modify
replace: olcSuffix
olcSuffix: dc=blanc,dc=iut
-
replace: olcRootDN
olcRootDN: cn=admin,dc=blanc,dc=iut
-
replace: olcRootPW
olcRootPW: {SSHA}BP4bpf/cRf/EGqafNd7ppsQIk6taTRhO
EOF


echo "Copie des fichiers LDIF..."
mkdir -p /root/ldap/blanc
cp /vagrant/ldap/*.ldif /root/ldap/blanc/
cd /root/ldap/blanc


echo "Création de dc=blanc,dc=iut..."

cat > create_base.ldif <<EOF
dn: dc=blanc,dc=iut
objectClass: top
objectClass: dcObject
objectClass: organization
dc: blanc
o: Equipe Blanc
EOF

ldapadd -x -D cn=admin,dc=blanc,dc=iut -w ldap -f create_base.ldif \
|| echo "Base déjà existante"


echo "Ajout des OU..."
ldapadd -x -D cn=admin,dc=blanc,dc=iut -w ldap -f base.ldif \
|| echo "OU déjà existantes"


echo "Ajout des groupes..."
ldapadd -x -D cn=admin,dc=blanc,dc=iut -w ldap -f groups.ldif \
|| echo "Groupes déjà existants"


echo "Ajout des utilisateurs..."
ldapadd -x -D cn=admin,dc=blanc,dc=iut -w ldap -f user.ldif \
|| echo "Utilisateurs déjà existants"


echo "Affectation aux groupes..."
ldapadd -x -D cn=admin,dc=blanc,dc=iut -w ldap -f addintogroups.ldif \
|| echo "Affectations déjà existantes"


echo "Vérification finale..."
ldapsearch -x -D cn=admin,dc=blanc,dc=iut -w ldap -b dc=blanc,dc=iut > /dev/null

echo "LDAP prêt et fonctionnel"
