# Table des matières
- [Récupération de l’image IOS après suppression accidentelle du fichier de démarrage](#récupération-de-limage-ios-après-suppression-accidentelle-du-fichier-de-démarrage)
- [Solution 1 : Télécharger une image Cisco IOS depuis Internet](#solution-1--télécharger-une-image-cisco-ios-depuis-internet)
- [Solution 2 : Récupérer l'image depuis un switch fonctionnel via serveur TFTP](#solution-2--récupérer-limage-depuis-un-switch-fonctionnel-via-serveur-tftp)
- [Partie 2 : Installation de l'image IOS sur le switch en panne](#partie-2--installation-de-limage-ios-sur-le-switch-en-panne)

---

# Récupération de l’image IOS après suppression accidentelle du fichier de démarrage

Suite à l’exécution de la commande `erase /all` en mode privilégié, le fichier de démarrage du switch a été supprimé, rendant le switch incapable de démarrer normalement. Il a été nécessaire de restaurer l’image IOS via le cable console.

---

## Solution 1 : Télécharger une image Cisco IOS depuis Internet

- Noter le modèle exact (ex : Catalyst 2960, 2960S, 2960G, etc.).

### 2. Télécharger l'image IOS
- Se connecter au site officiel Cisco Software Center (nécessite un compte Cisco avec contrat de support).
- Rechercher le modèle du switch, puis sélectionner la version IOS recommandée.
- Télécharger le fichier `.bin` correspondant.
- Renommer le fichier si nécessaire pour faciliter la gestion (ex : `c2960-lanbasek9-mz.152-4.E.bin`).

### 3. Placer le fichier sur la machine physique
- Copier le fichier téléchargé dans un dossier accessible (ex : `/home/user/cisco/`).

---

## Solution 2 : Récupérer l'image depuis un switch fonctionnel via serveur TFTP

### 1. Configuration réseau de la machine physique

` Avant de commencer il faut s'assurer que le switch dont on veut récupérer l'image est du meme modèle que le switch en panne.` 

Attribuer une adresse IP à l’interface réseau de la machine physique (par exemple `enp3s0`).

~~~
sudo ip addr add 192.168.1.1/27 dev enp3s0
~~~

### 2. Configuration du serveur TFTP avec Vagrant

Créer un fichier `Vagrantfile` pour déployer une VM Debian 12 avec serveur TFTP installé et configuré.

~~~
Vagrant.configure("2") do |config|
config.vm.box = "debian/bookworm64"
config.vm.network "public_network", bridge: "enp3s0"
config.vm.provision "shell", inline: <<-SHELL
sudo apt update
sudo apt install -y tftpd-hpa
sudo sed -i 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="--secure --create"/' /etc/default/tftpd-hpa
sudo sed -i 's/TFTP_DIRECTORY="/var/lib/tftpboot"/TFTP_DIRECTORY="/var/lib/tftpboot"/' /etc/default/tftpd-hpa
sudo chown -R tftp:tftp /var/lib/tftpboot
sudo chmod 2775 /var/lib/tftpboot
sudo systemctl restart tftpd-hpa
SHELL
end
~~~

Lancer la VM avec la commande :
~~~
vagrant up 
~~~
- Donne la propriété du répertoire racine TFTP au groupe tftp et ajuste les droits pour autoriser l’écriture des membres du groupe :
~~~
sudo chown -R tftp:tftp /var/lib/tftpboot
sudo chmod 2775 /var/lib/tftpboot
~~~
- Vérifier que le serveur TFTP écoute sur toutes les interfaces réseau (port 69 UDP).
- Vérifie que la configuration /etc/default/tftpd-hpa contient bien l'option `--create`
~~~
cat /etc/default/tftpd-hpa
~~~
~~~
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure --create"
~~~
- Dans `TFTP_ADDRESS= "0.0.0.0:69"` cela signifie que le port 69 écoute sur toutes les interfaces de la machine
- TFTP_OPTIONS="--secure --create"
L’option `--create`  permet la création de fichiers, indispensable pour que le switch puisse envoyer des fichiers vers le serveur.

### 3. Branchement du switch

Brancher la carte réseau de la machine physique (interface `enp3s0`) à une interface du switch (par exemple FastEthernet 2).

### 4. Configuration de l'interface du switch

Se connecter au switch en mode configuration.
~~~
Switch> enable
Switch# configure terminal
~~~

Configurer l’interface FastEthernet 2 afin de l'attribuer au Vlan 1:

~~~
Switch(config)# interface FastEthernet2
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 1
Switch(config-if)# exit
~~~

Attribuer une adresse ip au Vlan (par exemple ici : 192.168.1.3) :
~~~
Switch# int Vlan 1
Switch(config-if)# ip address 192.168.1.3 255.255.255.224
Switch(config-if)# no shutdown
Switch(config-if)# exit
~~~ 
Vérifier que l’interface appartient au bon Vlan :
~~~
Switch# show vlan
~~~
Vérifier que l'interface Vlan 1 est up et possède la bonne adresse ip :
~~~
Switch(config)# show ip interface brief
~~~
### 5. Récupération de l’image IOS

Se connecter en console sur le switch fonctionnel (source de l’image).

En mode utilisateur privilégié, exécuter :

~~~
Switch# copy flash:<nom_de_l'image.bin> tftp:
~~~

Indiquer l’adresse du serveur TFTP (192.168.1.2) et le nom du fichier de destination (laisser par défaut).

Si une erreur survient, revoir la configuration du serveur TFTP.

### 6. Vérification et récupération du fichier

Sur la VM TFTP, vérifier la présence du fichier dans `/var/lib/tftpboot`.

Copier le fichier vers le dossier partagé Vagrant :

~~~
cp /var/lib/tftpboot/<nom_de_l'image.bin> /vagrant/
~~~

Le fichier est désormais accessible sur la machine physique.

---

## Partie 2 : Installation de l'image IOS sur le switch en panne

### 1. Transfert de l'image via protocole Xmodem, si le réseau ne fonctionne pas en ROMmon (ROM Monitor)

- Se connecter en console au switch en panne à l’aide d’un câble série sur la machine sur laquelle se trouve l'image boot.
- Ouvrir un terminal et lancer la commande `minicom`.
- Dans le mode ROMmon, exécuter la commande suivante pour augmenter la vitesse de transmission :
  ~~~
  switch: set BAUD 115200
  ~~~
  Cette étape permet d’accélérer le transfert du fichier (environ 26 minutes pour 11 Mo contre 3h30 à 9600 bauds).

- Si le terminal semble figé ou affiche du charabia, fermer le terminal Minicom, puis ouvrir un nouveau terminal et exécuter :
  ~~~
  minicom -s
  ~~~
  Cela permet d’accéder au menu de configuration de Minicom.
- Sélectionner le menu **Protocol Configuration** et vérifier que la vitesse en bauds est bien réglée sur **115200**. Si ce n’est pas le cas, la modifier.
- Sélectionner Quitter,  **Ne pas sélectionner "Quitter minicom" sinon les modifications ne seront pas prises en compte**, en sélectionnant quittant minicom ouvrira le mode ROMmon du Switch

- La communication avec le switch se fait désormais à 115200 bauds.

- Sur le switch, exécuter la commande :
  ~~~
  switch: flash_init
  ~~~
  Cela permet de réinitialiser la mémoire flash.

- Dans le mode ROMmon du switch, appuyer sur **Ctrl+A**, puis sur **Z** pour ouvrir le menu de Minicom.
- Appuyer sur **S** pour sélectionner l’option « Send file ».
- Dans le sous-menu qui s’affiche, sélectionner le protocole **Xmodem**.
- Sélectionner avec la touche **Espace** le fichier binaire correspondant à l’image de boot, puis appuyer sur **Entrée**.
- Le switch affiche alors le message :
  ~~~
  Give your local XMODEM receive command now
  ~~~
  Cela signifie qu’il attend la commande de transfert sur le terminal du switch.
- Dans le terminal, exécuter la commande :
  ~~~
  switch: copy xmodem: flash:<nom_du_fichier.bin>
  ~~~
  Attendre la fin du transfert du fichier.

- Une fois le transfert terminé, lancer le boot sur la nouvelle image :
  ~~~
  switch: boot flash:<nom_de_l_image.bin>
  ~~~

`REMARQUE : Il est très probable qu’après le redémarrage du commutateur, la vitesse de transmission reste à 115200 bauds, ce qui peut entraîner l’affichage de caractères illisibles.  
Voici la procédure pour rétablir la vitesse à 9600 bauds :

Voici ce que j’ai fait :
- Éteindre le commutateur (switch) ou saisir reload (si caractères illisibles CTRL+A puis P et changer en 115200 bauds)
- Appuyer sur le bouton Mode tout en mettant le commutateur sous tension pour entrer dans le mode ROMMON "switch:"
- Entrer la commande "set" pour voir BAUD=115200
- Saisir "flash_init" puis "load_helper"
- "set_bs bs: rw"  --> définit l’attribut de lecture/écriture sur le secteur de démarrage
- "unset BAUD"
- "flash_init"
- "set BAUD 9600"  --> définit la vitesse de transmission à 9600 bauds
- "set_param"  --> enregistre les paramètres en mémoire
- "set_bs bs: ro"  --> remet le secteur de démarrage en lecture seule
- "boot"