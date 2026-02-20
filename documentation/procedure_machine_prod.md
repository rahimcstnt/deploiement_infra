# Configuration des machines du réseau de production

Objectif :  

Les machines utilisateurs du réseau **production** ne doivent accéder à Internet **uniquement via un navigateur web configuré avec un forward proxy**.

Aucun accès direct à l’extérieur ne doit être possible.

---

# 1. Blocage réseau par pare-feu

Première étape : empêcher toute communication directe vers l’extérieur.

Des règles de pare-feu ont été définies afin de :

- Bloquer le trafic sortant vers Internet
- Autoriser uniquement le trafic interne (réseau local)

Principe :

- Les machines production ne peuvent plus joindre directement Internet.
- Seul le proxy interne pourra établir des connexions vers l’extérieur.

Cela garantit un contrôle centralisé des accès.

---

# 2. Suppression de la route par défaut

En complément du pare-feu, la route vers la passerelle externe a été supprimée :

```bash
ip r del default via 10.0.2.2 dev eth0
```

Explication :

- `default via 10.0.2.2` : passerelle vers l’extérieur
- La suppression empêche toute sortie réseau directe
- Même sans pare-feu, la machine ne sait plus comment atteindre Internet

On vérifie avec :

```bash
ip route
```

Il ne doit plus y avoir de route `default`.

---

# 3. Configuration forcée de Firefox via policies.json

Pour imposer l’utilisation du proxy, un fichier de politiques a été créé :

Emplacement :

```
/usr/lib/firefox-esr/distribution/policies.json
```

Contenu :

```json
{
  "policies": {
    "Proxy": {
      "Mode": "manual",
      "HTTPProxy": "192.168.1.5:80",
      "SSLProxy": "192.168.1.5:443",
      "UseHTTPProxyForAllProtocols": false,
      "Passthrough": "localhost, 127.0.0.1, <local>, 192.168.1.0/24"
    }
  }
}
```

## Explication des paramètres

- `"Mode": "manual"`  
  → Configuration manuelle obligatoire.

- `"HTTPProxy": "192.168.1.5:80"`  
  → Proxy HTTP situé sur la machine 192.168.1.5.

- `"SSLProxy": "192.168.1.5:443"`  
  → Proxy HTTPS.

- `"Passthrough"`  
  → Adresses exclues du proxy (réseau local).

Effet :

- L’utilisateur ne peut pas modifier la configuration.
- Firefox utilise obligatoirement le forward proxy.

---

# 4. Redirection graphique (X11) dans Vagrant

Afin de permettre l’affichage graphique de Firefox depuis la machine virtuelle, la redirection X11 a été activée :

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = 4096
end

config.ssh.forward_x11 = true
```

Explication :

- `forward_x11 = true` permet d’afficher les applications graphiques via SSH.
- La mémoire est augmentée pour supporter un environnement graphique fluide.

Lancement :

```bash
vagrant ssh
firefox
```

Firefox s’affiche sur la machine hôte.

---

# 5. Résultat final

Les machines du réseau production :

- N’ont plus de route vers Internet
-  Ne peuvent pas contourner le pare-feu
- Peuvent naviguer uniquement via Firefox
-  Firefox est forcé à utiliser le forward proxy
- Le proxy centralise et contrôle tout le trafic sortant

---

# 6. Vérification

Test sans proxy :

```bash
curl http://google.com
```

Doit échouer.

Test via Firefox :

- La navigation fonctionne
- Les connexions passent par 192.168.1.5

Sur le serveur proxy :

```bash
tail -f /var/log/apache2/forward-proxy-access.log
```

Les requêtes des machines production doivent apparaître.


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE1MTQ4OTg0NTVdfQ==
-->