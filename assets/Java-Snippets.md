# JDK Cheat Sheet

- Liens de téléchargement

  - Archives Oracle : [Java 8](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html), [Java 7](https://www.oracle.com/java/technologies/javase/javase7-archive-downloads.html), [Java 6](https://www.oracle.com/fr/java/technologies/javase-java-archive-javase6-downloads.html)
  - Oracle : [Java](https://www.oracle.com/java/technologies/javase-downloads.html)
  - OpenJDK : [Ready for Use, Early access](https://jdk.java.net/)
  - Portable Apps : [Oracle JDK](https://portapps.io/app/oracle-jdk-portable/)

### Licenses

- Open licenses for developers and production

  - Java 6 Update 45 et inférieur
  - Java 7 Update 80 et inférieur
  - Java 8 Update 201 et inférieur
  - OpenJDK (toutes versions)

- Les versions suivantes de Java nécessitent une licence :

  - Java 6 Mise à jour au-dessus de 45
  - Mise à jour de Java 7 au-dessus de 80
  - Java 8 Update 202 et supérieur
  - Java 11 et supérieur
  - Java JRE sur les serveurs
  - Java JDK sur les serveurs

Info supplémentaire : [StackOverflow](https://stackoverflow.com/questions/58250782/which-free-version-of-java-can-i-use-for-production-environments-and-or-commerci)

### Memory dump and analysis

- Command line

```bash
jmap -dump:live,file=<file-path> <pid>
```
- Capture **OutOfMemoryError**

```bash
# JVM Options :
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/logs/heapdump
```


### Thread dump, stack trace

*source: [RedHat.com](https://access.redhat.com/solutions/19170)*

- From attached console : Ctrl-Break (except if -Xrs JVM argument)
- Command Line with *JDK*

```bash
# must be the same user who owns the JVM process or have sufficient privileges to access it (and Administrator for example)
# Windows Server 2008R2 : may need to use PsExec.exe tool
jstack -F JAVA_PID
# or JDK 16+
jstack -l JAVA_PID > thread-dump.out
# or 
C:\PSTools>psexec -s c:\Java\jdkX.Y.Z_W\bin\jstack.exe -l JAVA_PID >dump.txt
```
- Command Line with **JRE**

```bash
jcmd JAVA_PID
# or JRE 16+
jcmd JAVA_PID Thread.print > thread-dump.out
# or
C:\PSTools>psexec -s c:\jre\path\bin\jcmd.exe JAVA_PID Thread.dump >dump.txt
```

### Activation de JMX

*source : [StackOverflow](https://stackoverflow.com/questions/856881/how-to-activate-jmx-on-my-jvm-for-access-with-jconsole)*

```bash
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=9010
-Dcom.sun.management.jmxremote.rmi.port=9010
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Djava.rmi.server.hostname=127.0.0.1
```

