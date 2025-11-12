# Kafka Overview

## Documentation

- https://docs.confluent.io/platform/current/streams/developer-guide/dsl-api.html


## CLI operations

### Common variables initiatization

```bash
export MY_TOPIC=ocr-topic
export KAFKA_SERVERS=kafka-1:9092,kafka-2:9092,kafka-3:9092
export REGISTRY_SERVER=http://schema-registry:8081
```

### Implement Java Kafka Connector


<p><details>
<summary>KafkaConnector.java</summary>
    
```java
Properties p = new Properties();

//common
p.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, ...);
p.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, ...);
p.put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, ...);
p.put(AbstractKafkaSchemaSerDeConfig.AUTO_REGISTER_SCHEMAS, false);

//security
p.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, ...);
p.put(SchemaRegistryClientConfig.BASIC_AUTH_CREDENTIALS_SOURCE, ...));
p.put(SchemaRegistryClientConfig.USER_INFO_CONFIG, ...);
p.put(SaslConfigs.SASL_MECHANISM, ...);
p.put(SaslConfigs.SASL_JAAS_CONFIG, ...);

//consumer part:
p.put("topic", ...);
p.put("poll.delay", ...);
p.put("retry.delay", ...);
p.put(ConsumerConfig.GROUP_ID_CONFIG, ...);
p.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, ...);
p.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, ...);
p.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, ...);
p.put(KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, true);
/* Fine tuning ; see also https://learn.conduktor.io/kafka/kafka-options-explorer/ */
p.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, ...);
p.put(ConsumerConfig.MAX_PARTITION_FETCH_BYTES_CONFIG, ...);
p.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, ...);
p.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, ...);


// producer part:
p.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, ...);
p.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ...);
p.put("avro.remove.java.properties", true);
```

</details>

### TOPICS

From kafka-connect :

```bash

# Create a topic :
kafka-topics --create \
    --bootstrap-server $KAFKA_SERVERS \
    --topic $MY_TOPIC \
    --replication-factor 3 \
    --partitions 3 \
    --config cleanup.policy=delete \
    --config segment.bytes=1073741824

# List topics
kafka-topics --list \
    --bootstrap-server $KAFKA_SERVERS

# Detail of a topic
kafka-topics --describe \
    --topic $MY_TOPIC \
    --bootstrap-server $KAFKA_SERVERS
    
# Update a topic configuration
kafka-configs --zookeeper $ZOOKEEPER_SERVER \
    --alter \
    --entity-type topics \
    --entity-name $MY_TOPIC \
    --add-config retention.ms=604800000
kafka-configs --zookeeper $ZOOKEEPER_SERVER \
    --alter \
    --entity-type topics \
    --entity-name $MY_TOPIC \
    --delete-config segment.bytes

# Delete a topic
kafka-topics --delete \
    --topic $MY_TOPIC \
    --bootstrap-server $KAFKA_SERVERS
```

### La rétention des données

- Delete : Se fait par rapport au temps, suppression par segment (date dernier message du segment)
- Compact : pour les référentiels : garde la dernière valeur pour une même clé => topics lus en tant que KTable par le consumer



## PRODUCERS

From kafka-connect :

```bash
# start a producer command line
kafka-console-producer --broker-list $KAFKA_SERVERS \
    --topic $MY_TOPIC

# produce Avro records
export SCHEMA_V1='{"type":"record","name":"consoleRecord","fields":[{"name":"prop1","type":"string"}, {"name":"prop2","type":"string", "default": "prop2 default value"} ]}'
export SCHEMA_V2='{"type":"record","name":"consoleRecord","fields":[{"name":"prop1","type":"string"}, {"name":"prop3","type":"string", "default": "my prop 3 default"} ]}'
kafka-avro-console-producer --broker-list $KAFKA_SERVERS \
    --topic $MY_TOPIC \
    --property schema.registry.url=$REGISTRY_SERVER \
    --property value.schema="$SCHEMA_V1"
# {"prop1": "my prop1 first value", "prop2": "my prop2 first value"}
```

Important settings:

```properties
enable.idempotence=
# recommended : true (make messages appear once)

acks=
# Nb validations que le producer demande pour valider l'envoi du message. 0 ou 1 : message non répliqué. all: répliqué partout
# default: 1, recommended: all (prod)

retries=
# Ordre messages non garanti si retry nécessaire. Garantir l'ordre: max.in.flight.Request.per.connection=1 (par défaut = 5)
# default: infinite
# recommended: INT.MAX (actual value depends whether java lib or c++ librdkafka is used)

bootstrap.servers=
# liste des serveurs (2 ou 3) à utiliser en tant que point d'entrée aux brokers kafka

key.serializer=
value.serializer=
# interface Serializer (StringSerializer.class, ...)

compression.type=
# none / snappy / gzip / lz4 //  Taille des messages limitée à 1M

batch.size=
# taille du batch ; 16Kb par défaut ; gestion du débit

linger.ms=
# temps d'attente avant d'envoyer un batch ; 0 par défaut; batch part dès qu'il est plein (faible latence = petites valeurs)

buffer.memory=
# default 32MB
```

