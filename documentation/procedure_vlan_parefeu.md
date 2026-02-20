# Comment faire du routage inter-VLAN avec un pare-feu Stormshield

## Introduction

Ce tutoriel a été rédigé dans le contexte de mon infrastructure réseau, mais le principe reste identique dans d’autres environnements. Il explique comment isoler chaque service dans un VLAN et permettre la communication entre les réseaux via un pare-feu Stormshield.

## Le réseau dans mon cas

- Chaque machine physique (Douglas) correspond à un service :
  - Douglas 2 : service informatique
  - Douglas 3 : service administratif
  - Douglas 4 : service administratif
  - Toutes ces machines sont dans le réseau privé.

- Douglas 1 est dans la DMZ.

- Chaque machine aura la première adresse disponible de son sous-réseau, et les VMs déployées avec Vagrant seront en mode bridge sur l’interface `enp3s0`.
  - Les VMs prendront la passerelle par défaut de cette interface.

## Isoler chaque machine dans un VLAN

### Exemple : Machine Douglas 2 (service informatique)

- Brancher Douglas 2 sur le port `Fa0/2` du switch 2.
- Son adresse IP : `192.168.1.1` / Masque : `255.255.255.224`

#### Créer le VLAN sur le switch 2

~~~<config>
vlan 20
 name informatique
 exit
~~~

#### Configurer le port en mode access

~~~<config>
int Fa0/2
 switchport mode access
 switchport access vlan 20
 exit
~~~

> **Remarque** : cela signifie que le port accepte uniquement les trames taguées avec le VLAN 20.

- Répéter la même configuration pour toutes les autres machines.

#### Créer le VLAN DMZ

Il est essentiel de créer le VLAN DMZ sur les deux switchs si l’on souhaite que la machine Douglas 1 (DMZ) puisse communiquer avec les machines du réseau privé situées sur l’autre switch.
Par exemple, si le VLAN DMZ (ID 10) n’est créé que sur le switch 2, mais pas sur le switch 3, alors les machines du réseau privé sur le switch 3 ne pourront pas communiquer avec la machine DMZ.
Le switch 3 ne connaît pas le VLAN 10, donc il ne sait pas comment traiter les trames qui lui sont adressées.
Pour que la communication inter-VLAN fonctionne entre les deux réseaux, il faut que le VLAN soit déclaré sur les deux switchs.

~~~<config>
vlan 10
 name dmz
 exit
~~~

> **Explication** : le VLAN DMZ permet d’isoler les services exposés à l’extérieur (comme les serveurs web ou les services publics) du reste du réseau privé. Cela renforce la sécurité et permet de gérer les règles de filtrage au niveau du pare-feu.

## Configurer le port trunk

- Choisir une interface du switch qui n’est pas déjà utilisée (exemple : `Fa0/1`).

~~~<config>
int Fa0/1
 switchport mode trunk
 exit
~~~

> **Astuce** : le pare-feu prend en charge le filtrage des VLANs, donc il n’est pas nécessaire de limiter quels VLANs passent sur le port trunk.

- refaire la même manipulation sur le switch 3 pour l’autre réseau, et bien penser à créer tous les VLANs nécessaires.
Si dans le switch 3 je veux faire passer le vlan de mon service production je dois créer ce Vlan au niveau du switch de l'autre réseau et vice-versa sinon ça ne fonctionnera pas.

## Attention aux manipulations à éviter

Lorsqu’on configure des VLANs sur un réseau classique (sans pare-feu en position de routage central), il est fréquent d’attribuer une adresse IP et d’activer l’interface VLAN directement sur le switch, de cette façon :

~~~<config>
int vlan 20
 ip address 192.168.1.30 255.255.255.224
 exit
~~~

En temps normal, cela permet au switch de jouer le rôle de passerelle par défaut pour les machines du VLAN : il répondra aux pings et assurera le routage local. Par habitude, on configure souvent la première ou la dernière adresse du sous-réseau en tant que passerelle.

**Cependant, dans le cas d’un routage inter-VLAN géré par un pare-feu Stormshield, il ne faut surtout pas suivre cette méthode.**  
Si l’on configure l’adresse de la passerelle sur l’interface VLAN du switch, c’est le switch lui-même qui va répondre aux requêtes réseau des machines (par exemple aux pings), ce qui fausse les tests de communication et complique le diagnostic des erreurs.

## La bonne méthode (avec pare-feu)

### Créer les sous-interfaces VLAN sur le pare-feu

- Créer une sous-interface VLAN sur l’interface du pare-feu reliée au port trunk (par exemple, port IN).
- Attribuer une IP statique qui correspond à la dernière adresse disponible du sous-réseau (exemple : `192.168.1.30` pour le VLAN 20).
- Faire cela pour chaque VLAN du réseau privé et pour le VLAN DMZ.

> **Précision essentielle** : les ID des VLAN doivent être identiques sur le switch et sur le pare-feu, sinon la communication ne fonctionne pas.

## Faire les tests

### Préparer le pare-feu

- Désactiver la politique de sécurité `block-all` sur le pare-feu (elle bloque toutes les communications).
- Choisir une politique personnalisée (par exemple, `pass-all` ou une politique adaptée).

### Exemple de test : Douglas 2 ↔ Douglas 1

- Changer l’adresse IP de l’interface connectée au switch (par exemple, `enp3s0`) pour qu’elle corresponde au sous-réseau du VLAN.
- Modifier la route par défaut pour pointer vers la passerelle du VLAN (par exemple, `192.168.1.30`).
- Faire ces réglages sur toutes les machines concernées.

### Vérification

- Faire un ping vers la passerelle du VLAN pour vérifier la configuration du pare-feu.
- Faire un ping vers l’autre machine pour tester la communication inter-VLAN.

## Récapitulatif

- Les sous-interfaces VLAN sont à configurer sur le pare-feu, jamais sur le switch dans ce scénario.
- Les VLANs doivent être déclarés sur les deux switchs.
- La politique de sécurité du pare-feu doit permettre les communications nécessaires.
```

