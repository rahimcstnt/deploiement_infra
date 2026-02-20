# Procédure d’installation et de configuration d’un Forward Proxy  
(Service : Apache2)

---

# 1. Installation d’Apache

```bash
apt install apache2
systemctl enable apache2
systemctl start apache2
```

---

# 2. Activation des modules nécessaires

Un proxy Apache nécessite les modules suivants :

```bash
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_connect
```

Puis rechargement :

```bash
systemctl restart apache2
```

Explication :

- `proxy` : module principal de proxy.
- `proxy_http` : gestion du trafic HTTP.
- `proxy_connect` : permet le tunnel HTTPS (méthode CONNECT).

---

# 3. Configuration du Forward Proxy

Fichier :  
`/etc/apache2/sites-available/forward-proxy.conf`

```apache
<VirtualHost *:80>
    ServerName apache.local

    ProxyRequests On
    ProxyVia On

    <Proxy "*">
        Require ip 192.168.1.64/27
    </Proxy>

    AllowCONNECT 443

    ErrorLog ${APACHE_LOG_DIR}/forward-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/forward-proxy-access.log combined
</VirtualHost>
```

---

# 4. Explication des directives essentielles

### `ProxyRequests On`

Active le mode **forward proxy**.  
Sans cette directive, Apache agit uniquement comme serveur web.

---

### `ProxyVia On`

Ajoute l’en-tête HTTP `Via` pour indiquer que la requête passe par un proxy.

---

### Bloc `<Proxy "*">`

```apache
<Proxy "*">
    Require ip 192.168.1.64/27
</Proxy>
```

Restreint l’utilisation du proxy au réseau :

```
192.168.1.64/27
```

Seules les machines de ce sous-réseau peuvent utiliser le proxy.

Cela évite qu’Apache devienne un proxy ouvert.

---

### `AllowCONNECT 443`

Autorise la méthode CONNECT vers le port 443.

Permet le tunnel HTTPS via le proxy.

---

### Logs dédiés

```apache
ErrorLog ...
CustomLog ...
```

Permet de tracer l’utilisation du proxy.

---

# 5. Activation du site proxy

```bash
a2ensite forward-proxy.conf
systemctl reload apache2
```

---

# 6. Configuration côté client

Sur un poste client du réseau autorisé :

Configurer le proxy HTTP :

- Adresse : IP du serveur proxy
- Port : 80

Exemple navigateur :

Proxy HTTP : 192.168.1.X  
Port : 80

---

# 7. Vérification

Depuis un client autorisé :

- Accès à un site web externe
- Vérification des logs :

```bash
tail -f /var/log/apache2/forward-proxy-access.log
```

---

# 8. Résumé

Type : Forward Proxy  
Port : 80  
Réseau autorisé : 192.168.1.64/27  
HTTPS autorisé via CONNECT 443  
Modules activés : proxy, proxy_http, proxy_connect  

---

Le serveur agit désormais comme intermédiaire entre les clients internes autorisés et Internet.

<!--stackedit_data:
eyJoaXN0b3J5IjpbMjExNjgwMjkyXX0=
-->