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

### Integration testing 

<p><details>
<summary>Spring 2.7 + JUnit 5 framework</summary>

- project hierarchy:

```
src/main/{java,resources}
src/tao/{docker,java,resources}
src/test/{java,resources}
```

- pom.xml dependencies:

```xml
<!-- Unit testing -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
    <exclusions>
	<exclusion>
	    <groupId>org.junit.vintage</groupId>
	    <artifactId>junit-vintage-engine</artifactId>
	</exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <version>1.4.194</version>
    <scope>test</scope>
</dependency>
<dependency>
    <!-- allow to mock final classes and other -->
    <groupId>org.mockito</groupId>
    <artifactId>mockito-inline</artifactId>
    <version>4.3.1</version>
    <scope>test</scope>
</dependency>
```
 
- pom.xml build:

```xml
<plugin>
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-surefire-plugin</artifactId>
<version>2.22.0</version>
<configuration>
    <excludes>
	<exclude>**/*IT.java</exclude>
    </excludes>
</configuration>
</plugin>

<plugin>
<artifactId>maven-failsafe-plugin</artifactId>
<version>2.22.2</version>
</plugin>

<plugin>
<groupId>org.jacoco</groupId>
<artifactId>jacoco-maven-plugin</artifactId>
<version>0.8.4</version>
<executions>
    <execution>
	<id>prepare-agent</id>
	<goals>
	    <goal>prepare-agent</goal>
	</goals>
    </execution>
    <execution>
	<id>report</id>
	<phase>prepare-package</phase>
	<goals>
	    <goal>report</goal>
	</goals>
    </execution>
    <execution>
	<id>post-unit-test</id>
	<phase>test</phase>
	<goals>
	    <goal>report</goal>
	</goals>
	<configuration>
	    <!-- Sets the path to the file which contains the execution data. -->
	    <dataFile>target/jacoco.exec</dataFile>
	    <!-- Sets the output directory for the code coverage report. -->
	    <outputDirectory>target/jacoco-ut</outputDirectory>
	</configuration>
    </execution>
</executions>
</plugin>
```

- pom.xml profiles:

```xml
<profiles>
<profile>
    <id>failsafe</id>
    <build>
	<plugins>
	    <plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-surefire-plugin</artifactId>
		<configuration>
		    <!-- we want only tao in this profile --> 
		    <skipTests>true</skipTests>
		</configuration>
	    </plugin>
	    <plugin>
		<artifactId>maven-failsafe-plugin</artifactId>
		<version>2.22.2</version>
		<executions>
		    <execution>
			<goals>
			    <goal>integration-test</goal>
			    <goal>verify</goal>
			</goals>
			<configuration>
			    <forkCount>0</forkCount>
			    <useSystemClassLoader>false</useSystemClassLoader>
			    <includes>
				<include>**/*IT</include>
			    </includes>
			</configuration>
		    </execution>
		</executions>
	    </plugin>
	    <plugin>
		<groupId>org.codehaus.mojo</groupId>
		<artifactId>build-helper-maven-plugin</artifactId>
		<version>3.2.0</version>
		<executions>
		    <execution>
			<id>add-integration-test-source</id>
			<phase>generate-test-sources</phase>
			<goals>
			    <goal>add-test-source</goal>
			</goals>
			<configuration>
			    <sources>
				<source>src/tao/java</source>
			    </sources>
			</configuration>
		    </execution>
		    <execution>
			<id>add-integration-test-resource</id>
			<phase>generate-test-resources</phase>
			<goals>
			    <goal>add-test-resource</goal>
			</goals>
			<configuration>
			    <resources>
				<resource>
				    <directory>src/tao/resources</directory>
				</resource>
			    </resources>
			</configuration>
		    </execution>
		</executions>
	    </plugin>
	</plugins>
    </build>
</profile>
</profiles>
```

- DatabaseTestUtils.java:

```java
public static void executeScripts(String... scriptPaths) throws Exception {
	DriverManagerDataSource dataSource = getDataSource();
	Connection conn = dataSource.getConnection();
	for (String scriptPath: scriptPaths) {
	    ScriptUtils.executeSqlScript(conn, new ClassPathResource(scriptPath));
	}
	JdbcUtils.closeConnection(conn);
}

private static DriverManagerDataSource getDataSource() {
	DriverManagerDataSource dataSource = new DriverManagerDataSource();
	dataSource.setUrl("jdbc:h2:tcp://localhost:1521/db;Mode=Oracle;DB_CLOSE_DELAY=-1;SCHEMA_SEARCH_PATH=<MY_DEFAULT_SID>");
	dataSource.setUsername("sa");
	dataSource.setPassword("sa");
	dataSource.setDriverClassName("org.h2.Driver");
	return dataSource;
}
```

- MySkeletonIT.java:

```java
@SpringBootTest
@ContextConfiguration(classes= {MyMainApplication.class})
// ...
@BeforeEach
// SpringBatch
new JobLauncherTestUtils().setJob(job).setJobLauncher(jobLauncher);
// ...
@Test @DisplayName("Test description")
public void scenarioOneTest() throws Exception {
	/* given */
	/* when */
	/* then */
	// SpringBoot: AssertFile.assertFileEquals(new ClassPathResource("...").getFile(), expectedFile);
}


```

</details></p>

### Maven cheat sheet

```bash
# Locate a libray in the dependency tree
mvn dependency:tree -Dverbose -Dincludes=ch.qos.logback:logback-classic
```

```bash
# Check library updates from repository
mvn versions:display-dependency-updates 
```

### Java Keytool cheat sheet

<p><details>
	<summary>Listing</summary>
</details>

```bash
# Show trusted certificates
# bash
/path/to/jdk/bin/keytool -list -keystore cacerts | grep -v fingerprint
# batch
path\to\jdk\bin\keytool.exe -list -keystore cacerts | find /V "Empreinte"
```


