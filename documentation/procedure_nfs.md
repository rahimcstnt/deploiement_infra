# Déploiement du service NFS avec Ansible

---

# 1. Architecture mise en place

Une machine de gestion a été utilisée pour piloter le déploiement :  

- Ansible installé sur cette machine  
- Génération préalable d’une paire de clés SSH (privée / publique)  
- Copie de la clé publique sur toutes les machines clientes NFS  

Objectif : permettre l’administration distante sans mot de passe.

Important : la clé privée reste uniquement sur la machine Ansible et n’est jamais diffusée.

---

# 2. Utilisation des FQDN et du DNS privé

Les machines clientes appartiennent à la zone DNS privée :

```
prive.blanc.iut
```

Avant toute exécution Ansible, les clés hôtes SSH ont été enregistrées :

```bash
ssh-keyscan userinfo.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan useradmin1.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan useradmin2.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan userprod1.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan userprod2.prive.blanc.iut. >> ~/.ssh/known_hosts
```

Intérêt :

- La machine Ansible interroge directement le DNS.
- Si une adresse IP change, le FQDN reste valide.
- La gestion est donc indépendante des adresses IP.

---

# 3. Fichier d’inventaire Ansible

Fichier : `inventory.yaml`

```yaml
nfs_server:
  hosts:
    localhost:
      ansible_connection: local

nfs_clients:
  hosts:
    userinfo.prive.blanc.iut.:
    useradmin1.prive.blanc.iut.:
    useradmin2.prive.blanc.iut.:
    userprod.prive.blanc.iut.:
```

Explication :

- `nfs_server` : serveur NFS installé localement.
- `nfs_clients` : machines distantes sur lesquelles le client NFS sera installé.

---

# 4. Déploiement du serveur NFS

Exécution :

```bash
ansible-playbook -i inventory.yaml nfs-server.yaml
```

## Contenu principal du playbook

### a) Installation du serveur NFS

```yaml
- name: Installer nfs-kernel-server
  apt:
    name: nfs-kernel-server
    state: present
    update_cache: yes
```

Installe le service NFS côté serveur.

---

### b) Création des répertoires partagés

```yaml
/var/share/userinfo
/var/share/useradmin1
/var/share/useradmin2
/var/share/userprod
```

Chaque utilisateur possède son propre dossier exporté.

---

### c) Configuration du fichier `/etc/exports`

Exemple généré :

```
/var/share/userinfo userinfo.prive.blanc.iut(rw,sync,no_subtree_check,no_root_squash)
```

Signification des options :

- `rw` : lecture et écriture
- `sync` : écriture synchrone
- `no_subtree_check` : optimisation des performances
- `no_root_squash` : conserve les droits root côté client

---

### d) Activation des exports

```bash
exportfs -ra
```

Recharge la configuration sans redémarrage complet.

---

### e) Démarrage et activation du service

```yaml
systemd:
  name: nfs-kernel-server
  state: restarted
  enabled: yes
```

Le service démarre automatiquement au boot.

---

# 5. Déploiement des clients NFS

Exécution :

```bash
ansible-playbook -i inventory.yaml nfs-client.yaml
```

---

## Contenu principal du playbook

### a) Installation du client NFS

```yaml
apt:
  name: nfs-common
  state: present
```

Permet de monter des partages NFS.

---

### b) Création du point de montage

```yaml
/mnt/nfs
```

Répertoire local qui recevra le partage distant.

---

### c) Ajout dans `/etc/fstab`

Exemple généré :

```
192.168.1.4:/var/share/userinfo /mnt/nfs nfs defaults 0 0
```

- `192.168.1.4` : serveur NFS
- `/var/share/userinfo` : dossier exporté
- `/mnt/nfs` : point de montage local

Cela permet un montage automatique au démarrage.

---

### d) Montage immédiat

Le module `mount` assure :

- montage si non monté
- cohérence avec `/etc/fstab`

---

# 6. Résultat final

- Serveur NFS centralisé sur la machine locale
- Un répertoire dédié par utilisateur
- Clients montés automatiquement
- Accès sécurisé via SSH par clé
- Administration entièrement automatisée avec Ansible
- Utilisation des FQDN pour éviter toute dépendance aux IP fixes

---

# 7. Vérification

Sur un client :

```bash
mount | grep nfs
```

ou

```bash
df -h
```

Le partage doit apparaître monté sur `/mnt/nfs`.

---

L’infrastructure NFS est ainsi déployée de manière reproductible, centralisée et automatisée grâce à Ansible.

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTczNjgwMDkzOF19
-->