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


### Telemetry with OpenTelemetry, Micrometer and Grafana



<p><details>
<summary>pom.xml</summary>
```xml
	<dependencyManagement>
		<dependencies>
			<!-- Force toutes les dépendances OpenTelemetry à la même version -->
			<!-- import the OpenTelemetry BOMs before any other BOMs in your project. -->
			<!-- https://opentelemetry.io/docs/zero-code/java/spring-boot-starter/getting-started/ -->
			<dependency>
				<groupId>io.opentelemetry.instrumentation</groupId>
				<artifactId>opentelemetry-instrumentation-bom</artifactId>
				<version>${otel-instrumentation.version}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
	<dependencies>
		<!-- Monitoring dependencies (versions gérées par le bom dans le dependencyManagement) -->
		<dependency>
			<groupId>io.micrometer</groupId>
			<artifactId>micrometer-registry-otlp</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<!-- permet d'exposer les métriques au format prometheus sur /actuator/prometheus -->
			<groupId>io.micrometer</groupId>
			<artifactId>micrometer-registry-prometheus</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>io.opentelemetry</groupId>
			<artifactId>opentelemetry-exporter-otlp</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>io.opentelemetry.instrumentation</groupId>
			<artifactId>opentelemetry-spring-boot-starter</artifactId>
		</dependency>
		<dependency>
			<!-- Permet de lier les observations (traces, @Observed) à micrometer (métriques) -->
			<groupId>io.micrometer</groupId>
			<artifactId>micrometer-tracing-bridge-otel</artifactId>
		</dependency>
	</dependencies>
```
</details>


<p><details>
<summary>application.yaml</summary>
```yaml
# https://docs.spring.io/spring-boot/reference/actuator/observability.html
# https://docs.spring.io/spring-boot/reference/actuator/tracing.html

# Micrometer
management:
  health:
    readinessState.enabled: true
    livenessState.enabled: true
  endpoint:
    health:
      probes.enabled: true
      show-details: always
  endpoints.web.exposure:
    include: "*"
    exclude: "caches"
  observations:
    # enable scanning of observability annotations like @Observed, @Timed, @Counted, @MeterTag and @NewSpan:
    annotations.enabled: true
    # desactiver des observations: management.observations.enable.denied.prefix: false
    # If you need greater control over the prevention of observations, you can register beans of type ObservationPredicate
    enable.all: true
    key-values.env: ${SPRING_APP_ENVIRONMENT}
    key-values.service.name: ${SPRING_APP_NAME}
  otlp:
    logs.export:
      url: https://otel-collector-url.com/http/v1/logs
    metrics.export:
      enabled: true
      connect-timeout: 10s # par defaut 1s
      read-timeout: 30s # par defaut 10s
      step: 60s
      url: https://otel-collector-url.com/http/v1/metrics
    tracing:
      endpoint: https://otel-collector-url.com/http/v1/traces
  tracing:
    enabled: true
    sampling.probability: 1.0

# OpenTelemetry
# https://opentelemetry.io/docs/languages/java/configuration/
otel:
  exporter:
    otlp:
      headers:
        x-scope-orgid: default
      endpoint: https://otel-collector-url.com:443
      # http/protobuf pour la compatibilité maximale, la simplicité réseau, ou proxies HTTP.
      # gRPC pour la performance maximale et que l'infra le supporte
      protocol: grpc
  instrumentation.micrometer.enabled: true
  instrumentation.logback-appender.enabled: true
  logs.exporter: otlp
  metrics.exporter: otlp
  resource:
    attributes:
      env: ${SPRING_APP_ENVIRONMENT}
      service.name: ${SPRING_APP_NAME}
  sdk.disabled: false
  service.name: ${SPRING_APP_NAME}
  traces.exporter: otlp

application:
  config:
    otel:
      metric-names-allowed:
        - "http.server.requests"
        - "logback.events"
        - "method.observed"
        - "process.start.time"
        - "process.uptime"
        - "spring.data.repository.invocations"
        - "spring.batch.job.launch.count"
      observation-uris-filtered:
        - "/actuator/**"
```
</details>

