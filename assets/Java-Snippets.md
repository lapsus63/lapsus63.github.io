# Java Snippets

### JDK Cheat Sheet

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

### LDAP Connection

```java
/*
 * import javax.naming.*;
 * VM possible options : -Dhttps.protocols=TLSv1 -Djavax.net.debug=all
 */
Hashtable env = new Hashtable();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		env.put(Context.PROVIDER_URL, "ldaps://localhost:636");
		try {
			//bind to the domain controller
			LdapContext ctx = new InitialLdapContext(env, null);
			ctx = new InitialLdapContext(env, null);
			SearchControls controls = new SearchControls();
			controls.setSearchScope(SearchControls.SUBTREE_SCOPE);
			NamingEnumeration<SearchResult> result = ctx.search("", "(uid=username)", controls);
			System.out.println("LDAP Connection Successful : " + result);
			System.exit(0);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
```


### Azure Event Data Hub Receiver

<p><details>
<summary>pom.xml</summary>

```xml
    <!-- https://docs.microsoft.com/fr-fr/azure/event-hubs/event-hubs-java-get-started-send -->
    <dependency>
      <groupId>com.azure</groupId>
      <artifactId>azure-messaging-eventhubs</artifactId>
      <version>5.7.0</version>
    </dependency>
    <dependency>
      <groupId>com.azure</groupId>
      <artifactId>azure-messaging-eventhubs-checkpointstore-blob</artifactId>
      <version>1.6.0</version>
    </dependency>
```
</details>
</p>

<p><details>
<summary>Receiver.java</summary>

```java

import com.azure.core.amqp.AmqpTransportType;
import com.azure.messaging.eventhubs.EventData;
import com.azure.messaging.eventhubs.EventProcessorClient;
import com.azure.messaging.eventhubs.EventProcessorClientBuilder;
import com.azure.messaging.eventhubs.checkpointstore.blob.BlobCheckpointStore;
import com.azure.messaging.eventhubs.models.ErrorContext;
import com.azure.messaging.eventhubs.models.EventContext;
import com.azure.messaging.eventhubs.models.PartitionContext;
import com.azure.storage.blob.BlobContainerAsyncClient;
import com.azure.storage.blob.BlobContainerClientBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.function.Consumer;

import static com.azure.messaging.eventhubs.EventHubClientBuilder.DEFAULT_CONSUMER_GROUP_NAME;

// Define the connection-string with your values (azure: Event Hub Namespace | Shared access policies | RootManageSharedAccessKey)
public final static String connectionString = "Endpoint=sb://******.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=******";
public final static String storageConnectionString = "DefaultEndpointsProtocol=https;AccountName=******;AccountKey=******";
public static final String eventHubName = "******";
public static final String storageContainerName = "******";
	
public static void receiveEvents() throws Exception {
        // Create a blob container client that you use later to build an event processor client to receive and process events
        BlobContainerAsyncClient blobContainerAsyncClient = new BlobContainerClientBuilder()
                .connectionString(Config.storageConnectionString)
                .containerName(Config.storageContainerName)
                .buildAsyncClient();

        // Create a builder object that you will use later to build an event processor client to receive and process events and errors.
        EventProcessorClientBuilder eventProcessorClientBuilder = new EventProcessorClientBuilder()
                .connectionString(Config.connectionString, Config.eventHubName)
                .transportType(AmqpTransportType.AMQP_WEB_SOCKETS)
                .consumerGroup(DEFAULT_CONSUMER_GROUP_NAME)
                .processEvent(PARTITION_PROCESSOR)
                .processError(ERROR_HANDLER)
                .checkpointStore(new BlobCheckpointStore(blobContainerAsyncClient));

        // Use the builder object to create an event processor client
        EventProcessorClient eventProcessorClient = eventProcessorClientBuilder.buildEventProcessorClient();

        LOG.info("Starting event processor");
        eventProcessorClient.start();

        System.out.println("Press enter to stop.");
        System.in.read();

        LOG.info("Stopping event processor");
        eventProcessorClient.stop();
        LOG.info("Event processor stopped.");

        LOG.info("Exiting process");
    }

    public static final Consumer<EventContext> PARTITION_PROCESSOR = eventContext -> {
        PartitionContext partitionContext = eventContext.getPartitionContext();
        EventData eventData = eventContext.getEventData();

        LOG.info("Processing event from partition {} with sequence number {} with body: {}", partitionContext.getPartitionId(), eventData.getSequenceNumber(), eventData.getBodyAsString());

        // Every 10 events received, it will update the checkpoint stored in Azure Blob Storage.
        if (eventData.getSequenceNumber() % 10 == 0) {
            eventContext.updateCheckpoint();
        }
    };

    public static final Consumer<ErrorContext> ERROR_HANDLER = errorContext -> {
        LOG.info("Error occurred in partition processor for partition {}, {}", errorContext.getPartitionContext().getPartitionId(), errorContext.getThrowable());
    };
```
</details>
</p>
