
# Procédure d’installation et de configuration d’un serveur DHCP  
(Service : isc-dhcp-server)

Cette procédure décrit la configuration complète du service DHCP à partir des fichiers fournis :

- `/etc/default/isc-dhcp-server`
- `/etc/dhcp/dhcpd.conf`

---

# 1. Installation du service DHCP

Installation du paquet :

```bash
apt install isc-dhcp-server
```

Le service principal est :  
`isc-dhcp-server`

---

# 2. Configuration du service (fichier /etc/default/isc-dhcp-server)

Ce fichier définit les paramètres de démarrage du service.

## 2.1 Fichier de configuration utilisé

```bash
DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
```

Explication :  
Indique que le serveur DHCPv4 utilisera le fichier `/etc/dhcp/dhcpd.conf` comme configuration principale.

---

## 2.2 Interface réseau d’écoute

```bash
INTERFACESv4="eth1"
```

Explication :  
Le serveur DHCP écoute uniquement sur l’interface réseau `eth1`.

Cela signifie que :

- Les requêtes DHCP ne seront traitées que sur ce réseau.
- L’interface `eth1` doit être configurée avec une adresse IP statique appartenant au réseau distribué.

Exemple (configuration statique possible côté système) :

```
192.168.1.30/27
```

---

# 3. Configuration principale (fichier /etc/dhcp/dhcpd.conf)

---

# 3.1 Paramètres globaux des baux

```bash
default-lease-time 10;
max-lease-time 20;
```

Explication :

- `default-lease-time` : durée par défaut d’un bail DHCP (10 secondes).
- `max-lease-time` : durée maximale possible d’un bail (20 secondes).

Ces valeurs sont très courtes et adaptées à un environnement de test uniquement.

En production, on utilise généralement :
- 3600 secondes (1 heure)
- ou 86400 secondes (24 heures)

---

# 3.2 Mise à jour dynamique DNS (DDNS)

```bash
ddns-update-style interim;
update-static-leases on;
```

Explication :

- `ddns-update-style interim` : active les mises à jour dynamiques DNS selon le mode standard ISC.
- `update-static-leases on` : permet aussi la mise à jour DNS pour les baux statiques.

Cela signifie que le serveur DHCP met à jour automatiquement la zone DNS.

---

# 3.3 Clé de sécurisation des mises à jour DNS

```bash
key "dhcpupdate" {
    algorithm hmac-sha256;
    secret "oWMJyK8f2p62BCSHMVJAn55uW0pPPO58OV0ghxhi6qY=";
};
```

Explication :

- Définit une clé partagée entre le serveur DHCP et le serveur DNS.
- `algorithm hmac-sha256` : algorithme de signature.
- `secret` : clé secrète encodée en base64.

Cette clé garantit que seules les mises à jour autorisées sont acceptées par le DNS.

---

# 3.4 Déclaration de la zone DNS

```bash
zone prive.blanc.iut {
    primary 192.168.1.98;
    key dhcpupdate;
}
```

Explication :

- `zone prive.blanc.iut` : nom de la zone DNS mise à jour.
- `primary 192.168.1.98` : serveur DNS principal.
- `key dhcpupdate` : clé utilisée pour sécuriser les mises à jour.

Le serveur DNS se situe donc à l’adresse 192.168.1.98.

---

# 4. Configuration des sous-réseaux

Le réseau 192.168.1.0 est découpé en sous-réseaux de taille /27.

Rappel :

Masque 255.255.255.224 = /27  
Nombre d’adresses par sous-réseau : 32  
Nombre d’hôtes utilisables : 30  

---

## 4.1 Sous-réseau 192.168.1.0/27

```bash
subnet 192.168.1.0 netmask 255.255.255.224 {
    range 192.168.1.7 192.168.1.29;
    option routers 192.168.1.30;
    option domain-name "prive.blanc.iut";
    option domain-name-servers 192.168.1.98;
    option broadcast-address 192.168.1.31;
}
```

Explication :

- Plage distribuée : 192.168.1.7 à 192.168.1.29
- Passerelle : 192.168.1.30
- DNS : 192.168.1.98
- Broadcast : 192.168.1.31
- Domaine fourni aux clients : prive.blanc.iut

---

## 4.2 Sous-réseau 192.168.1.32/27

```bash
subnet 192.168.1.32 netmask 255.255.255.224 {
    range 192.168.1.34 192.168.1.61;
    option routers 192.168.1.62;
    option domain-name "prive.blanc.iut";
    option domain-name-servers 192.168.1.98;
    option broadcast-address 192.168.1.63;
}
```

Même principe :

- Plage : 34–61
- Passerelle : 62
- Broadcast : 63

---

## 4.3 Sous-réseau 192.168.1.64/27

```bash
subnet 192.168.1.64 netmask 255.255.255.224 {
    range 192.168.1.66 192.168.1.93;
    option routers 192.168.1.94;
    option domain-name "prive.blanc.iut";
    option domain-name-servers 192.168.1.98;
    option broadcast-address 192.168.1.95;
}
```

---

## 4.4 Sous-réseau 192.168.1.96/27

```bash
subnet 192.168.1.96 netmask 255.255.255.224 {
    range 192.168.1.100 192.168.1.125;
    option routers 192.168.1.126;
    option domain-name "prive.blanc.iut";
    option domain-name-servers 192.168.1.98;
    option broadcast-address 192.168.1.127;
}
```

---

# 5. Résumé de l’architecture

Interface d’écoute :  
- eth1

Serveur DNS :  
- 192.168.1.98

Domaine distribué :  
- prive.blanc.iut

Découpage réseau :  
- 4 sous-réseaux en /27
- Chaque sous-réseau possède :
  - sa propre passerelle
  - sa propre plage DHCP
  - le même serveur DNS

---

# 6. Démarrage et vérification

Redémarrage du service :

```bash
systemctl restart isc-dhcp-server
```

Vérification du statut :

```bash
systemctl status isc-dhcp-server
```

Vérification des erreurs :

```bash
journalctl -fu isc-dhcp-server
```

---

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTIwNzUxMjUwNTZdfQ==
-->