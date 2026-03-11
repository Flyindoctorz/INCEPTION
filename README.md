INCEPTION 

Ce projet a ete cree comme partie du curriculum42 by cgelgon.

I. Description : 

le projet centre autour de l'apprentissage de Docker, du Docker-compose.
Le projet s'appelle inception a cause de la regle de sudo, inaccessible sur la session reguliere USER,
qui nous oblige a utiliser une VM pour faire tourner les docker.

DOCKER permet d'installer des containers isoles qui permet de faire tourner une application tout en utilisant l'OS 
de la machine hote.
Le container se ferme lorsqu'aucun processus n'est demarre.

DOCKER-COMPOSE est un outil permettant de de definir le comportement des container lance, et d'executer des applications
Docker a container multiples. Tout se parametre dans un unique ficher YML qu'une seule commande execute pour build et demarrer
tout les containers configures.

Sans docker-compose, il faudrait demarrer et parametrer chaque docker individuellement.

L'OBJECTIF :
faire tourner 3 containers conjointement :
- MariaDB - systeme de gestion de base de donnee Open Source derive de MySQL
- Wordpress, qu'on construit en utilisant la database de MariaDB est un systeme de gestion de contenu
- NGINX, qu'on construit a partir de Wordpress est un logiciel Open Source de serveur web


Ce projet utilise Docker et Docker Compose pour deployer une infrastructure web multi-services.
Chaque service tourne dans un container isole, construit depuis un Dockerfile personnalise base sur
la penultieme version stable d'Alpine Linux ou Debian.

Services inclus :
- **NGINX**    : reverse proxy et terminateur TLS (TLSv1.2/1.3 uniquement), seul point d'entree sur le port 443
- **WordPress**: CMS tournant avec php-fpm dans son propre container, sans NGINX
- **MariaDB**  : base de donnees relationnelle pour WordPress, non exposee a l'exterieur

Choix de conception principaux :
- Toutes les images sont buildees depuis zero via des Dockerfiles custom (pas d'images Docker Hub pre-faites)
- Un seul container expose un port externe : NGINX sur le 443
- Les mots de passe sont geres via Docker Secrets, pas en clair dans les variables d'environnement
- Un reseau bridge custom (inception) est utilise pour que les services communiquent par nom de container
- Les donnees persistantes (BDD, uploads) sont stockees dans des volumes Docker nommes

---

### Virtual Machines vs Docker

| Virtual Machines                              | Docker Containers                              |
|-----------------------------------------------|------------------------------------------------|
| Embarque un OS complet par VM                 | Partage le kernel de la machine hote           |
| Demarrage en plusieurs minutes                | Demarrage en quelques millisecondes            |
| Tres lourd : plusieurs Go par VM              | Leger : quelques Mo par image                  |
| Isolation au niveau hardware (hyperviseur)    | Isolation au niveau processus (namespaces)     |
| Ideal pour faire tourner des OS differents    | Ideal pour les microservices et le CI/CD       |

> **Choix retenu** : Docker, car les services sont de petits processus Linux homogenes.
> Les containers offrent reproductibilite et rapidite sans l'overhead d'un hyperviseur.

---

### Secrets vs Environment Variables

| Docker Secrets                                        | Environment Variables                              |
|-------------------------------------------------------|----------------------------------------------------|
| Stockes de facon chiffree, montes dans /run/secrets/  | Stockes en clair dans l'environnement du container |
| Invisibles dans `docker inspect`                      | Visibles dans `docker inspect` et les logs         |
| Accessibles uniquement par le service cible           | Accessibles par tous les processus du container    |
| Recommandes pour mots de passe, tokens, certificats   | Adaptes aux configs non-sensibles (ports, noms)    |

> **Choix retenu** : Les mots de passe de la base de donnees sont passes via Docker Secrets.
> Les parametres non-sensibles (noms de domaine, ports) sont dans le fichier `.env`.

---

### Docker Network vs Host Network

| Docker Network (bridge/custom)                          | Host Network                                      |
|---------------------------------------------------------|---------------------------------------------------|
| Chaque container a sa propre interface reseau virtuelle | Le container partage directement le reseau hote   |
| Isolation forte entre services                          | Aucune isolation reseau                           |
| Decouverte de services par nom de container (DNS)       | Doit utiliser localhost et gerer les ports manuellement |
| Ports exposes de facon explicite uniquement             | Tous les ports du container sont ouverts sur l'hote |
| Recommande pour les architectures multi-services        | Utile uniquement pour des besoins haute performance |

> **Choix retenu** : Un reseau bridge custom `inception` est utilise. NGINX, WordPress et MariaDB
> communiquent par nom de container sans exposer de ports inutiles vers l'hote.

---

### Docker Volumes vs Bind Mount

| Docker Volumes                                        | Bind Mounts                                        |
|-------------------------------------------------------|----------------------------------------------------|
| Geres par Docker sous /var/lib/docker/volumes/        | Mappe un chemin specifique de l'hote dans le container |
| Portables : fonctionnent sur n'importe quel hote Docker | Dependants de l'hote : le chemin doit exister      |
| Les donnees persistent independamment du container    | Les donnees persistent sur l'hote mais couplees au chemin |
| Sauvegardes via les commandes Docker standard         | Sauvegardes via les outils systeme classiques      |
| Preferes pour les donnees de production               | Pratiques en developpement (edition live du code)  |

> **Choix retenu** : Des volumes nommes (`db-data`, `wp-data`) sont utilises pour MariaDB et WordPress.
> Ils sont montes dans /home/<user>/data/ sur l'hote comme exige par le sujet.

---

II. Instruction : 

Use make to compile the project 

III Ressources :

Sources utilisees dans le projet :
- https://tuto.grademe.fr/inception/
- https://wiki-tech.io/Conteneurisation/Docker/Docker-Compose
- https://docs.docker.com/engine/install/debian/#install-using-the-repository
- https://docs.docker.com/network/
- https://docs.docker.com/storage/volumes/
- https://nginx.org/en/docs/
- https://fr.wikipedia.org/wiki/WordPress
- https://fr.wikipedia.org/wiki/NGINX
- https://fr.wikipedia.org/wiki/MariaDB
- https://fr.wikipedia.org/wiki/Docker_(logiciel)
- https://wiki.mozilla.org/Security/Server_Side_TLS
- Claude code pour corriger des scripts

