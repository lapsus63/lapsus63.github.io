# IBM EAI 

### Overview

- EAI permet de faire communiquer applis entre elles + appliquer des transformations  
- Entreperise Application Integration = solutions + méthodes  
- Message = 1 Unité (format XML) ; Fichier = n Unites ; Flux ; Message EDI ; flux EDI  
- Niveaux de complexité : FTP > MQ > EAI > ESB  
- Outils : IIB IBM Integration Bus ; WebSphere Message Queue ; E2E (xNet app) ; Web Broker Interface (xNet)  
- Norme OAGIS : Open Application Group Integration Specification. = structure du XML ; norme mondiale.  
- Pas de XSD, compliqué à maintenir  

### Types de flux IIB

- Flux publication / souscription (1/2 flux)
  - publication: `Appli > MQ > Queue Manager > IIB Flow > Queue Manager IIB`
- Flux complet  (rare)
- Flux point-à-point
  - Connexion directe entre deux applis par des Queue Manager interconnectés
- Flux request / reply (rare)

### Contenu d'un projet EAI (Eclipse)

- Divers projets :
  - MsgFlow: pour les messages type XML
  - MsgSets : pour les msg type CSV
    - On décrit format des lignes (séparateurs, retour chariot, ...)
- 1 projet = n flux = 1 exécutable à déployer (depuis IIB, 1 flux = 1 fichier .bar avec WMB6).
- convention 
  - nommage: source _ destination _ nature canonique _ publication ou souscription _ version .msgflow
  - loguer dès le début pour valider que le message est pris en compte
  - Properties / Validation : décocher Validation pour éviter qu'Eclipse ne réagisse inutilement
- Datasources:
  - Properties sur un noeud, configure l'accès à la DB via le nom de la datasource pour ce noeud
  - 1 datasource par base
- User defined properties
  - Utilisé pour le monitoring par exemple
  - Fournit des variables de contexte

### Quelques commandes MQ :

```
crtmqm: création d'un qm
dltmqm: suppression d'un qm
strmqm: demarrage d'un qm
endmqm: arret d'un qm
dspmq: affichage des mq
sqlmqver: affichage des versions de mq
```
### Outils 

- Client MQ RFHUtil
- IDE Eclipse IIB (IBM Integration Toolkit)
  - Debugger : `Integration Nodes > NAME > Connexion > Launch debugger`

### IBM WebSphere Message Queuing (MQ)

- WMB: WebSphere Message Broker = End-point d'envoi ou de réception de demi-flux.
- Service de messagerie inter-applicatif
- Assure délivrance des messages
- Applications : 
  - MQ Server: permet de créer des composants de l'architecutre MQ
  - Queue Manager: Programme qui fournit svc de message queuing aux applications. On peut créer N queue manager sur un même serveur.
- Queue : BàL dans laquelle le msg arrive. Plusieurs types :
  - Local: File d'attente locale. L'app s'y connecte
  - Alias: Synonyme (DWMB en dév, CWMB en qualif, ...alias: WMB.APP)
  - Remote: = Alias mais ale droit de pointer queue locale sur un autre environnement. Utilisé en sortie de flux APP1 vers APP1. 
  - Création d'une queue:
    - Queue Alias +
    - Queue Locale +
    - Queue Backout qui contient les msg en erreur (fonctionnelle ou technique). Possibilité de renvoyer le message.
- Channel: Canal permettant d'interconnecter 2 QM pour envoyer msg de l'un à l'autre. Utilise une XMITQ (transmission Q) pour fonctionner
  - Sender (principal)
  - Receiver (principal)
  - Server connection:
  - Client connection:
  - Server (rare)
  - Requester (rare)
- Message: Conteneur de la donnée.
- Dead letter queue
  - Envoyée à la dead-letter queue si le QM ne sait pas comment gérer le message (pb fonctionnel, pb server, ...)
  - Si pas de backout, envoyé à dead-letter queue.
  - Un msg qui arrive dans l'EAI ne peut en théorie pas être perdu.

### Structure MQ

- Header systeme (MQMD)
- 0..n autre headers (MQDLH, MQRFH2, MQXQH, ...)
- Ordre des headers important
- Un header contient les infos décrivant la strcture du header suivant
- Headers séparés du XML. 
- Header contient:
  - Topic
  - Filtre(s) (possibilité de ne traiter que certains messages en fonction d'un filtre défini dans la création de la queue MQS)

### Hello world examples

- Connexion SSH
  - Start MQSC for queue manager QM-NAME : runmqsc QM-NAME
  - Paste queue creation scripts in stdin
- IBM Integration Toolkit (Eclipse IIB):
  - Integration Nodes > QM-NAME > Connect
  - Application Development > New > Application (TEST_HELLOWORLD)
  - Application Development > New Message Flow (TEST_FLOW)
  - Insert MQInput + <link> + Compute + <link> + MQOutput
    - File .esql => Compute operation (merge them if many compute operations)
    - File .msgflow => Message Flow
    - Examples of Compute operations :

```sql
-- From  : <Exercice><Personne><Nom>Martin</Nom><Prenom>Laurent</Prenom><Age>25</Age><Metier>Avocat</Metier></Personne></Exercice>
-- To    : <Resultat><ID><EtatCivil>Laurent Martin, 25 ans</EtatCivil><Metier>Avocat</Metier></ID></Resultat>
-- esql  :
CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        CALL CopyMessageHeaders();
        -- CALL CopyEntireMessage();
        -- Intialise l'objet Resultat (sera forcément créé dans l'output)
        CREATE FIELD OutputRoot.XMLNSC.Resultat;
        DECLARE pers REFERENCE TO InputRoot.XMLNSC.Exercice.Personne;
        SET OutputRoot.XMLNSC.Resultat.ID.EtatCivil = pers.Prenom || ' ' || pers.Nom || ', ' || pers.Age || ' ans';
        SET OutputRoot.XMLNSC.Resultat.ID.Metier = pers.Metier;
        RETURN TRUE;
    END;
```

```sql
-- To    : <Resultat><ID><EtatCivil Boulot='Avocat'>Laurent Martin, 25 ans</EtatCivil></ID><ID><EtatCivil Boulot='Acteur'>Jean-Michel Apeupres, 42 ans</EtatCivil></ID></Resultat>
-- esql  :
CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        CALL CopyMessageHeaders();
        -- CALL CopyEntireMessage();
        -- Intialise l'objet Resultat (sera forcément créé dans l'output)
        CREATE FIELD OutputRoot.XMLNSC.Resultat;
        DECLARE i INTEGER 1;
        FOR input AS InputRoot.XMLNSC.Exercice.Personne[] DO
            CREATE FIELD OutputRoot.XMLNSC.Resultat.ID[i];
            DECLARE outID REFERENCE TO OutputRoot.XMLNSC.Resultat.ID[i];
            SET outID.EtatCivil = input.Prenom || ' ' || input.Nom || ', ' || input.Age || ' ans';
            SET outID.EtatCivil.(XMLNSC.Attribute)Metier = input.Metier;
            SET i = i + 1;
        END FOR;       
        RETURN TRUE;
    END;
```
