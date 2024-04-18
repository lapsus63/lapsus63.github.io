# Devoxx 2024

## keynote 1 greatest mistakes
- who: mark rendle
- bugs les plus couteux de l'histoire (date sur 2 chiffres, etc)

## keynote 2 monde shooté metaux
- who: Agnès crepet guillaume pitron
- indium (tactile)
- 70 métaux smartphone, 182kg matière 
- fairphone env 25 métaux, meilleures conditions de travail,..


## cybersecurité
- who:Sonia seddiki
- dns tunneling : ping ne passe pas mais dans résolu. ex attaque solarwings 2020.
- échange de messages en fonction des IP résolues par le faux serveur, ou requête txt dans pour récupérer code malveillant, envoi credentials sur dns en Hexa puis ping dns avec URL contenant de Hexa.
- steganographie texte e2808b efbbbf espaces sans chasse
- side Channel attacks : analyse conso CPU sur décryptage RSA pour déduire clé privée (square moins consommateur que square&multiply)


## architecture simple
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


## test containers
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



## C4 modeles architecture 
- who: Jérôme Gauthier 
- c4model.com 4 niveaux d'abstraction 
- zoom : context / container / component / code
- outil agnostique as-code : mermaid, c4builder, structurizr, ...
- cf exemple structurizr photo 
- fichier dsl -> container docker structurizr -> localhost:8080
- graphviz utilisé pour layout
- adapté pour plusieurs apps, pour contribuer, rétro modéliser 
- moins adapté pour monolithes



## duckentacle fabriquons le futur
- who: Rémi Forax & José Paumard
- dev.java
- youtube road to 21

### unnamed classes & patterns jep (463) 445 458 456
- jep 463 : classes implicites
- var sans nom. ex. var de lambda non utilisée : _ au lieu d'un nom inutile `(_, _) ->`
- classe sans nom : pas de déclaration public class ... dans le .java


### string template jep 465 -> 459
- htmx librairie js pour traiter la vue sans js, côté serveur
  - hx-trigger, hx-post, hx-get, hx-target, ...
  - React force utilisation nodejs côté serveur 
  - on veut rendering serveur side sans utiliser JavaScript.
- string template processor (old jep)
  - générer HTML/XML.. sans avoir besoin d'escape et sans PB d'injection 
  - processeurs : `str (string), fmt (format), ComponentTemplateProcessor` return un `Renderer`.
  - interface qui valide des fragments (objets inclus dans le string), et escape correctement les valeurs 
- string templates
  - reimplementation en cours, pas de preview en 23. pas en GA en LTS 25.
  - `public static Renderer render(StringTemplate tpl) {}`
  - Ex. XMLDom,...
  -`"$### ..."`
  - avantage auto complétion intégrée car intégré au code.


### constructions: statements before super jep 447 (panama)
- java22 preview
- pas de calculs avant d'appeler le super, par exemple avec des arguments calculés 
- bytecode: 11e instruction après stockage des paramètres en mémoire 
- ex. pouvoir faire objets.requirenonnull avant appel au super
- nécessaire pour valueTypes ex. Optionals, pour que le classe soit garantie non modifiable (project Valhalla)


### (foreign func) & memory api jep 454
- dispo java22
- foreign func: exécuter code non java
- mémoire off heap non gérée par le gc
- le gc compacte la mem, la déplace. pas d'arithmétique sur pointeurs possible 
- avtg: stockée raw data, stockage direct i/o, lecture et traitement rapides
- java4: bytebuffer, limité 2go, pointeur vers bytebuffer géré par le gc; sun.misc.Unsafe
- memory api : rapide, pas limité à 2go, octet par octet, ou via structures (+safe), libération mémoire manuelle
- lecture/écriture :
```java
Arena a = Arena.global(); // de base
.ofAuto
.ofConfined
.ofShared
segment s = a.allocate(80L, 1L);
s.allocate(10*4, 1L) // 10 entiers
// pls APIs :
s.setAtIndex(ValueLayout.Long, index, value);
index++ // pointeur se déplace de 8 octets
// lecture
s.getAtIndex(ValueLayout.long, index)
```
- Arena, autocloseable contient MemorySegment contient des tableaux de int, des long, des struct, types mixés int/long/doubles/...
- on libère toute l'aréna d'un coup, pas par segment.
- Arena dans gc, mémoire adressée hors gc
- shared et confined .close la mémoire est libérée, Arena tjrs dans le heap. confined utilisé que par thread qui l'a créée.
- MemorySegment : mémoire continue, on heap:  ```java
MemorySegment.array()
MemoryLayout.structlayout(ValueLayout.java_int.withname("x"), ...)
```
- VarHandle pour calculer
```java
MEM_LAYOUT.varHandle(MemoryLayout
   .PathElement.groupElement("x"))
   .withInvokeExactBehavior();

// écriture :
var_handle1.set(segment, 0, index, value1); var_handle2.set(segment, 0,index,value2)
// lecture :
var_handle.get(segment, 0, index)
```
- utilisable avec filechannel. Use case: charger un milliard de données, les streamer, calculer: 6 secondes.


## OpenRewrite
- who: Frédéric Mencier
- (!) données perdues, cf replay
- www moderne.io
- https://docs.openrewrite.org (/recipes)
- utilisé avec maven
- dryRun : rewrite.patch
- cf image photo
- estimation migration manuelle eao vers quarkus : 34ans 6 personnes : 6ans.
- écriture recettes openrewrite custom (cookbook, cf photo)
- 30 recettes du catalogue + 23 recettes custom
- nouvelle recette : 

```java
class MyRecette extends Recipes

public TreeVisotor getVisitor() {
return New JavaIsoVisitor(){
    @Override
    public J.ClassDeclzration visitclassdeclaration {
   r= super.visit...
   if ...
      r.with...
   
}
}

}
```


## testing css
- who: Fabien Zibi
- langage déclaratif, pas testable
- CSS -> CSS -> affichage browser
- vérifier CSS généré (test auto sur fonctions scss)
- verif rendu d'un élément, d'une page 
- jest, nodesass, ts/js, puppeteer ...
- jest: `renderSync({...})` 
- `npm run test:unit --function`
- Snapshot testing : fichier référence pour vérifier non régression. `expect(cssstring).toMatchSnapshot('snapshotname')`. fichier généré lors du premier test. a comitter. -- testname -u pour maj Snapshot.
- test de rendu: ex tester sur tous les boutons dont la même hauteur. `await.page.evaluate... btn: queryselector..getboundingsclientrect.`
- screenshot : pas le plus pertinent. Utile quand mise à jour de librairie, utilisation ponctuelle sans commit. `toMatchImageSnaphot`
- tester les urls dans les CSS, `existSync`
- puppeteer peut simuler différents navigateurs 
- 



## BOF Gitlab past present future 
- who: JP Baconnais,*
- depuis 2013 25k
- 2014 100k
- plateforme 50aine services (manage,plan,create,verify,packagé,release,configure,monitor,secure)
- catalog: réutilisabilite, 



## template
- who:
- 


## template
- who:
- 

## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 


## template
- who:
- 

