# INSTALLATION

sudo apt install slapd
(mot de passe revaz)

# CREATION DE LA BASE
```
sudo systemctl stop slapd
sudo rm -rf /etc/ldap/slapd.d/*
sudo rm -rf /var/lib/ldap/*
sudo dpkg-reconfigure slapd
ldapsearch -x -LLL -b dc=blanc,dc=iut
```
il doit s'afficher

# 