<p><details>
<summary>OpenTelemetryConfig.java</summary>
```java
@Configuration
@ConfigurationProperties(prefix = "application.config.otel")
@Slf4j
@Setter
@Profile("opentelemetry")
public class OpenTelemetryConfig {

    private List<String> metricNamesAllowed;
    private List<String> metricNamesFiltered;
    private List<String> observationUrisFiltered;

    @Bean
    public ObservationRegistryCustomizer<ObservationRegistry> customizeObservation() {
        PathMatcher pathMatcher = new AntPathMatcher("/");
        return registry -> registry.observationConfig().observationPredicate((name, context) -> {
            if (context instanceof ServerRequestObservationContext observationContext) {
                String uri = observationContext.getCarrier().getRequestURI();
                return observationUrisFiltered.stream().noneMatch(pattern -> pathMatcher.match(pattern, uri));
            }
            return true;
        });
    }

    @Bean
    public MeterFilter filterMetrics() {
        return new MeterFilter() {
            @Override
            public MeterFilterReply accept(Meter.Id id) {
                String name = id.getName();
                if (metricNamesAllowed.contains(name)) {
                    if (name.startsWith("http.server.requests") && id.getTags().stream().anyMatch(tag -> "uri".equals(tag.getKey()) && tag.getValue().startsWith("/actuator"))) {
                        return MeterFilterReply.DENY;
                    }
                    return MeterFilterReply.NEUTRAL;
                } else if (metricNamesFiltered.contains(name)) {
                    return MeterFilterReply.DENY;
                }
                log.warn("Unkown metric name: {} {}", name, id.getTags());
                return MeterFilterReply.NEUTRAL;
            }
        };
    }
}
```
</details>



<p><details>
<summary>OpenTelemetryUtils.java</summary>
```java

    public static void updateObservation(Map<String, String> tags) {
        Observation obs = getObservationRegistry().getCurrentObservation();
        if (obs != null) {
            KeyValues kvs = tags.entrySet().stream().collect(
                    KeyValues::empty,
                    (keyValues, entry) -> keyValues.and(entry.getKey(), entry.getValue()),
                    KeyValues::and
            );
            // Low cardinality tags will be added to metrics and traces, while high cardinality tags will only be added to traces.
            obs.lowCardinalityKeyValues(kvs);
        } else {
            log.debug("No current observation found");
        }
    }

    public static void updateEvent(AbstractEvent metricWrapper) {
        try {
            log.info(metricWrapper.getMessage());
            updateObservation(metricWrapper.getTags());
        } catch (Exception e) {
            log.warn("Error while updating time based event {}", metricWrapper.getName(), e);
        }
    }

    public static void updateCounter(AbstractCounter metricWrapper) {
        String metricName = null;
        try {
            metricName = metricWrapper.getName();
            Meter meter = getOpenTelemetryMeter();
            if (meter == null) {
                return;
            }
            LongCounter counter = meter.counterBuilder(metricName).build();
            counter.add(metricWrapper.getIncrement(), metricWrapper.getAttributes());
            log.trace("Counter {} updated: {}", metricName, metricWrapper.getTags().entrySet().stream()
                    .map(e -> e.getKey() + "=" + e.getValue())
                    .collect(Collectors.joining(" ", "", "")));
            updateObservation(metricWrapper.getTags());
        } catch (Exception e) {
            log.warn("Error while updating counter {}", metricName, e);
        }
    }

    public static void updateLongGauge(AbstractLongGauge metricWrapper) {
        String metricName = null;
        try {
            metricName = metricWrapper.getName();
            Meter meter = getOpenTelemetryMeter();
            if (meter == null) {
                return;
            }
            LongGauge gauge = meter.gaugeBuilder(metricName).ofLongs().build();
            gauge.set(metricWrapper.getValue(), metricWrapper.getAttributes());
            log.trace("Gauge {} updated with {}: {}", metricName, metricWrapper.getValue(), metricWrapper.getTags().entrySet().stream()
                    .map(e -> e.getKey() + "=" + e.getValue())
                    .collect(Collectors.joining(" ", "", "")));
            updateObservation(metricWrapper.getTags());
        } catch (Exception e) {
            log.warn("Error while updating gauge {}", metricName, e);
        }
    }

	// Application should implement ApplicationContextAware and call this method
    public static void initContext(ApplicationContext applicationContext) {
        context = applicationContext;
    }

    private static Meter getOpenTelemetryMeter() {
        if (context == null) {
            return null;
        }
        return context.getBean(OpenTelemetry.class).getMeter(OpenTelemetryUtils.class.getPackageName());
    }

    private static ObservationRegistry getObservationRegistry() {
        return context.getBean(ObservationRegistry.class);
    }

    /**
     * see <a href="https://www.w3.org/TR/trace-context/">W3C</a>
     * 00: version
     * trace-id: 16 bytes array (32 hex characters)
     * span-id: 8 bytes array (16 hex characters)
     * trace-flags: 1 byte array (2 hex characters)
     * 01 : indique que cette trace est échantillonnée et devrait être enregistrée
     * 00 : indique que la trace ne devrait pas être échantillonnée
     * @return the current traceparent in the W3C Trace Context format.
     */
    public static String getTraceParent() {
        Span currentSpan = Span.current();
        if (currentSpan != null && currentSpan.getSpanContext().isValid()) {
            String traceId = currentSpan.getSpanContext().getTraceId();
            String spanId = currentSpan.getSpanContext().getSpanId();
            return "00-" + traceId + "-" + spanId + "-01";
        }
        return "";
    }
```
</details>

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