### PRODUCER Java implementation


<p><details>
<summary>AbstractKafkaProducer.java</summary>
    
```java
    private final Environment env;
    private final KafkaProducer<K, V> producer;

    public AbstractKafkaProducer(Environment env, KafkaProducer<K, V> producer) {
        this.env = env;
        this.producer = producer;
    }

    @Observed
    public void write(String topic, K key, V value) {
        List<Header> headers = List.of(
                new RecordHeader("traceparent", OpenTelemetryUtils.getTraceParent().getBytes(StandardCharsets.UTF_8)));
        sendRecord(new ProducerRecord<>(topic, null, key, value, headers));
    }

    protected void sendRecord(ProducerRecord<K, V> producerRecord) {
        try {
            // Asynchronous (add .get() to make it synchronous)
            producer.send(producerRecord, getDefaultCallback());
        } catch (Exception e) { }
    }

    /**
     * @return a default function to handle responses from Kafka API after a send event.
     */
    private Callback getDefaultCallback() {
        return (RecordMetadata metadata, Exception e) -> {
            if (e instanceof AuthenticationException) {
                /* log... */
            }
            if (metadata == null) {
                /* log... */
            } else if (e != null && log.isErrorEnabled()) {
                /* log... */
            } else if (log.isDebugEnabled()) {
                /* log... */
            }
        };
    }
```

</details>



## CONSUMERS

From kafka-connect :

```bash
# start a consumer command line
kafka-console-consumer --bootstrap-server $KAFKA_SERVERS \
    --topic $MY_TOPIC \
    --group group2 \
    --from-beginning
kafka-avro-console-consumer --bootstrap-server $KAFKA_SERVERS \
    --topic $MY_TOPIC \
    --property schema.registry.url=$REGISTRY_SERVER \
    --from-beginning 
    
# Describe consumer group
kafka-consumer-groups --bootstrap-server $KAFKA_SERVERS \
    --describe \
    --group group2
```

Important settings:

```properties
```


### CONSUMER Java implementation


<p><details>
<summary>AbstractKafkaConsumer.java</summary>
    
```java
@Getter
public abstract class AbstractKafkaConsumer<K, V extends SpecificRecord> {

    private final Consumer<K, V> consumer;
    private final Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();

    protected AbstractKafkaConsumer(Consumer<K, V> consumer) {
        this.consumer = consumer;
    }

    protected abstract String getTopic();
    protected abstract String getAutoOffsetReset();
    protected abstract int getPollDelay();
    protected abstract int getRetryDelay();
    protected abstract boolean canProcess(ConsumerRecord<K, V> consumerRecord);    
    public abstract void processRecord(ConsumerRecord<K, V> consumerRecord);
    public abstract void flushBatch();

    /**
     * Listening of Kafka records in an infinite loop (entrypoint)
     */
    public void monitor() {
        consumer.subscribe(Collections.singleton(getTopic()), new LogRebalanceListener<>(consumer, offsets));
        boolean canMonitor = true;
        while (canMonitor) {
            try {
                listenRecords();
            } catch (InterruptException ie) {
                /* Program killed */
                canMonitor = false;
            } catch (SslAuthenticationException sslEx) {
                canMonitor = false;
            } catch (Exception e) {
                try {
                    TimeUnit.MILLISECONDS.sleep(getRetryDelay());
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    private boolean isPaused(Consumer<K, V> consumer) {
        return !consumer.paused().isEmpty();
    }

    /** Update map offset to the new valid offset positions */
    private void updateOffsetsPosition(ConsumerRecord<K, V> consumerRecord) {
        offsets.put(new TopicPartition(consumerRecord.topic(), consumerRecord.partition()), new OffsetAndMetadata(consumerRecord.offset() + 1));
    }

    private void rewind(Consumer<K, V> consumer) {
        if (offsets.isEmpty()) {
            // if this is the first time you don't have any offset committed yet, that's unfortunate that you get both no position and a failure, but here would be a path to handle this case
            if ("earliest".equals(StringUtils.defaultIfBlank(getAutoOffsetReset(), "earliest"))) {
                consumer.seekToBeginning(consumer.assignment());
            } else if ("latest".equals(getAutoOffsetReset())) {
                consumer.seekToEnd(consumer.assignment());
            }
        }
        // if we already have committed position
        for (Map.Entry<TopicPartition, OffsetAndMetadata> entry : offsets.entrySet()) {
            if (entry.getValue() != null) {
                consumer.seek(entry.getKey(), entry.getValue());
            }
        }
    }

    /**
     * Iteration of infinite loop listening Kafka Topic
     */
    public void listenRecords() {
        ConsumerRecords<K, V> records = consumer.poll(Duration.ofMillis(getPollDelay()));
        if (isPaused(consumer)) {
            consumer.resume(consumer.assignment());
        }
        for (ConsumerRecord<K, V> consumerRecord : records) {
            try {
                processAndUpdate(consumerRecord);
            } catch (Exception e) {
                break;
            }
        }
        if (!records.isEmpty() && !isPaused(consumer)) {
            flushAndCommit();
        }
    }

    private void flushAndCommit() {
        try {
            flushBatch();
            consumer.commitSync(offsets);
        } catch (CommitFailedException e) { }
    }

    private void processAndUpdate(ConsumerRecord<K, V> consumerRecord) {
        try {
            if (canProcess(consumerRecord)) {
                processRecord(consumerRecord);
            }
        } catch (Exception e) {
            consumer.pause(consumer.assignment());
            rewind(consumer);
            throw e;
        }
        updateOffsetsPosition(consumerRecord);
    }

    public void stop() {
        consumer.close();
    }
}  
```

