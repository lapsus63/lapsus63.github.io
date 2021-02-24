# JDK Cheat Sheet

- Command line **memory dump**

```bash
jmap -dump:live,file=<file-path> <pid>
```

- Command line **stack trace**

```bash
jstack -F <pid>
```

- Capture **OutOfMemoryError**

```bash
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/logs/heapdump
```

- Capture memory / threads without installed JDK :

Download "ServerJRE9" from Oracle website : http://www.oracle.com/technetwork/java/javase/downloads/server-jre9-downloads-3848530.html

 