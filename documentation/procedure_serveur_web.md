
# Procédure – Serveur Web 
Déploiement direct dans /var/www/html

---

# 1. Installation

```bash
apt install apache2 php libapache2-mod-php
systemctl enable apache2
systemctl start apache2
```

---

# 2. Utilisation du répertoire par défaut

Apache utilise par défaut :

```
/var/www/html
```

j'ai donc placé le fichier directement ici :

```
/var/www/html/index.php
```

Aucune création de VirtualHost spécifique n’est nécessaire si le site est accessible via l’adresse IP du serveur ou si le DNS pointe vers ce serveur.

---

# 3. Droits d’accès

Vérification des permissions :

```bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

Cela permet au service Apache (utilisateur www-data) d’accéder aux fichiers.

---

# 4. Fonctionnement de la page

Le fichier `index.php` :

- Contient uniquement du HTML, CSS et JavaScript.
- Ne contient pas de traitement PHP côté serveur.
- Le formulaire est simulé via JavaScript.
- Aucun envoi réel de données n’est effectué.

---

# 5. Liaison DNS

Le DNS doit contenir :

```
www IN A 192.168.1.101
```

L’adresse IP doit correspondre à celle du serveur web.

---

# 6. Test

Depuis un navigateur :

```
http://192.168.1.101
```

ou

```
http://blanc.iut
```

La page animée doit s’afficher correctement.

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTIyNzAyOTk5Ml19
-->