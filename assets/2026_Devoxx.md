# Devoxx 2026

![crowd](/assets/2026_devoxx/devoxx_2026.png)

## Le programme suivi

<details><summary>Making of</summary>

- Utilisation de l'appareil photo du téléphone pour prendre des captures d'écrans et des photos.
- Saisie en live dans l'outil Joplin pour mixer photos et textes, puis export en markdown et migration vers git.
- Redécoupage et redimensionnement des photos en 900 px de large max
</details>

- [Programme devoxx](https://m.devoxx.com/events/devoxxfr2026/schedule)

## Quelques points clés

Résumé:

- Keynotes: IA centric, utilisation de l'IA pour prototyper, self-ware, intégration aux outils Figma, Lovable, Cursor, ...
  - Plus philosophique, la condition humaine à l'ère de l'IA, et les impacts des infrastructures physiques sur nos territoires.
  - Quelques lectures : `l'IA expliquée aux humains` de Jean-Gabriel Ganascia, et le `Droit à la paresse` de Paul Lafargue.

- Coder avec l'IA
  - Agentic coding, nouveaux modes de travails, agentic-first (`SDD; Specification Driven Development`) ; OpenSpec
  - Bien définir ses skills, ses `AGENT.md`, `CLAUDE.md`, etc. pour éviter les problèmes de contexte et d'hallucinations.
  - Le `Context Engineer` un métier d'avenir
  - Les agents avec Docker (leur couteau Suisse) ; accès au GPU facilité depuis Docker Compose
  - `Claude` particulièrement mis en avant

- Développement Java
  - Architecture hexagonale, The Hive Pattern pour préparer un monolithe à évoluer vers des micro-services.
  - Value types pour les performances en mémoire
  - Gestion des performances dans Kubernetes ; outils `Flow` et `Kind` pour faciliter le développement local, pitfall compilation native
  - Performances autour de Spring
  - Des quizz pour se détendre

- Autres : démo sur les passkeys, gérer la montée en charge de gitlab, OSINT

## Jeudi 23 avril 2026

<details><summary>Les Keynotes</summary>

![Screenshot_20260423_0900_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_0900_1.png)
![Screenshot_20260423_0935_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_0935_1.png)
- Lovable pour prototyper, ou cursor.
- Figma en moins compliqué.
- Créer des skills pour les PM.
</details>
<details><summary><strike>Façonner la pertinence et la résilience de notre expertise au délà de 2030</strike></summary>

![Screenshot_20260423_1030_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1030_1.png)
- Non assisté
</details>
<details><summary>De 1000 à 5000 utilisateurs: scaler Gitlab</summary>

![Screenshot_20260423_1030_2.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1030_2.png)
![PXL_20260423_083910656~2.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_083910656~2.jpg)
![PXL_20260423_085147205.MP~2.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_085147205.MP~2.jpg)
</details>
<details><summary>Agentic coding, nouveau territoire tu Platform engineering</summary>

![Screenshot_20260423_1135_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1135_1.png)
![PXL_20260423_094052717~2.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_094052717~2.jpg)
![PXL_20260423_094151867.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_094151867.jpg)
![PXL_20260423_094252044.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_094252044.jpg)
- Cf Claude marketplace.

![PXL_20260423_100449422.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_100449422.jpg)
</details>
<details><summary>Les passkeys</summary>

![Screenshot_20260423_1300_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1300_1.png)
- Webauthn (w3c)
- Facteurs biométriques.
- Ex bit warden.

![PXL_20260423_110749051.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_110749051.jpg)
![PXL_20260423_110849352.MP~2.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_110849352.MP~2.jpg)
![PXL_20260423_111008097.MP~2.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_111008097.MP~2.jpg)
- App passkeys-debugger.io sur internet

![PXL_20260423_111621559.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_111621559.jpg)
</details>
<details><summary>The Hive : Coder un monolithe prêt pour les microservices</summary>

![Screenshot_20260423_1330_3.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1330_3.png)
- https://gitlab.com/beyondxscratch/hive-pattern

![PXL_20260423_113641351.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_113641351.jpg)
- Stratégie de modularization dans le domaine.
- Regrouper domaines métiers.

![PXL_20260423_113912462.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_113912462.jpg)
- Isoler sous domaines feuilles (sans dépendances)
- Ne pas partager la db ...

![PXL_20260423_114228913.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_114228913.jpg)
![PXL_20260423_114655457.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_114655457.jpg)
![PXL_20260423_114841879.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_114841879.jpg)
![PXL_20260423_115256149.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_115256149.jpg)
![PXL_20260423_115550009.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_115550009.jpg)
- Inproc package pour les infra intérêt modules

![PXL_20260423_115811775.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_115811775.jpg)
![PXL_20260423_120057111.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_120057111.MP.jpg)
- Application context et shared kernel séparés également.

![PXL_20260423_120240550.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_120240550.jpg)
- Inclure les modules dans class path.
- @AutoConfiguration : spring scanne ce qu'il y a à injecter.
- Extraction des modules, voir consommation des modules (CPU, mem)
- Ajouter un contrôleur rest au futur micro service
- Un client http côté main app à la place du inproc adapter
- Nécessite url du micro service, à paramétrer dans l'appli.
- Hive = ruche = modules préparés pour devenir des micro services.
- Yaml: Préciser port server, plus besoin de charger dans class path,

![PXL_20260423_121712414.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_121712414.jpg)
</details>
<details><summary><strike>Meet & Chip - La rencontre sous tension</strike></summary>

![Screenshot_20260423_1330_4.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1330_4.png)
- Non assisté
</details>
<details><summary><strike>Observability from scratch with OpenTelemetry</strike></summary>

![Screenshot_20260423_1330_5.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1330_5.png)
- Non assisté
</details>
<details><summary>Docker Agent - Comment simplifier la création d'agents IA</summary>

- https://github.com/docker/docker-agent

![Screenshot_20260423_1435_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1435_1.png)
![PXL_20260423_124219259.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_124219259.jpg)
- docker agent run pirate.yaml:

![PXL_20260423_124659101.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_124659101.jpg)
- Claude consommerait beaucoup de tokens pour faire la même chose.

![PXL_20260423_124821573.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_124821573.jpg)
![PXL_20260423_125622573.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_125622573.jpg)
![PXL_20260423_125743312.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_125743312.jpg)
![PXL_20260423_131617957.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_131617957.MP.jpg)
</details>
<details><summary>Quizz Java de José Paumard et Jean-Michel Doudoux</summary>

![Screenshot_20260423_1540_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1540_1.png)
- Jose Paumard : https://dev.java

![PXL_20260423_135953312.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_135953312.jpg)
![PXL_20260423_140431813.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_140431813.MP.jpg)
![PXL_20260423_141540032.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_141540032.MP.jpg)
![PXL_20260423_142231614.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_142231614.MP.jpg)
</details>
<details><summary><strike>Meet with Langchain4j-CDI</strike></summary>

![Screenshot_20260423_1700_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1700_1.png)
- Non assisté
</details>
<details><summary>Domptez vos agents : Agents.md et Context Engineering</summary>

- https://medium.com/@b-fontaine

![Screenshot_20260423_1700_2.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1700_2.png)
- `claude --dangerously-skip-permissions`
- Nouvelle feat sans agent. MD
- Parcourt tout le code

![PXL_20260423_150817330.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_150817330.MP.jpg)
- Causes dégradations perfs
- Trop de tokens

![PXL_20260423_150942366.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_150942366.jpg)
- Agents MD standard et lui nativement par les agents. Porte les conventions, décisions d'architecture, etc. Adaptateur pour l'outil.
- Claude.md adaptateur pour l'outil, il importe agents.MD avec @Agents.md
- Ne pas dépasser 200l par fichier

![PXL_20260423_151407788.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_151407788.jpg)
- A placer à la racine du projet et dans les répertoires, ex un fichier spécifique front, un autre pr le back, ...

![PXL_20260423_151901978.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_151901978.jpg)
- /compact pour garder les décisions en supprimant le bruit.
Passage de relais d'une phase à l'autre

![PXL_20260423_152307754.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_152307754.jpg)
- Prompt = ordre de mission, doit être précis et contexte fermé

![PXL_20260423_152402421.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_152402421.jpg)
- Ex 122k tokens avant. 59k tokens après ; 14min avant, 4 min après

![PXL_20260423_152816184.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_152816184.MP.jpg)
- Cas d'hallucinations : supprimer la session.

![PXL_20260423_152946216.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_152946216.MP.jpg)
![PXL_20260423_153146506.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_153146506.MP.jpg)
</details>
<details><summary><strike>Spring Native et Boot 4.0</strike></summary>

![Screenshot_20260423_1750_1.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1750_1.png)
- Non assisté
</details>
<details><summary>ClaudeCode.proTips</summary>

![Screenshot_20260423_1750_2.png](/assets/2026_devoxx/Jeudi/Screenshot_20260423_1750_2.png)
- Installation agent Windows : `irm https://claude.ai/install.ps1`
- `/doctor` pour vérifier son install
- `/theme` ; `/color` ; `/statusline <langage naturel>`
- `/tui` default ; `/tui fullscreen` (plus adapté aux longues sessions)
- `/focus` élimine le bruit (échanges de Claude code)
- `/rename` (pour nommer la session)
- `/resume` (récupérer une session) ; custom setting `cleanupPeriodDays` pour changer dispo 30 jours
- `/powerup` (didacticiel)
- Lancer une `!commande_bash` directement
- `@path-to-file explique moi cette fonction` (économie de tokens)
- `claude --add-dir` pour ajouter répertoires 
- `/init` : analyse code base, archi, conventions, générer `claude.md`, peut être localisé dans son home également
- `/memory` pour consulter et modifier ce que Claude a mémorisé de lui-même sur le projet
- `/compact` pour compresser l'historique
- `/context` pour diagnostiquer
![PXL_20260423_160725487.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_160725487.MP.jpg)
- `/voice` pour dictée ses prompts
- `Shift+Tab` pour passer en mode **plan** : Iterer avant de modifier le code
- `Haiku` simple et rapide , `Sonnet`, `Opus` complexe et avancé
- `/model opusplan` pour utiliser opus en mode plan uniquement
- `/effort` low medium, high, xhigh, max... A un impact sur les coûts
- `EscEsc` Zfficher les messages précédents
- `/rewind` pour rembobiner
- Glisser les screenshots plutôt que de décrire un problème
- `/fork` pour tenter une autre approche, copie la session vers une nouvelle session. Retour avec `/resume`
- `/btw` poser des questions courtes pendant une autre tâche longue
- `/export` ; `/copy` ; `/diff` ; `/undo`...
- `/review`
- `/simplify` trois agents qui se mettent d'accord et appliquent les modifications directement
- `/insights` analyse les sessions et générer un rapport personnalisé sur comment on utilise l'outil. Identifier pertes de temps, propose optimisations, etc.
- `/hooks` automatiser des actions répétitives
- `/loop 5m` vérifie si le déploiement est terminé
- `/schedule` persiste après fermeture du terminal
- Skills:
![PXL_20260423_162112301.MP.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_162112301.MP.jpg)
- MCP:
![PXL_20260423_162255883.jpg](/assets/2026_devoxx/Jeudi/PXL_20260423_162255883.jpg)
</details>

## Vendredi 24 avril 2026

<details><summary>Les Keynotes</summary>

![Screenshot_20260423-170108.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-170108.png)
- Philosophe et ingénieur.
- l'IA expliquée aux humains (livre)
- Droit à la paresse, livre de Paul Lafargue.

![Screenshot_20260423-190321.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190321.png)
- Chercheur sociologie.
- Impacts infrastructure physiques sur notre territoire.
</details>
<details><summary>Java: Les Value Types ne sont pas complexes</summary>

![Screenshot_20260423-190430.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190430.png)
![PXL_20260424_083518846.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_083518846.jpg)
- value record au lieu de record : mêmes perfs que type primitif
- Valhalla, depuis 2014.
- Code like a class, works like an int.
- Avoir l'abstraction sans en payer le prix.
- JEP 401.

![PXL_20260424_084438364.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_084438364.MP.jpg)
- `@ValueBased` objets seront convertis en value class avec Valhalla. On n'aura plus de coût de boxing.
- L'opérateur == retournera true pour tous les integer, même hors cache.
</details>
<details><summary>Docker Compose votre Dev Toolkit pour AI et Cloud</summary>

![Screenshot_20260423-190531.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190531.png)
- https://docs.docker.com/ai
- Répondre à : Compliqué d'accéder aux ressources gpu depuis containers.

**Docker model runner**

![PXL_20260424_093928198.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_093928198.MP.jpg)
![PXL_20260424_094024150.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_094024150.jpg)
![PXL_20260424_094055296.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_094055296.jpg)

**Docker offload (payant)**
- Si besoin de plus de ressources ou de gpu.
- Bascule vers machine cloud, sans modifier le compose.
- Activé depuis docker desktop.

**MCP gateway**

![PXL_20260424_095257809.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_095257809.jpg)
- Démarre serveurs MCP dans des containers.

![PXL_20260424_095548959.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_095548959.MP.jpg)
![PXL_20260424_095705147.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_095705147.MP.jpg)
- Demo docker hub: https://gloursdocker/zephyr-app

**Compose bridge**
- Convertir l'application en kube yml (voir devoxx 2025)

**Provider services**
- Étendre compose sur phases démarrage et arrêt (cloud)
- Services gérés par autre chose qu'un container docker.

![PXL_20260424_101926151.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_101926151.jpg)
</details>
<details><summary>OSINT : Trouver ce qui ne devrait pas être trouvé</summary>

![Screenshot_20260423-190720.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190720.png)
- Open Source intelligence
- Ex chercher sur maps à partir de photos, annonces etc
- Ex généalogie
- Osint branche de cyber sécurité.
- Ex Strava leaks: détecter bases militaires, porte avions,..

![PXL_20260424_104113923.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_104113923.jpg)
- Quelques outils, jeux osint :

![PXL_20260424_104953526.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_104953526.MP.jpg)
</details>
<details><summary><strike>Prolongez la vie de vos dashboards</strike></summary>

![Screenshot_20260423-190810.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190810.png)
- Non assisté
</details>
<details><summary>Kubernetes et la JVM</summary>

![Screenshot_20260423-190938.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-190938.png)
![PXL_20260424_113738825.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_113738825.MP.jpg)
- `flox init`: créer un environnement.
- `flox activate`: Utiliser un environnement particulier

![PXL_20260424_113838712.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_113838712.MP.jpg)
- `kind create cluster` (devcluster.yml)
- Kaniko utilise container pour construire une image.

![PXL_20260424_114729760.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_114729760.jpg)
- Utiliser, afficher les ergonomics

![PXL_20260424_115642528.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_115642528.MP.jpg)
- Containers en serial gc car un seul CPU, au lieu du G1.
- Avant java 10 maintenir adequation Xmx et taille du container

![PXL_20260424_120012675.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_120012675.jpg)
- Probes spring boot non activées par défaut
- Graceful shutdown: `server.graceful-shutdown`
- Temps de démarrage jvm :
- Class Data Sharing

![PXL_20260424_120708898.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_120708898.MP.jpg)
- Projets Leyden openjdk

![PXL_20260424_120855532.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_120855532.MP.jpg)
![PXL_20260424_120934798.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_120934798.jpg)
- Graalvm native: on perd réflection, proxy dynamique,... Compilation longue et coûteuse

![PXL_20260424_121028367.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_121028367.jpg)
![PXL_20260424_121134433.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_121134433.jpg)
</details>
<details><summary><strike>Feature Flags : Aide ou Frein</strike></summary>

![Screenshot_20260423-191017.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191017.png)
- Non assisté
</details>
<details><summary><strike>Vive le platform engineering</strike></summary>

![Screenshot_20260423-191048.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191048.png)
- Non assisté
</details>
<details><summary><strike>Autorisations avec Spring Security</strike></summary>

![Screenshot_20260423-191140.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191140.png)
- Non assisté
</details>
<details><summary><strike>Vous croyez connaître Git</strike></summary>

![Screenshot_20260423-191220.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191220.png)
- Non assisté
</details>
<details><summary><strike>De Java à l'IA : construisez votre premier système d'agents intelligents</strike></summary>

![Screenshot_20260423-191409.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191409.png)
- Non assisté
</details>
<details><summary>Éloge de la simplicité</summary>

![Screenshot_20260423-191454.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191454.png)
- Type Keynote
- Compare planning IT et gestion des urgences à l'hôpital
</details>
<details><summary><strike>Iceberg du CSS : Plongée dans les abysses du moteur de rendu</strike></summary>

![Screenshot_20260423-191540.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191540.png)
- Non assisté
</details>
<details><summary>Performances du backend Spring</summary>

![Screenshot_20260423-191633.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191633.png)
- https://beaufume.fr
- `jpa.properties.hibernate.log_slow_query=100`
- `hibernate.generate_statistics=true` (rapport html)

![PXL_20260424_134809533.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_134809533.jpg)
![PXL_20260424_135144228.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_135144228.MP.jpg)
![PXL_20260424_135256893.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_135256893.jpg)
![PXL_20260424_135407009.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_135407009.jpg)
![PXL_20260424_135657330.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_135657330.jpg)
![PXL_20260424_140049784.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_140049784.jpg)
![PXL_20260424_140328137.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_140328137.jpg)
![PXL_20260424_140602592.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_140602592.MP.jpg)
- Cache:

![PXL_20260424_140956419.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_140956419.jpg)
- Virtual threads

![PXL_20260424_141041514.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_141041514.MP.jpg)
- Measures
- Connaitre point de rupture de son application
- Gatling, peut-être lancé via CLI, ou même maven

![PXL_20260424_141438891.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_141438891.MP.jpg)
- Durée des tests Spring

![PXL_20260424_141646576.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_141646576.MP.jpg)
- Attention aux annotations différentes, qui créent des contextes différents.
- Un contexte différent à chaque fois qu'on ajoute des mockitobean

![PXL_20260424_141916014.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_141916014.MP.jpg)
- Librairie mockinbean
</details>
<details><summary><strike>Jdeps, JLinks et les layers : Faites perdre du poids à vos images Docker Javas</strike></summary>

![Screenshot_20260423-191723.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191723.png)
- Non assisté
</details>
<details><summary><strike>JCStress: Plonger au coeur de la concurrence et des systèmes distribués en Java</strike></summary>

![Screenshot_20260423-191817.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191817.png)
- Non assisté
</details>
<details><summary><strike>Vibe-coder du lourd avec Kilocode</strike></summary>

![Screenshot_20260423-191908.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191908.png)
- Non assisté
</details>
<details><summary>Error Prone: L'arme secrète de Google pour des lignes de code sans bug</summary>

![Screenshot_20260423-191940.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-191940.png)
- Exemple:

![PXL_20260424_150419347.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_150419347.MP.jpg)
![PXL_20260424_150851845.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_150851845.jpg)
- Sémantique ,
- Utilisation des API (java time etc),
- Deadlocks , concurrence
- Performance,
- Code mort

![PXL_20260424_151616309.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_151616309.MP.jpg)
- Possibilité d'intégrer ses propres règles métiers, interdire des API sensibles, vérifier les logs quality,...
- Implementer BugChecker

![PXL_20260424_152247893.MP.jpg](/assets/2026_devoxx/Vendredi/PXL_20260424_152247893.MP.jpg)
- Certains BugChecks open Source.
- On peut désactiver certaines règles
</details>
<details><summary><strike>70 jours.homme sauvés grâce à gemini-cli</strike></summary>

![Screenshot_20260423-192015.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-192015.png)
- Non assisté
</details>
<details><summary>Les Cast-codeurs</summary>

![Screenshot_20260423-192055.png](/assets/2026_devoxx/Vendredi/Screenshot_20260423-192055.png)
- Conférences à conseiller:
  - Top 10 event driven architecture pitfalls
  -  mesurer l'immesurable
  -  votre second cerveau IA sans perdre votre âme
  -  le futur du logiciel libre
  -  retrouver l'étincelle un reboot de carrière
- Créer des café IA pour démystifier l'IA
- 4972 participants au devoxx
</details>
