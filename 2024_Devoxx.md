# Devoxx 2024

### keynote 1 greatest mistakes
- who: mark rendle
- bugs les plus couteux


### monde shooté metaux
- who: Agnès crepet guillaume pitron
- indium (tactile)
- 70 métaux smartphone, 182kg matière 
- fairphone env 25 métaux, meilleures conditions de travail,..


### cybersecurité
- who:Sonia seddiki
- dns tunneling : ping ne passe pas mais dans résolu. ex attaque solarwings 2020.
- échange de messages en fonction des IP résolues par le faux serveur, ou requête txt dans pour récupérer code malveillant, envoi credentials sur dns en Hexa puis ping dns avec URL contenant de Hexa.
- steganographie texte e2808b efbbbf espaces sans chasse
- side Channel attacks : analyse conso CPU sur décryptage RSA pour déduire clé privée (square moins consommateur que square&multiply)


### architecture simple
- who: Bertrand Delacrétaz
- système compliqué difficile à remplacer 
- ex de simplicité : cmd linux, Lego, le kazoo,... perdurent, mais équilibre à trouver, ne pas se limiter au passé trop simple.
- 2e ex: rtp pour enregistrer flux audio en peu de ligne de code (1999) avec contraintes perso (15sec par fichier, enr continu), stockage hdd
- apache sling servlets (généricité) simplicité basé sur des standards. standards+spécialité 
- web components et templates html, cf web-platform-zoo sur https://open source.adobe.com

- penser: on peut faire plus simple. maintenance moins chère, mais plus d'ingénierie. nécessaire pour du code durable.
- mesurer complexité du code
- se demander s'il n'y a rien à enlever sans casser 
- non compatible cycle agile, travail de recherche sur une période négociée 



### test containers
- who: Clarence Dimitri Charles 
- tests intégration sans ressources partagées tq oracle dev.
- librairie java permettant de prov dB, etc.
- module officiel Spring boot 3, junit5
- maven org.testcontainers : oracle-xe junit-jupiter, ...
- déléguer cycle vie Springboot `@Springboottest +@Testcontainers,  @ServiceConnection @Bean OracleContainer .withReuse`
- @DynamicPropertySource
- AppTest : main : `SApp.from(App::main).with(...)`
- @RestartScope pour live reload sans reboot containers
- TcpProxy bean pour surcharger port au lieu d'utiliser un port aléatoire 
- couplé Docker : démon Docker 
- Tests plus longs 
- customisation possible docker compose



### C4 modeles architecture 
- who: Jérôme Gauthier 
- c4model.com 4 niveaux d'abstraction 
- zoom : context / container / component / code
- outil agnostique as-code : mermaid, c4builder, structurizr, ...
- cf exemple structurizr photo 
- fichier dsl -> container docker structurizr -> localhost:8080
- graphviz utilisé pour layout
- adapté pour plusieurs apps, pour contribuer, rétro modéliser 
- moins adapté pour monolithes




### duckentacle fabriquons le futur
- who: Rémi Forax José Paumard
- 




### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

### template
- who:
- 

