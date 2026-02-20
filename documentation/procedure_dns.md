
# Procédure d’installation et de configuration d’un serveur DNS  
(Service : BIND9)

Cette procédure décrit la configuration d’un serveur DNS maître pour :

- Domaine public : **blanc.iut**
- Domaine privé : **prive.blanc.iut**
- Mise à jour dynamique sécurisée avec DHCP
- Résolution récursive limitée aux réseaux autorisés

---

# 1. Installation du service DNS

Installation :

```bash
apt install bind9 bind9utils bind9-doc
```

Service principal :

```bash
systemctl enable bind9
systemctl start bind9
```

---

# 2. Configuration globale – named.conf.options

Fichier : `/etc/bind/named.conf.options`

---

## 2.1 Définition des réseaux autorisés

```bash
acl "trusted" {
192.168.1.0/24;
127.0.0.1;
192.168.2.0/24;
192.168.3.0/24;
192.168.4.0/24;
};
```

Explication :

Définit une liste de réseaux considérés comme fiables.  
Seuls ces réseaux pourront effectuer des requêtes récursives.

---

## 2.2 Options principales

```bash
options {
directory "/var/cache/bind";
recursion yes;
dnssec-validation no;
allow-recursion { trusted; };
allow-query { trusted; };
allow-query-cache { trusted; };
listen-on { any; };
listen-on-v6 { none; };
forwarders {
192.168.4.20;
};
notify explicit;
notify-delay 5;
};
```

Explication des lignes importantes :

- `directory` : emplacement des fichiers de zone.
- `recursion yes` : autorise la résolution récursive.
- `allow-recursion { trusted; }` : limite la récursion aux réseaux ACL.
- `allow-query { trusted; }` : limite les requêtes DNS aux réseaux autorisés.
- `listen-on { any; }` : écoute sur toutes les interfaces IPv4.
- `listen-on-v6 { none; }` : désactive IPv6.
- `forwarders { 192.168.4.20; };` : envoie les requêtes externes vers ce DNS relais.
- `dnssec-validation no;` : désactive la validation DNSSEC (souvent en environnement interne).

---

# 3. Configuration locale – named.conf.local

Fichier : `/etc/bind/named.conf.local`

---

## 3.1 Inclusion de la clé DHCP

```bash
include "/etc/bind/dhcpupdate.key";
```

Permet d’utiliser la clé sécurisée partagée avec le serveur DHCP.

---

## 3.2 Définition des ACL internes

```bash
acl "net-prive" {
192.168.1.0/24;
};
```

Réseau interne principal.

```bash
acl "net-public" {
192.168.2.0/24;
192.168.3.0/24;
192.168.4.0/24;
};
```

Réseaux considérés comme publics ou secondaires.

---

# 4. Zone principale : blanc.iut

```bash
zone "blanc.iut" {
type master;
file "/var/cache/bind/db.blanc.iut";
allow-query { net-public; net-prive;};
};
```

Explication :

- `type master` : serveur maître pour la zone.
- `file` : fichier contenant les enregistrements.
- `allow-query` : autorise les requêtes depuis les réseaux définis.

Cette zone est statique (pas de mise à jour dynamique).

---

# 5. Zone privée : prive.blanc.iut

```bash
zone "prive.blanc.iut" {
type master;
file "/var/cache/bind/db.prive.blanc.iut";
allow-update { key "dhcpupdate"; };
allow-query { net-prive; };
notify yes;
};
```

Explication :

- `allow-update { key "dhcpupdate"; };`  
  Autorise les mises à jour dynamiques sécurisées par la clé.
- `allow-query { net-prive; };`  
  Restreint la résolution au réseau privé.
- `notify yes;`  
  Informe les éventuels serveurs secondaires des modifications.

---

# 6. Fichier de clé – dhcpupdate.key

```bash
key "dhcpupdate" {
algorithm hmac-sha256;
secret "oWMJyK8f2p62BCSHMVJAn55uW0pPPO58OV0ghxhi6qY=";
};
```

Explication :

- Clé partagée entre DHCP et DNS.
- Garantit que seules les mises à jour autorisées sont acceptées.

Cette clé doit être identique dans la configuration DHCP.

---

# 7. Fichier de zone – db.blanc.iut

Zone principale publique.

## 7.1 En-tête SOA

```bash
@ IN SOA ns.blanc.iut. admin.blanc.iut. (
2 ; Serial
604800 ; Refresh
86400 ; Retry
2419200 ; Expire
604800 ) ; Negative Cache TTL
```

Explication :

- `ns.blanc.iut.` : serveur DNS autoritaire.
- `admin.blanc.iut.` : email administrateur (admin@blanc.iut).
- `Serial` : numéro de version de la zone (doit être incrémenté à chaque modification).
- `Refresh` : délai avant vérification par un serveur secondaire.
- `Retry` : délai en cas d’échec.
- `Expire` : durée maximale de validité.
- `Negative Cache TTL` : durée de cache des réponses négatives.

---

## 7.2 Enregistrements principaux

```bash
@ IN NS ns.blanc.iut.
ns IN A 192.168.1.98
```

Déclare le serveur DNS autoritaire.

---

```bash
@ IN A 192.168.1.98
mail IN A 192.168.1.100
www IN A 192.168.1.101
```

Associe des noms à des adresses IP.

---

## 7.3 Enregistrement MX

```bash
@ IN MX 10 mail
```

Définit le serveur de messagerie du domaine.

Priorité 10 → plus petit = plus prioritaire.

---

## 7.4 SPF

```bash
@ IN TXT "v=spf1 mx -all"
```

Autorise uniquement le serveur défini dans le MX à envoyer des emails pour ce domaine.

---

## 7.5 DMARC

```bash
_dmarc IN TXT "v=DMARC1; p=reject; rua=mailto:admin@blanc.iut."
```

Politique DMARC :

- `p=reject` : rejette les mails non conformes.
- `rua` : adresse de rapport.

---

## 7.6 Services SRV

```bash
_imaps._tcp IN SRV 10 10 993 mail
_submission._tcp IN SRV 10 10 587 mail
```

Annonce :

- Service IMAPS sur port 993
- Service SMTP Submission sur port 587

---

# 8. Fichier de zone – db.prive.blanc.iut

Même structure que la zone principale, avec :

- Serial différent (3)
- Mise à jour dynamique activée
- SRV utilisant le nom complet :

```bash
mail.prive.blanc.iut.
```

---

# 9. Vérification et redémarrage

Vérification syntaxique :

```bash
named-checkconf
named-checkzone blanc.iut /var/cache/bind/db.blanc.iut
named-checkzone prive.blanc.iut /var/cache/bind/db.prive.blanc.iut
```

Redémarrage :

```bash
systemctl restart bind9
```

---

# 10. Résumé de l’architecture DNS

Serveur DNS : 192.168.1.98  
Zone publique : blanc.iut  
Zone privée : prive.blanc.iut  
Mise à jour dynamique : activée sur la zone privée  
Résolution récursive : limitée aux réseaux autorisés  
Relais externe : 192.168.4.20  

---

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE0MTM1NzIwOTJdfQ==
-->