```bash
# Automatically upgrade libraries in pom.xml (-o for offline ; warning: coffee time)
mvn -o versions:use-latest-releases
```

- [Merging integration and unit test reports with JaCoCo](https://stackoverflow.com/questions/33349864/merging-integration-and-unit-test-reports-with-jacoco)

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



### IDE Code Formatter
 
<p><details>
<summary>eclipse-formatter-config.xml</summary>
	
```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->
<profiles version="23">
<!-- see 
 - https://code.revelc.net/formatter-maven-plugin/format-mojo.html#configFile
 - https://github.com/redhat-developer/vscode-java/blob/master/formatters/eclipse-formatter.xml 
 - https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.jdt.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fjdt%2Fcore%2Fformatter%2FDefaultCodeFormatterConstants.html
   https://eclipse.googlesource.com/jdt/eclipse.jdt.core/+/v_398a/org.eclipse.jdt.core/formatter/org/eclipse/jdt/core/formatter/DefaultCodeFormatterConstants.java
 - https://github.com/revelc/formatter-maven-plugin/blob/main/src/main/resources/formatter-maven-plugin/eclipse/java.xml
 -->
    <profile kind="CodeFormatterProfile" name="formatter" version="23">
        <setting id="org.eclipse.jdt.core.formatter.align_arrows_in_switch_on_columns" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.align_assignment_statements_on_columns" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.align_fields_grouping_blank_lines" value="2147483647"/>
        <setting id="org.eclipse.jdt.core.formatter.align_selector_in_method_invocation_on_expression_first_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.align_type_members_on_columns" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.align_variable_declarations_on_columns" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.align_with_spaces" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_additive_operator" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_enum_constant" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_field" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_local_variable" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_method" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_package" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_parameter" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_annotations_on_type" value="49"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_allocation_expression" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_annotation" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_enum_constant" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_explicit_constructor_call" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_method_invocation" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_arguments_in_qualified_allocation_expression" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_assertion_message" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_assignment" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_bitwise_operator" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_compact_if" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_compact_loops" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_conditional_expression" value="80"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_conditional_expression_chain" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_enum_constants" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_expressions_in_array_initializer" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_expressions_in_for_loop_header" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_expressions_in_switch_case_with_arrow" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_expressions_in_switch_case_with_colon" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_logical_operator" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_method_declaration" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_module_statements" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_multiple_fields" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_multiplicative_operator" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_parameterized_type_references" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_parameters_in_constructor_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_parameters_in_method_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_permitted_types_in_type_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_record_components" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_relational_operator" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_resources_in_try" value="81"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_selector_in_method_invocation" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_shift_operator" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_string_concatenation" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_superclass_in_type_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_superinterfaces_in_enum_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_superinterfaces_in_record_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_superinterfaces_in_type_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_switch_case_with_arrow" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_throws_clause_in_constructor_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_throws_clause_in_method_declaration" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_type_annotations" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_type_arguments" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_type_parameters" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.alignment_for_union_type_in_multicatch" value="16"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_after_imports" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_after_last_class_body_declaration" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_after_package" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_abstract_method" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_field" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_first_class_body_declaration" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_imports" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_member_type" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_method" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_new_chunk" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_before_package" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_between_import_groups" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_between_statement_group_in_switch" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.blank_lines_between_type_declarations" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_annotation_type_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_anonymous_type_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_array_initializer" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_block" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_block_in_case" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_block_in_case_after_arrow" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_constructor_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_enum_constant" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_enum_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_lambda_body" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_method_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_record_constructor" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_record_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_switch" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.brace_position_for_type_declaration" value="end_of_line"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.align_tags_descriptions_grouped" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.align_tags_names_descriptions" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.clear_blank_lines_in_block_comment" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.clear_blank_lines_in_javadoc_comment" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.count_line_length_from_starting_position" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_block_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_header" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_html" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_javadoc_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_line_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.format_source_code" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.indent_parameter_description" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.indent_root_tags" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.indent_tag_description" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.insert_new_line_before_root_tags" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.insert_new_line_between_different_tags" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.insert_new_line_for_parameter" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.javadoc_do_not_separate_block_tags" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.line_length" value="200"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.new_lines_at_block_boundaries" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.new_lines_at_javadoc_boundaries" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.comment.preserve_white_space_between_code_and_line_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.compact_else_if" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.continuation_indentation" value="2"/>
        <setting id="org.eclipse.jdt.core.formatter.continuation_indentation_for_array_initializer" value="2"/>
        <setting id="org.eclipse.jdt.core.formatter.disabling_tag" value="@formatter:off"/>
        <setting id="org.eclipse.jdt.core.formatter.enabling_tag" value="@formatter:on"/>
        <setting id="org.eclipse.jdt.core.formatter.format_guardian_clause_on_one_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.format_line_comment_starting_on_first_column" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_annotation_declaration_header" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_enum_constant_header" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_enum_declaration_header" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_record_header" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_type_header" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_breaks_compare_to_cases" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_empty_lines" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_statements_compare_to_block" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_statements_compare_to_body" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_cases" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_switch" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.indentation.size" value="4"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_enum_constant" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_field" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_local_variable" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_method" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_package" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_parameter" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_type" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_label" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_opening_brace_in_array_initializer" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_after_type_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_at_end_of_file_if_missing" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_before_catch_in_try_statement" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_before_closing_brace_in_array_initializer" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_before_else_in_if_statement" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_before_finally_in_try_statement" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_new_line_before_while_in_do_statement" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_additive_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_and_in_type_parameter" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_arrow_in_switch_case" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_arrow_in_switch_default" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_assignment_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_at_in_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_at_in_annotation_type_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_bitwise_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_closing_angle_bracket_in_type_arguments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_closing_angle_bracket_in_type_parameters" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_closing_brace_in_block" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_closing_paren_in_cast" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_colon_in_assert" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_colon_in_case" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_colon_in_conditional" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_colon_in_for" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_colon_in_labeled_statement" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_allocation_expression" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_annotation" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_array_initializer" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_constructor_declaration_parameters" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_constructor_declaration_throws" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_enum_constant_arguments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_enum_declarations" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_explicitconstructorcall_arguments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_for_increments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_for_inits" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_declaration_parameters" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_declaration_throws" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_invocation_arguments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_multiple_field_declarations" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_multiple_local_declarations" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_parameterized_type_reference" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_permitted_types" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_record_components" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_superinterfaces" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_switch_case_expressions" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_type_arguments" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_comma_in_type_parameters" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_ellipsis" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_lambda_arrow" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_logical_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_multiplicative_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_not_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_parameterized_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_type_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_type_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_brace_in_array_initializer" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_bracket_in_array_allocation_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_bracket_in_array_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_cast" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_catch" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_constructor_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_enum_constant" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_for" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_if" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_method_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_method_invocation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_parenthesized_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_record_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_switch" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_synchronized" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_try" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_while" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_postfix_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_prefix_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_question_in_conditional" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_question_in_wildcard" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_relational_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_semicolon_in_for" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_semicolon_in_try_resources" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_shift_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_string_concatenation" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_after_unary_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_additive_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_and_in_type_parameter" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_arrow_in_switch_case" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_arrow_in_switch_default" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_assignment_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_at_in_annotation_type_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_bitwise_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_parameterized_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_type_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_type_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_brace_in_array_initializer" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_bracket_in_array_allocation_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_bracket_in_array_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_cast" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_catch" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_constructor_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_enum_constant" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_for" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_if" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_method_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_method_invocation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_parenthesized_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_record_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_switch" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_synchronized" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_try" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_while" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_assert" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_case" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_conditional" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_default" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_for" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_colon_in_labeled_statement" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_allocation_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_array_initializer" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_constructor_declaration_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_constructor_declaration_throws" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_enum_constant_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_enum_declarations" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_explicitconstructorcall_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_for_increments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_for_inits" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_declaration_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_declaration_throws" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_invocation_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_multiple_field_declarations" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_multiple_local_declarations" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_parameterized_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_permitted_types" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_record_components" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_superinterfaces" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_switch_case_expressions" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_type_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_comma_in_type_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_ellipsis" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_lambda_arrow" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_logical_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_multiplicative_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_parameterized_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_type_arguments" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_type_parameters" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_annotation_type_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_anonymous_type_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_array_initializer" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_block" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_constructor_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_enum_constant" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_enum_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_method_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_record_constructor" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_record_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_switch" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_type_declaration" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_allocation_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_annotation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_annotation_type_member_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_catch" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_constructor_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_enum_constant" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_for" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_if" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_invocation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_parenthesized_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_record_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_switch" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_synchronized" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_try" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_while" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_parenthesized_expression_in_return" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_parenthesized_expression_in_throw" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_postfix_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_prefix_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_question_in_conditional" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_question_in_wildcard" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_relational_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_semicolon" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_semicolon_in_for" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_semicolon_in_try_resources" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_shift_operator" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_string_concatenation" value="insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_before_unary_operator" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_brackets_in_array_type_reference" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_braces_in_array_initializer" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_brackets_in_array_allocation_expression" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_annotation_type_member_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_constructor_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_enum_constant" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_method_declaration" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_method_invocation" value="do not insert"/>
        <setting id="org.eclipse.jdt.core.formatter.join_line_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.join_lines_in_comments" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.join_wrapped_lines" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_annotation_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_anonymous_type_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_code_block_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_else_statement_on_same_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_empty_array_initializer_on_one_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_enum_constant_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_enum_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_if_then_body_block_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_imple_if_on_one_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_lambda_body_block_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_loop_body_block_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_method_body_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_record_constructor_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_record_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_simple_do_while_body_on_same_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_simple_for_body_on_same_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_simple_getter_setter_on_one_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_simple_while_body_on_same_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_switch_body_block_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_switch_case_with_arrow_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_then_statement_on_same_line" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.keep_type_declaration_on_one_line" value="one_line_never"/>
        <setting id="org.eclipse.jdt.core.formatter.lineSplit" value="200"/>
        <setting id="org.eclipse.jdt.core.formatter.never_indent_block_comments_on_first_column" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.never_indent_line_comments_on_first_column" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_after_code_block" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_at_beginning_of_code_block" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_at_beginning_of_method_body" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_at_end_of_code_block" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_at_end_of_method_body" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_blank_lines_before_code_block" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.number_of_empty_lines_to_preserve" value="1"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_annotation" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_catch_clause" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_enum_constant_declaration" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_for_statment" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_if_while_statement" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_lambda_declaration" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_method_delcaration" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_method_invocation" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_record_declaration" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_switch_statement" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.parentheses_positions_in_try_clause" value="common_lines"/>
        <setting id="org.eclipse.jdt.core.formatter.put_empty_statement_on_new_line" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="space"/>
        <setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
        <setting id="org.eclipse.jdt.core.formatter.text_block_indentation" value="0"/>
        <setting id="org.eclipse.jdt.core.formatter.use_on_off_tags" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.use_tabs_only_for_leading_indentations" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_additive_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_assertion_message_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_assignment_operator" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_bitwise_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_conditional_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_logical_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_multiplicative_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_or_operator_multicatch" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_relational_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_shift_operator" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_string_concatenation" value="true"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_before_switch_case_arrow_operator" value="false"/>
        <setting id="org.eclipse.jdt.core.formatter.wrap_outer_expressions_when_nested" value="true"/>
    </profile>
</profiles>

```
</details>


### CSV Writer
 
<p><details>
<summary>CSVWriterRepository.java</summary>
	
```java
/* To be used with opencsv library */
public final class CSVWriterRepository<T> extends CSVWriter {

    public final static char CSV_SEPARATOR = ';';

    public final static char QUOTE_CHAR = CSVWriter.NO_QUOTE_CHARACTER;

    public final static char ESCAPE_CHAR = CSVWriter.NO_ESCAPE_CHARACTER;

    public final static String LINE_END = CSVWriter.RFC4180_LINE_END;

    public final static boolean APPLY_QUOTES_TO_ALL = false;

    private final Class<T> entityType;

    private List<Field> headerFields;

    private final Path tempFile;

    private final FileWriter fileWriter;

    public static <T> CSVWriterRepository build(Class<T> entityType) throws IOException {
        Path tempFile = Files.createTempFile(entityType.getSimpleName().toLowerCase(), ".tmp");
        FileWriter writer = new FileWriter(tempFile.toFile());
        return new CSVWriterRepository(entityType, tempFile, writer);
    }

    private CSVWriterRepository(Class<T> entityType, Path tempFile, FileWriter fileWriter) {
        super(fileWriter, CSV_SEPARATOR, QUOTE_CHAR, ESCAPE_CHAR, LINE_END);
        this.entityType = entityType;
        this.tempFile = tempFile;
        this.fileWriter = fileWriter;
    }

    public List<Field> getHeaderFields() {
        if (headerFields == null) {
            headerFields = Arrays.stream(entityType.getDeclaredFields())
                    .filter(f -> f.isAnnotationPresent(CsvBindByName.class))
                    .sorted((f1, f2) -> {
                        int p1 = 0;
                        int p2 = 0;
                        if (f1.isAnnotationPresent(CsvBindByPosition.class)) {
                            p1 = f1.getAnnotation(CsvBindByPosition.class).position();
                        }
                        if (f2.isAnnotationPresent(CsvBindByPosition.class)) {
                            p2 = f2.getAnnotation(CsvBindByPosition.class).position();
                        }
                        if (p1 == 0 && p2 == 0) {
                            return f1.getAnnotation(CsvBindByName.class).column().compareTo(f2.getAnnotation(CsvBindByName.class).column());
                        }
                        return Integer.compare(p1, p2);
                    })
                    .toList();
        }
        return headerFields;
    }

    public void appendHeader() {
        writeNext(getHeaderFields().stream().map(f -> f.getAnnotation(CsvBindByName.class).column()).toArray(String[]::new), APPLY_QUOTES_TO_ALL);
    }

    public void appendData(T data) {
        if (data == null) {
            return;
        }
        List<String> line = new ArrayList<>();
        getHeaderFields().forEach(field -> {
            try {
                field.setAccessible(true);
                Object value = field.get(data);
                if (value instanceof BigDecimal && field.isAnnotationPresent(CsvNumber.class)) {
                    DecimalFormat decimalFormat = new DecimalFormat(field.getAnnotation(CsvNumber.class).value());
                    decimalFormat.setRoundingMode(field.getAnnotation(CsvNumber.class).roundingMode());
                    value = decimalFormat.format(value);
                } else if (value instanceof TemporalAccessor && field.isAnnotationPresent(CsvDate.class)) {
                    String format = field.getAnnotation(CsvDate.class).value();
                    value = DateTimeFormatter.ofPattern(format).format((TemporalAccessor) value);
                }
                line.add(StringUtils.trimToEmpty(Objects.toString(value, null)));
            } catch (IllegalAccessException e) {
                log.error(String.format("Error while reading field %s", field.getName()), e);
                line.add("");
            }
        });
        writeNext(line.toArray(new String[0]), APPLY_QUOTES_TO_ALL);
    }

    public Path getTempFile() {
        return tempFile;
    }

    @Override
    public void close() throws IOException {
        super.close();
        if (fileWriter != null) {
            fileWriter.close();
        }
    }

}
```
</details>
</p>