</details>


<p><details>
<summary>LogRebalanceListener.java</summary>
    
```java
@Override
public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
    for (TopicPartition topicPartition : partitions) {
        offsets.remove(topicPartition);
    }
}

@Override
public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
    Map<TopicPartition, OffsetAndMetadata> committed = consumer.committed(new HashSet<>(partitions));
    if (committed != null) {
        for (Map.Entry<TopicPartition, OffsetAndMetadata> entry : committed.entrySet()) {
            if (entry.getValue() != null) {
                offsets.put(entry.getKey(), entry.getValue());
            } else {
                offsets.remove(entry.getKey());
            }
        }
    }
}
```

</details>


## SCHEMA REGISTRY

Schema definition is mandatory for public Topics. These Schemas must be validated by Data Architect

From kafka-connect or postman :

```bash
# get subjects
curl $REGISTRY_SERVER/subjects
curl $REGISTRY_SERVER/subjects/$MY_TOPIC-value/versions
curl $REGISTRY_SERVER/subjects/$MY_TOPIC-value/versions/{version_number}
curl $REGISTRY_SERVER/subjects/$MY_TOPIC-value/versions/{version_number}/schema
```

## REST PROXY

Image docker: confluentinc/cp-kafka-rest:6.2.0 [Documentation](https://docs.confluent.io/platform/current/kafka-rest/quickstart.html)

Contrôle des composants Kafka via une API REST :

- Produire/Consommer du Json/Avro/Binary/...
- Inspection des topics (GET /topics, GET /topics/topic-name, GET /topics/topic-name/partitions, ...)
- 


## Insync replicas

- ISR List = liste des leaders + followers pour une partition
- Configure si les replicas doivent avoir reçu et acquité les messages avant qu'il puisse être lu par les consumers
- Si un broker tombe, ISR list est réduite, le message peut-être lu car les messages seront acquités par tous les replica actifs
- La variable min.sync.replicas permet de configurer le min nécessaire d'acquittements pour pouvoir produire

```bash
kafka-topics --describe --topic topic_name
```

## CONNECTORS

Error management:

```properties
errors.tolerance=
# Error handling. Recommended value : "all"

errors.log.enable=
# Error handling. Recommended value : "true"

errors.log.include.messages=
# Error handling. Recommended value : "true"

errors.deadletterqueue.topic.name=
# Error handling. Possible values : "FDW-sink-machine_state-dlq", ...

errors.deadletterqueue.context.headers.enable=
# Error handling. Recommended value : "true"
```

## CONNECTOR KafkaGen

* Ex. `./kafkagen-x.x.x-windows.exe produce -f=message.json topic_name`
* message.json:

```json
[
 {
    "key": "key",
    "value": {
      "param1": "param1",
      "param2": "param2"
    }
 }
]
```

* ~/.kafkagen/config.yml:

```yaml
kafkagen:
 contexts:
 - name: ctx-name
   context:
     bootstrap-servers: 
     security-protocol: 
     sasl-mechanism: 
     sasl-jaas-config: org.apache.kafka.common.security.plain.PlainLoginModule required username="******" password="******";
     registry-url: 
     registry-username: 
     registry-password: 
     group-id-prefix: 
 current-context: ctx-name
```
