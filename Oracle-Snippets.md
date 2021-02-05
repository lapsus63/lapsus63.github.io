## Full Schema Extraction

```sql
-- see https://stackoverflow.com/questions/10886450/how-to-generate-entire-ddl-of-an-oracle-schema-scriptable
-- Before use, replace spool file dest

sqlplus<<EOF
set long 100000
set head off
set echo off
set pagesize 0
set linesize 1000
set verify off
set feedback off
spool "C:\Users\User\Desktop\schema_ENV.sql"

select dbms_metadata.get_ddl(object_type, object_name, owner) from (
    --Convert DBA_OBJECTS.OBJECT_TYPE to DBMS_METADATA object type:
    select owner, object_name, decode(object_type,
            'DATABASE LINK',      'DB_LINK',
            'JOB',                'PROCOBJ',
            'RULE SET',           'PROCOBJ',
            'RULE',               'PROCOBJ',
            'EVALUATION CONTEXT', 'PROCOBJ',
            'CREDENTIAL',         'PROCOBJ',
            'CHAIN',              'PROCOBJ',
            'PROGRAM',            'PROCOBJ',
            'PACKAGE',            'PACKAGE_SPEC',
            'PACKAGE BODY',       'PACKAGE_BODY',
            'TYPE',               'TYPE_SPEC',
            'TYPE BODY',          'TYPE_BODY',
            'MATERIALIZED VIEW',  'MATERIALIZED_VIEW',
            'QUEUE',              'AQ_QUEUE',
            'JAVA CLASS',         'JAVA_CLASS',
            'JAVA TYPE',          'JAVA_TYPE',
            'JAVA SOURCE',        'JAVA_SOURCE',
            'JAVA RESOURCE',      'JAVA_RESOURCE',
            'XML SCHEMA',         'XMLSCHEMA',
            object_type
        ) object_type
    from dba_objects 
    where owner in ('UDH_DBA')
        --These objects are included with other object types.
        and object_type not in ('INDEX PARTITION','INDEX SUBPARTITION','LOB','LOB PARTITION','TABLE PARTITION','TABLE SUBPARTITION')
        --Ignore system-generated types that support collection processing.
        and not (object_type = 'TYPE' and object_name like 'SYS_PLSQL_%')
        --Exclude nested tables, their DDL is part of their parent table.
        and (owner, object_name) not in (select owner, table_name from dba_nested_tables)
        --Exclude overflow segments, their DDL is part of their parent table.
        and (owner, object_name) not in (select owner, table_name from dba_tables where iot_type = 'IOT_OVERFLOW')
)
order by owner, object_type, object_name;


spool off
quit
EOF
```


## Create User From Scratch

```sql
DROP USER MY_NAME CASCADE;

CREATE USER MY_NAME IDENTIFIED BY MY_PASSWORD DEFAULT TABLESPACE TS_NAME TEMPORARY TABLESPACE TMP01 PROFILE MY_PROFILE ACCOUNT UNLOCK;
GRANT CONNECT TO MY_NAME;
GRANT RESOURCE TO MY_NAME; 
```


## Explain Query (Plan Table)

```sql
EXPLAIN PLAN FOR 
SELECT ...;
SELECT * FROM TABLE(dbms_xplan.display);
```

## Query to File

```sql
set heading on
set linesize 1500
set colsep '|'
set numformat 99999999999999999999
set pagesize 25000
spool C:\Users\User\Desktop\myoutputfile.txt
@"C:\Users\User\Desktop\myinputfile.txt"
spool off;
```

## Session Killer

```sql
SELECT 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||''' IMMEDIATE;' FROM v$session;
```

## Table Definitions

```sql
-- Show CREATE TABLE
select dbms_metadata.get_ddl( 'TABLE', 'TABLENAME', 'OWNER_NAME' ) from dual;
-- Show Indexes
SELECT * FROM all_indexes WHERE owner = 'OWNER_NAME' AND table_name = 'TABLENAME';
```


