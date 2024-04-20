# Devoxx 2024

![crowd](/assets/2024_devoxx/devoxx_crowd.webp)

## Keynote 1 - Greatest mistakes
> Mark Rendle
- bugs les plus couteux de l'histoire (date sur 2 chiffres, etc)
- [youtube](https://www.youtube.com/watch?v=Y9clBHENy4Q)

## Keynote 2 - Monde shooté aux metaux
> who: Agnès Crepet Guillaume Pitron
- métaux rares : indium (tactile)
- 70 métaux dans un smartphone (~6 euros), 182kg matière pour en fabriquer un.
- Efforts Fairphone : env 25 métaux, meilleures conditions de travail,..


## Cybersecurité
> Sonia Seddiki
- dns tunneling : ping ne passe pas mais dans résolu. ex attaque solarwings 2020.
- échange de messages en fonction des IP résolues par le faux serveur, ou requête txt dans pour récupérer code malveillant, envoi credentials sur dns en Hexa puis ping dns avec URL contenant de Hexa.
- steganographie dans du texte e2808b efbbbf : espaces sans chasse
- Side Channel attacks : analyse conso CPU sur décryptage RSA pour en déduire la clé privée (algo square moins consommateur que algo square&multiply)


## Vers une architecture simple
> Bertrand Delacrétaz
- système compliqué difficile à remplacer 
- ex de simplicité : cmd linux, Lego, l'instrumient Kazoo,... perdurent, mais équilibre à trouver, ne pas se limiter au passé trop simple.
- 2e ex: rtp pour enregistrer flux audio en peu de ligne de code (en 1999) avec contraintes perso (15 sec max par fichier, enregistrement continu), stockage sur hdd
- Apache sling servlets (généricité) simplicité basé sur des standards. standards+spécialité 
- Web components et templates HTML, cf web-platform-zoo sur [le site Adobe](https://opensource.adobe.com/web-platform-zoo/)

- penser: on peut faire plus simple. maintenance moins chère, mais plus d'ingénierie. nécessaire pour du code durable.
- mesurer la complexité du code
- se demander s'il n'y a rien à enlever sans casser 
- Non compatible cycle agile : travail de recherche sur une période plus ou moins longue timeboxée.


## Test Containers
> Clarence Dimitri Charles 
- lancer des tests intégration sans ressources partagées telles qu'une base oracle de dev.
- librairie java permettant de provisionner une dB, d'autres services.
- module officiel intégré à Spring boot 3, JUnit5
- maven org.testcontainers : `oracle-xe junit-jupiter`, ...
- Déléguer au cycle vie Springboot `@Springboottest +@Testcontainers,  @ServiceConnection @Bean OracleContainer .withReuse, @DynamicPropertySource, ...`
- ApplicationTest avec son main : `SpringTestApp.from(SpringApp::main).with(...)`
- `@RestartScope` pour live reload sans reboot containers
- Bean `TcpProxy` pour surcharger le port utilisé sur la DB provisionée au lieu d'utiliser un port aléatoire 
- Couplé Docker : prérequis = avoir un démon Docker 
- Tests plus longs 
- Customisation possible des images style docker compose


## C4 modeles architecture 
> Jérôme Gauthier 
- c4model.com 4 niveaux d'abstraction. Zoom : context / container / component / code
- outil agnostique as-code : `mermaid, c4builder, structurizr, ...`
- cf exemple `structurizr` photo 
- fichier dsl -> container docker structurizr -> `localhost:8080` 
- (graphviz utilisé pour layout)
- adapté pour plusieurs apps, pour contribuer, rétro modéliser 
- moins adapté pour des applications monolithes


## Duckentacle : Fabriquons le futur
> Rémi Forax & José Paumard
- [dev.java](https://dev.java/)
- youtube [road to 21](https://www.youtube.com/playlist?list=PLX8CzqL3ArzVHAHWowaXwYFlLk78D8RvL)

### unnamed classes & patterns jep (463) 445 458 456
- jep 463 : classes implicites
- variables non utilisées sans nom. ex. var de lambda non utilisée : _ au lieu d'un nom inutile `(_, _) ->`
- classes sans nom : pas de déclaration public class ... dans le .java

### string template jep 465 -> 459
- [htmx](https://htmx.org/) : librairie js pour traiter la vue sans js, côté serveur
  - `hx-trigger, hx-post, hx-get, hx-target, ...`
  - vs `React` qui force l'utilisation nodejs côté serveur 
  - on veut un rendering serveur side sans utiliser de Javascript.
- `String Template Processor` (old JEP)
  - But : générer du HTML/XML.. sans avoir besoin d'escape et sans risquer des pb d'injection 
  - Choix d'un processeur : `str (string), fmt (string format), ComponentTemplateProcessor` return un `Renderer`.
  - = Interface qui valide des fragments (objets inclus dans le string), et escape correctement les valeurs 
- `String Templates` (new JEP)
  - __reimplementation en cours__, pas de preview en 23. pas en GA en LTS 25.
  - `public static Renderer render(StringTemplate tpl) {}`
  - Ex. XMLDom,...
  -`"$### ..."`
  - avantage des templates dans le code : auto complétion intégrée dans l'IDE.

### constructions: statements before super - JEP 447 (panama)
- Java22 preview
- Aujourd'hui pas de calculs avant d'appeler le super, par exemple avec des arguments calculés à passer 
- Dans le bytecode: l'appel au super est la 11e instruction après stockage des paramètres en mémoire 
- Ex. pouvoir faire `Objets.requireNonNull` avant de faire l'appel au super
- Serait nécessaire pour les ValueTypes (ex. `Optionals`), pour que le classe soit garantie non modifiable (cible : project Valhalla)

### (foreign functions) & Memory API - JEP 454
- Dispo en Java 22
- Foreign functions: exécuter du code non java exterieur.
- Mémoire off-heap non gérée par le GC
- Le GC compacte la mémoire, la déplace. Pas d'arithmétique sur les pointeurs possible 
- Avantages: stocker de la raw data, stockage direct depuis I/O, lecture et traitement rapides
- En Java 4: `ByteBuffer` limité à 2 Go, pointeur vers ByteBuffer géré par le GC ; et `sun.misc.Unsafe`
- Memory API : rapide, pas limité à 2 Go, gestion octet par octet, ou via structures (+safe), libération de la mémoire manuelle
- Lecture / Ecriture :

```java
Arena a = Arena.global(); // de base
.ofAuto
.ofConfined
.ofShared
segment s = a.allocate(80L, 1L);
s.allocate(10*4, 1L) // 10 entiers
// écriture :
s.setAtIndex(ValueLayout.Long, index, value);
index++ // le pointeur se déplace de 8 octets
// lecture :
s.getAtIndex(ValueLayout.long, index)
```
- `Arena`, `AutoCloseable`, contient `MemorySegment`,  contient des tableaux de int, des long, des struct, types mixés int/long/doubles/...
- On libère toute l'Arena d'un coup, pas par segment.
- Arena est un objet dans le GC, sa mémoire est adressée hors GC
- `shared` et `confined` : `.close()` la mémoire est libérée, Arena reste dans le heap. `confined` utilisé que par le thread qui l'a créée.
- `MemorySegment` : mémoire continue, on-heap:

```java
MemorySegment.array()
MemoryLayout.structlayout(ValueLayout.java_int.withname("x"), ...)
```
- `VarHandle` pour calculer

```java
MEM_LAYOUT.varHandle(MemoryLayout
   .PathElement.groupElement("x"))
   .withInvokeExactBehavior();

// écriture :
var_handle1.set(segment, 0, index, value1); var_handle2.set(segment, 0,index,value2)
// lecture :
var_handle.get(segment, 0, index)
```
- utilisable avec `FileChannel`. Use case possible: charger un milliard de données, les streamer, calculer: **6 secondes**.


## OpenRewrite
> Frédéric Mencier
- (!) données perdues, cf replay
- [www moderne.io](https://www.moderne.io/)
- [docs.openrewrite.org](https://docs.openrewrite.org/) ([recipes](https://docs.openrewrite.org/recipes))
- utilisé avec maven
- dryRun : génère un `rewrite.patch`
- REX estimation migration manuelle EAP vers Quarkus : 34ans 6 personnes : 6ans.
  - Ecriture recettes openrewrite custom (cookbook, cf photo)
  - 30 recettes du catalogue + 23 recettes custom
- nouvelle recette : 

```java
class MyRecette extends Recipes
public TreeVisotor getVisitor() {
return New JavaIsoVisitor(){
    @Override
    public J.ClassDeclzration visitclassdeclaration {
       r= super.visit...
       if ... {
           r.with...
       }
    }
}
```


## Testing CSS
> Fabien Zibi
- langage déclaratif, pas testable
- SCSS -> CSS -> affichage browser
- Vérifier le CSS généré (test auto sur fonctions scss)
- Vérifier le rendu d'un élément, d'une page 
- outils principaux : `jest, nodesass, ts/js, puppeteer ...`
- jest: `renderSync({...})` 
- `npm run test:unit --testName`
- Snapshot testing : on crée fichier référence pour vérifier de la non-régression. `expect(css_string).toMatchSnapshot('snapshot_name')`. fichier généré lors du premier test. `-- testName -u` pour maj Snapshot.
- test de rendu: ex tester que tous les boutons ont la même hauteur. `await.page.evaluate... btn: queryselector..getboundingsclientrect.`
- Vérifier screenshot : pas le test le plus pertinent. Utile quand mise à jour de librairie, utilisation ponctuelle. `toMatchImageSnaphot`
- Vérifier les urls (fonts, images, etc) dans les CSS, `existSync`
- `puppeteer` peut simuler différents navigateurs 


## BOF Gitlab past present future 
> JP Baconnais, *
- Depuis 2013 ; utilisé par 25k users
- En 2014 100k users
- La plateforme propose une 50aine de services (manage,plan,create,verify,packagé,release,configure,monitor,secure)
- catalog: réutilisabilité, include: component: ... (avantage = testable)
- Gitlab CI local outil indépendant de Gitlab mais pouvant aider
- éviter only et except, conflits avec rules
- dora metrics sur ultimate (lead Times sur les MR, etc)
- Gitlab Duo, with AI : autocompletion, summary, modèles personnalisés 
- Gitlab intégré à Google Cloud 
- Gitops FluxCD communautaire 
- evols project management (jira)
- Remote développement
- Forts investissement sur l'IA 


## Keynote 1 - Etat du monde en 2100 : Rapport Meadows
> Anatole Chouard 
- youtube: [chez Anatole](https://www.youtube.com/c/chezanatole)
- Club of Rome (Suisse), 1968, comprendre impacts sur le futur. dynamique des systèmes 
- 5 systèmes : population, ressources, industrie, pollution, système alimentaire 
- modélisation de 5 courbes entre 1970 et 2100 selon efforts portés sur utilisation des ressources etc. Chute des ressources, baisse population, etc.
- Calculs simplifiés en raison des capacités de calculs de l'époque
- Rapport revu et 2008 et courbes confirmées.
- Nouveau rapport `Earth For All` en 2022 avec nouveaux indicateurs, peut-être moins objectif.


## Keynote 2 - Cybersecurité 
> Guillaume Poupard (ancien directeur ansii, docaposte)
- exemple zone de bon droit : Crimée, officiellement ukrainienne mais qui n'a pas possibilité d'aider les autres pays sur ce territoire. 
- livre blanc sécurité et défense nationale, 2008. aborde cyber, toutes les menaces qui peuvent venir sur le France (pandémie,etc).
- loi portée : opérateurs d'importance vitale c doivent se protéger des attaques cyber.
- ex TV5Monde 2015 écran noir revendication djihadiste, créée par pays de l'Est.
- ex Ukraine



## LangChain4j LLMs - Hands on lab
> Marie Alice Blete Lize Raes Vincent Peres
- revoir présentation slides d'hier 
- [Springboot exemple](https://github.com/langchain4j/langchain4j-examples/tree/main/spring-boot-example/src/main/java/dev/langchain4j/example)
- readme indique liste providers compatibles autres que openai
- gitpod.io#lien-vers-repo
- [Lab github](https://github.com/LizeRaes/lc4j-lab-intro-assignments) cf README.md
- [Lab github solution](https://github.com/LizeRaes/lc4j-lab-intro-solution)
- avoir une clé openAi, clé "démo" permet quelques tests.
### Converser avec un modèle
- main objetcts: `ChatLanguageModel, OpenAiChatModel, OpenAiChatModelName, StreamingChatLanguageModel, StreamingResponseHandler, `, `model.generate("dis bonjour")`
- model.temperature: vers 0 juste, vers 1 plus créatif.
- streaming : permet de streamer une réponse longue
- model 4.0 plus fort mais plus cher, pas souvent utile 
- abonnement chatgpt (mensuel) != abonnement openAi(à la conso)
### Générer des images
- `ImageModel, OpenAiImageModel, model.generate("image description"), `
- URL générée
- modelname dall-e-2, ...
- `persistTo` pour sauver localement 
### Feedbackanalyzer
- feedback.shoggi.monster/feedback.html
- voir résultats analyse photos 
### aiServices
- `ChatAssistant AiServices.create(MyInterfaceTranslator.class), @SystemMessage("you are a professional translatorinto {{lang}}"). @UserMessage("translate this texte: {{texte}}"), @V, AiMessage`
- orienté Service pour spécialisation (méthode translate, summarize, extractFateTime, ...)
- @SystemMessage : instruction générale 
- @V injection des valeurs pour les templates, @UserMessage
- typage des retours en Liste<String>, LocalDateTime, etc.
### mémoire 
- pratique pour les sessions de chat
- `ChatMemory, MessageWindowChatMemory.withChatMessages(10), ChatLanguageModel, Assistant`
- `assistant.chat("i like chocolate"); assistant.chat("qu'est-ce que j'aime ?");`
- créer une fausse mémoire pour entraîner le modèle 
- `Tokenizer, OpenAiTokenizer("gpt-3.5-turbo"), TokenWindowChatMemory`
- maxTokens;
- bien restreindre le SystemMessage pour éviter l'injection de prompt.
- coûts: mémoire renvoyée au modèle à chaque appel, api stateless. fine tuning possible sur openAi directement mais plus grosse artillerie.
- créer un SystemMessage pour identifier le type de personne qui va répondre

```java
chatMemory.add(systemMessage);
chatMemory.add(UserMessage.from("input..."))
chatMemory.add(AiMessage.from("réponse..."))
AiServiceWithMemory assistant = AiService.builder...;
assistant.chat("my message")
```

### tools
- `@Tool, aiService.tools()` sur methodes. nom méthode et description interprétées.
- define tools pour trouver des méthodes à appeler si conditions réunies

### rag
- `EmbeddingModel, InMemoryEmbeddedStored, EmbeddingStoreInjector`
- injection de documentation 
- ex. Feedbackanalyzer
- https://github.com/LizeRaes/feedback-analyzer
![feedback analyzer](/assets/2024_devoxx/feedback_analyzer.webp)
![feedback_analysis](/assets/2024_devoxx/feedback_analysis.webp)


## ADR
> Sylvain Aurat
- architecture, important décision record, créé 2011
- rendre compte, focaliser sur le pourquoi 
- se protéger (turn-over, retrouver contexte)
- offensif : base de connaissances, planification des changements 
- piloter 
- pas (que) pour architectes
- choix librairie, etc.
- conservation historique des ADR 
![adr format](/assets/2024_devoxx/adr_format.webp)
- Beaucoup de formats existent.
- +justifications (PB envisageable et pourquoi non bloquant, ...), +alternatives (défensif)
- stockage : git markdown. 
- ia peut aider à proposer solutions 
- contexte : limites, coûts, charges, besoins 
- conséquences : besoin de se former, utilisable de suite, risques, etc.
![adr example](/assets/2024_devoxx/adr_example.webp)


## Infra sans secrets
> Thibault Lengagne
- récupérer slides
### zéro credentials
- plus de leak plus d'outils type git guardian, gitleaks... nécessaire 
- privilégier les mdp générés à la volée aux mdp long terme.
- cred valable 15 min
- single sign on
- auth -> autor
- token + refresh token ald pwd
- un seul mdp sso à se souvenir 
- clés d'Api de services externe restent
### secrets développeur 
- webapp, cloud IAM, tools.
- sso single point of failure (mep double authent)
- oauth2-proxy permet de se pluguer sur sso et mettre barrière entre sso et outils on premier (bdd,...)
- boundary + vault
![vault1](/assets/2024_devoxx/vault_1.webp)
![vault2](/assets/2024_devoxx/vault_2.webp)


### secrets cicd
- secrets en clair dans code vs mécanisme cicd 
- outils pour scanner gitlabhub
- sops (mozilla) pour chiffrer si nécessaire, privilégier vault depuis application directement
- cloud providers : oidc. ex. autoriser repo sur branche donnée, rôle IAM.

### secrets workload
- vault operator
- vault csi provider
- vault-agent + vault: Sync les secrets et les gère en var d'environnement dans l'application 
- comparaison des outils sur site hashicorp
- DB : créer un rôle. vault: générer un user/MDP à la volée avec le rôle 



## Propre vm avec compilation JIT
> Olivier Poncet 
- https://github.com/ponceto/rpn-calculator-with-jit
- jit : trafsfo lgg en lg machine à la volée 
- avantages :
  - augmentation portabilité 
  - acc interpréteur de code
  - translation dynamique de code
- ahead of Time : compilation c, c++, ...
- juste un Time : bytecode ou autre, transfo binaire à l'exec. 2nd fois directement binaire 
- aot + jit = java
- bytecode : instr codée sur un octet (OpCode)
![bytecode1](/assets/2024_devoxx/bytecode_1.webp)
![bytecode2](/assets/2024_devoxx/bytecode_2.webp)
- ISA: architecture matérielle du processeur
- ABI: def types de données, registres 
- bien connaître ISA et ABI pour écrire le compilateur, spécifications x86-64 à connaître.
- prolog prépare stack mémoire 
- corps stock fct dans mémoire et appeler mémoire 
- eoilog restaure la pile



## API Vector programmation parallèle SIMD
> José Paumard 
- bit.ly/vector-api
- en preview jep 469 8e incubation, stable et en version finale en Valhalla 
- principe utilisé par le jit depuis java5
- https://speakerdeck.com/josepaumard
- API de calcul 
- SIMD: single instruction multiple data
- stream parallel , bcp données et adaptées à parallélisation 
- arrays.parallelsort
- toujours bencher les perfs quand on fait du parallèle sur équiv. prod
- stream et array : api découpe et traite dans deux threads, subdivisions succ. pls hypothèses : fct associatives, partage en deux pas garanti sur hashsets. avoir des coeurs dispos, ne pas utiliser i/o dans stream.
- SIMD est différent. pas de multithread.
- CPU SIMD. plusieurs unités [ALU reg1 reg2 et result] 1 LOAD = n UC chargent en mm temps
![crowd](/assets/2024_devoxx/simd_1.webp)
- algo écrite sur vecteurs au lieu de nombres.
- chaque CPU a son implémentation, connaître son CPU.
- pas de concurrence, pas de multithread 
- on peut cumuler stream et parallélisation SIMD 
- traiter 32bitd en parallèle=traiter 4long en parallèle 
```java
specis=IntVector.SPECIES_PREFERRED
IntVector.fromArray(specis, array, 0)
v1.add(v2)  // un cycle CPU 
  .intoArray(result,0)
```
- large arrays : use for loops de 8 et 8 (int), selon taille du registre CPU : `species.length()`
- si tableau < nb registres : `mask = species.indexInRange` masking pas supporté par tous les CPU.
- `species.loopBound` pour les proc sans masking
- lane-wise opérations // crosslane opérations (comparer des vecteurs, `v.reduceLanes`)
- utiliser jnh pour benchmarker
- use case: algèbre linéaire, réseau neurones, ai,...
- projet Babylon : traitements GPU openjdk.
- calcul matriciel manuel 


## Kafka SQL Parquet 
> François Teychene
### duckdb:
- jdbc:duckdb avec parquet : 7sec 1miliard de tuples
- ex. `select * from fichier*.parquet`
- ex. `select * from http://Host:port/fichier*.parquet`
- on peut donc distribuer la donnée 
- `copy (select...) to file.parquet`
### gestion sécurité et ownership
- clickhouse-server
- conduktor-sql faire du SQL sur données Kafka en conservant acl et sécurité rbac
