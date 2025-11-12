# Flink Overview

## Documentation

- Workshopby Eric Carlier (Confluent) [https://docs.confluent.io/platform/current/streams/developer-guide/dsl-api.html](https://docs.confluent.io/platform/current/streams/developer-guide/dsl-api.html)

## Overview

- Flink is top 5 Apache projects in 2024.
- Confluent Cloud Flink : remove complexity of cluster management etc. Workspaces, available topics, etc.

| ksqldb + streams           | Flink                                                    |
|----------------------------|----------------------------------------------------------|
| Required versionJava + SQL | Java, Python, SQL                                        |
| related to Kafka only      | Data driven architecture agnostic (Kafka, MQ, DB, ...)   |
| Java softwares, web apps   | Data scientists, data analysts                           |
| Event driven               | Real Time analytics ; Streaming data pipelines           |

- Flink use pools : logical unit to do processing. A pool is associated to a project/namespace.
- CFU : computing unit. Can be run in parallel. cost evaluated by number of CFU by minute.
- Confluent CLI is available :

```bash
# Ex
confluent flink shell --compute-pool lfcp-wy6m7j --environment env-7qkvzj
```

- SQL processing from workspace :

```sql
SHOW catalogs;
DESCRIBE EXTENDED shoe_orders;
-- Select data from a table in streaming mode (updated continiously):
select * from shoe_customers;
```
