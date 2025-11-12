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
