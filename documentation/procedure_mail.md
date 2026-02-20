# Procédure d’installation et de configuration du serveur mail  
(Postfix + Dovecot + Roundcube)

Cette procédure décrit la configuration d’un serveur de messagerie basé sur :

- Postfix (SMTP)
- Dovecot (IMAP + authentification)
- Roundcube (Webmail via Apache)



---

# 1. Configuration de Postfix (main.cf)

Fichier : `/etc/postfix/main.cf`

## 1.1 Identification du serveur

```ini
myhostname = mail.blanc.iut
mydomain = blanc.iut
```

**Explication :**
- `myhostname` : nom complet (FQDN) du serveur mail.
- `mydomain` : domaine principal géré par le serveur.

---

```ini
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
```

**Explication :**
Définit les domaines pour lesquels le serveur accepte les mails en livraison locale.
Cela signifie que les mails destinés à `blanc.iut` seront stockés localement.

---

## 1.2 Stockage des mails

```ini
home_mailbox = Maildir/
```

**Explication :**
Active le format **Maildir** dans le répertoire personnel de chaque utilisateur.
Les mails seront stockés dans :

```
/home/utilisateur/Maildir/
```

---

## 1.3 Configuration réseau

```ini
inet_interfaces = all
```

**Explication :**
Le serveur SMTP écoute sur toutes les interfaces réseau.

---

```ini
inet_protocols = ipv4
```

**Explication :**
Désactive IPv6 et force l’utilisation d’IPv4 uniquement.

---

```ini
mynetworks = 192.168.1.0/24
```

**Explication :**
Relaye uniquement les mails provenant du réseau local.
Ici : toutes les machines du réseau 192.168.1.0/24.

---

## 1.4 Sécurité SMTP

```ini
smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination
```

**Explication :**
- `permit_mynetworks` : autorise le réseau local.
- `reject_unauth_destination` : empêche le serveur de devenir un relais ouvert (anti open-relay).

---

## 1.5 Authentification SMTP (liaison avec Dovecot)

```ini
smtpd_sasl_auth_enable = yes
```

Active l’authentification SMTP.

```ini
smtpd_sasl_security_options = noanonymous
```

Interdit l’authentification anonyme.

```ini
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
```

Indique que :
- L’authentification est déléguée à Dovecot
- Le socket utilisé est `/var/spool/postfix/private/auth`

---

# 2. Configuration de Dovecot (dovecot.conf)

Fichier : `/etc/dovecot/dovecot.conf`

---

## 2.1 Protocoles activés

```ini
protocols = imap
```

**Explication :**
Active uniquement IMAP.
POP3 est désactivé.

---

## 2.2 Emplacement des mails

```ini
mail_location = maildir:~/Maildir
```

**Explication :**
Indique à Dovecot que les mails sont stockés en Maildir dans le dossier personnel de chaque utilisateur.

---

## 2.3 Authentification

```ini
disable_plaintext_auth = no
```

**Explication :**
Autorise l’authentification en clair.
Adapté à un environnement de test local uniquement.
En production, cette option doit être mise à `yes` avec SSL activé.

---

```ini
auth_mechanisms = plain login
```

Active les méthodes d’authentification standards IMAP.

---

```ini
passdb {
  driver = pam
}
```

**Explication :**
Utilise l’authentification système Linux via PAM.

---

```ini
userdb {
  driver = passwd
}
```

**Explication :**
Les utilisateurs sont les comptes système Linux.

---

## 2.4 Configuration du service IMAP

```ini
service imap-login {
  inet_listener imap {
    port = 143
  }
}
```

**Explication :**
Le serveur IMAP écoute sur le port 143.
Le port sécurisé IMAPS (993) est désactivé.

---

## 2.5 Communication avec Postfix

```ini
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
```

**Explication :**
Crée un socket UNIX permettant à Postfix d’utiliser Dovecot pour l’authentification SMTP.

---

# 3. Configuration de Roundcube

Fichier : `/etc/roundcube/config.inc.php`

---

## 3.1 Serveur IMAP

```php
$config['imap_host'] = ['mail.blanc.iut:143'];
```

**Explication :**
Roundcube se connecte au serveur IMAP local sur le port 143.

---

## 3.2 Serveur SMTP

```php
$config['smtp_host'] = 'mail.blanc.iut:25';
```

**Explication :**
Roundcube envoie les mails via Postfix sur le port 25.

---

## 3.3 Authentification SMTP

```php
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
```

**Explication :**
Roundcube utilise :
- `%u` : le nom d’utilisateur connecté
- `%p` : son mot de passe

Cela permet d’utiliser les identifiants IMAP pour l’envoi SMTP.

---

## 3.4 Clé de chiffrement

```php
$config['des_key'] = 'IKF+oCBuJ8O6atvJDRqIKt9W';
```

**Explication :**
Clé utilisée pour chiffrer le mot de passe IMAP stocké en session.
Elle doit être unique et privée.

---

## 3.5 Interface

```php
$config['skin'] = 'elastic';
```

Définit le thème graphique utilisé.

---

# 4. Configuration Apache pour Roundcube

Fichier : `/etc/apache2/conf-available/roundcube.conf`

---

## 4.1 Alias

```apache
Alias /roundcube /var/lib/roundcube/public_html
```

**Explication :**
Permet d’accéder au webmail via :

```
http://mail.blanc.iut/roundcube
```

---

## 4.2 Autorisation d’accès

```apache
<Directory /var/lib/roundcube/public_html/>
  Require all granted
</Directory>
```

Autorise l’accès public à l’interface web.

---

## 4.3 Protection des dossiers sensibles

```apache
<Directory /var/lib/roundcube/config>
  Require all denied
</Directory>
```

Empêche l’accès aux fichiers de configuration via le web.

Même principe pour :

```apache
/var/lib/roundcube/temp
/var/lib/roundcube/logs
```

Ces dossiers ne doivent jamais être accessibles publiquement.

---

# 5. Architecture finale

- Postfix : réception et envoi SMTP
- Dovecot : accès IMAP + authentification
- Roundcube : interface web
- Stockage : Maildir dans /home/utilisateur/Maildir
- Authentification : comptes système Linux (PAM)

---

# 6. Remarque importante (Sécurité)

La configuration actuelle :

- utilise IMAP non chiffré (143)
- utilise SMTP non chiffré (25)
- autorise l’authentification en clair

Cette configuration est adaptée à un réseau local de test.

Pour un environnement de production, il est nécessaire :

- d’activer SSL/TLS (IMAPS 993 et SMTPS 587)
- de forcer l’authentification chiffrée
- d’installer un certificat valide

---


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE0MzUyMzQ1MV19
-->