erase start-up config 
delete flash:/vlan.dat 
Ces commandes permettent d'effacer la configuration du switch 

# Connexion au firewall stormshield SN310 
- Commande pour vérifier les ports usb actifs 
~~~
 ls /dev/ttyUSB*
~~~
- Il faut connecter la machine physique au port 2 du firewall stormshield pour accéder à la console
- Exectuer la commande suivante pour démarrer minicom sur le port usb auquel est connecté le firewall :
~~~
minicom -D /dev/ttyUSB0
~~~
- login: admin
- password : admin 
- `Ce mot de passe est le mot de passe par défaut ; pour des raisons de sécurité, il est conseillé de le modifier.`
- `Si probleme de login / mot de passe il faut reset le firewall (face arrière bouton en bas à droite)`
- 
Guide d'installation du parefeu : 
~~~
https://documentation.stormshield.eu/SNS/v4/fr/Content/PDF/InstallationGuides/sns-fr_SN160-SN210-SN310-quickstart_v1.2.pdf
~~~
~~~
https://documentation.stormshield.com/SNS/v4/fr/Content/PDF/SNS-UserGuides/sns-fr-manuel_d_utilisation_et_de_configuration-v4.2.6.pdf
~~~
- Guide des commandes CLI du parefeu
~~~
https://documentation.stormshield.eu/SNS/v4/en/Content/PDF/SNS-UserGuides/sns-en-cli_serverd_commands_reference_guide-v4.pdf
~~~

- Configurer l'ip de l'interface enp3s0 afin qu'elle soit sur le meme réseau que l'interface de configuration du pare-feu 10.0.0.254 ici par exemple : 10.0.0.1/24 

Switch 3 (DMZ)
Port Fa0/1 :
switchport mode access
switchport access vlan 10

Port Fa0/2 :
switchport mode trunk

Switch 2 (Réseau privé)
Port Fa0/2 :
switchport mode access
switchport access vlan 20

Port Fa0/3 :
switchport mode access
switchport access vlan 30

Port Fa0/4 :
switchport mode access
switchport access vlan 40

Port Fa0/1 :
switchport mode trunk

Firewall
Interface IN (VLAN 20) :
IP 192.168.1.30/27

Interface IN (VLAN 30) :
IP 192.168.1.62/27

Interface IN (VLAN 40) :
IP 192.168.1.94/27

Interface OUT (DMZ, VLAN 10) :
IP 192.168.1.126/27

Règles de pare-feu
Autoriser VLAN 20 → DMZ

Autoriser DMZ → réseau privé (VLAN 20, 30, 40)

Bloquer VLAN 30/40 → DMZ

Bloquer tout autre trafic non autorisé

Passerelles par défaut
Machines VLAN 20 : 192.168.1.30

Machines VLAN 30 : 192.168.1.62

Machines VLAN 40 : 192.168.1.94

Machines DMZ : 192.168.1.126