</p>

### LDAP Connection

<p><details>
<summary>LdapConnect.java</summary>

```java
import javax.naming.*;
import javax.naming.ldap.*;
import javax.naming.directory.*;
import java.util.*;

public class LdapConnect {


        public static final void main(String... args) {

        /*
         * VM possible options : -Dhttps.protocols=TLSv1 -Djavax.net.debug=all
         */
        Hashtable env = new Hashtable();
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        env.put(Context.PROVIDER_URL, "ldaps://localhost:636");
        try {
            // bind to the domain controller
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
        }
}

```
</details>
</p>


### Azure Event Data Hub Receiver/Producer

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

	


<p><details>
<summary>EventProducer.java</summary>

```java
	
import com.azure.core.amqp.AmqpTransportType;
import com.azure.messaging.eventhubs.EventData;
import com.azure.messaging.eventhubs.EventDataBatch;
import com.azure.messaging.eventhubs.EventHubClientBuilder;
import com.azure.messaging.eventhubs.EventHubProducerClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.List;

// Define the connection-string with your values (azure: Event Hub Namespace | Shared access policies | RootManageSharedAccessKey)
public final static String connectionString = "Endpoint=sb://******.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=******";
public final static String storageConnectionString = "DefaultEndpointsProtocol=https;AccountName=******;AccountKey=******";
public static final String eventHubName = "******";
public static final String storageContainerName = "******";
	
public static void publishEvents() {

// create a producer client
EventHubProducerClient producer = new EventHubClientBuilder()
	.connectionString(Config.connectionString, Config.eventHubName)
	.transportType(AmqpTransportType.AMQP_WEB_SOCKETS)
	.consumerGroup(DEFAULT_CONSUMER_GROUP_NAME)
	.buildProducerClient();

// sample events in an array
List<EventData> allEvents = Arrays.asList(new EventData("Hello"), new EventData("World"));

// create a batch
EventDataBatch eventDataBatch = producer.createBatch();

for (EventData eventData : allEvents) {
    // try to add the event from the array to the batch
    if (!eventDataBatch.tryAdd(eventData)) {
	// if the batch is full, send it and then create a new batch
	producer.send(eventDataBatch);
	eventDataBatch = producer.createBatch();

	// Try to add that event that couldn't fit before.
	if (!eventDataBatch.tryAdd(eventData)) {
	    throw new IllegalArgumentException("Event is too large for an empty batch. Max size: " + eventDataBatch.getMaxSizeInBytes());
	}
    }
}
// send the last batch of remaining events
if (eventDataBatch.getCount() > 0) {
    producer.send(eventDataBatch);
}
producer.close();

LOG.info("End of Publication job");
}

```
</details>
</p>

	
### Azure Storage Account Queue Listener
	

<p><details>
<summary>pom.xml</summary>
	
```xml
<!-- https://docs.microsoft.com/fr-fr/azure/storage/queues/storage-java-how-to-use-queue-storage?tabs=java -->
<dependency>
  <groupId>com.azure</groupId>
  <artifactId>azure-storage-queue</artifactId>
  <version>12.6.0</version>
</dependency>
```
	
</details>
</p>


<p><details>
<summary>Listener.java</summary>
	
```java

import com.azure.core.util.Base64Util;
import com.azure.storage.queue.QueueClient;
import com.azure.storage.queue.QueueClientBuilder;
import com.azure.storage.queue.models.PeekedMessageItem;
import com.azure.storage.queue.models.QueueMessageItem;
import com.azure.storage.queue.models.QueueProperties;
import com.azure.storage.queue.models.QueueStorageException;

import java.nio.charset.StandardCharsets;
	
final static String connectStr = "DefaultEndpointsProtocol=https;AccountName=******;AccountKey=******";
	
public static void getQueueLength(String queueName) {
        try {
            // Instantiate a QueueClient which will be used to create and manipulate the queue
            QueueClient queueClient = new QueueClientBuilder().connectionString(connectStr).queueName(queueName).buildClient();

            QueueProperties properties = queueClient.getProperties();
            long messageCount = properties.getApproximateMessagesCount();

            System.out.println(String.format("Queue length: %d", messageCount));
        } catch (QueueStorageException e) {
            // Output the exception message and stack trace
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }


    public static void peekQueueMessage(String queueName) {
        try {
            // Instantiate a QueueClient which will be used to create and manipulate the queue
            QueueClient queueClient = new QueueClientBuilder()
                    .connectionString(connectStr)
                    .queueName(queueName)
                    .buildClient();

            // Peek at the first message
            PeekedMessageItem receivedMessage = queueClient.peekMessage();
            System.out.println("Peeked message: " + receivedMessage.getMessageText());

        } catch (QueueStorageException e) {
            // Output the exception message and stack trace
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }

    public static void receiveThenDeleteQueueMessage(String queueName) {
        try {
            // Instantiate a QueueClient which will be used to create and manipulate the queue
            QueueClient queueClient = new QueueClientBuilder()
                    .connectionString(connectStr)
                    .queueName(queueName)
                    .buildClient();

            // Receive the first message (masked for 30 seconds unless deleted is performed)
            QueueMessageItem receivedMessage = queueClient.receiveMessage();
            System.out.println("Received message: " + new String(Base64Util.decodeString(receivedMessage.getMessageText()), StandardCharsets.UTF_8));

            // queueClient.deleteMessage(receivedMessage.getMessageId(), receivedMessage.getPopReceipt());
            // System.out.println("Deleted message: " + receivedMessage.getMessageText());
        } catch (QueueStorageException e) {
            // Output the exception message and stack trace
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }
```
	
</details>
</p>
	
