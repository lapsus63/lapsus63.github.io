# Oracle Snippets

### Full Schema Extraction

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
    where owner in ('OWNER_NAME_HERE')
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


### Create User From Scratch

```sql
DROP USER MY_NAME CASCADE;

CREATE USER MY_NAME IDENTIFIED BY MY_PASSWORD DEFAULT TABLESPACE TS_NAME TEMPORARY TABLESPACE TMP01 PROFILE MY_PROFILE ACCOUNT UNLOCK;
GRANT CONNECT TO MY_NAME;
GRANT RESOURCE TO MY_NAME; 
```


### Explain Query (Plan Table)

```sql
EXPLAIN PLAN FOR 
SELECT ...;
SELECT * FROM TABLE(dbms_xplan.display);
```

### Query to File

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

### Session Killer

```sql
SELECT 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||''' IMMEDIATE;' FROM v$session;
```

Kill sessions from server directly

```bash
ssh oracle-db
sudo su - oracle
ps -ef | grep oracleNAME_OF_SID | awk '{print $2}' | xargs kill -9
```

### Shutdown and restart from server (CLI)

```bash
sudo su - oracle
. ORAENV NAME_OF_SID
sqlplus '/ as sysdba'
shutdown immediate; -- si ca met trop de temps : shutdwon abort
startup
```

### Debugging with SqlDeveloper

- [Oracle Tutorial](https://www.oracle.com/webfolder/technetwork/tutorials/obe/db/sqldev/r30/plsql_debug_OBE/plsql_debug_otn.htm)
- [Failure establishing connection](http://www.dba-oracle.com/t_ora_30683_failure_establishing_connection_to_debugger.htm)



### Table Definitions

```sql
-- Show CREATE TABLE
select dbms_metadata.get_ddl( 'TABLE', 'TABLENAME', 'OWNER_NAME' ) from dual;
-- Show Indexes
SELECT * FROM all_indexes WHERE owner = 'OWNER_NAME' AND table_name = 'TABLENAME';
```


### Get Current Locks

```sql
select c.owner, c.object_name, c.object_type, b.sid, b.serial#, b.status, b.osuser, b.machine
from v$locked_object a , v$session b, dba_objects c
where b.sid = a.session_id
and a.object_id = c.object_id;
```

### Full database text search

```sql
-- see https://stackoverflow.com/questions/208493/search-all-fields-in-all-tables-for-a-specific-value-oracle

SET SERVEROUTPUT ON SIZE 100000;
DECLARE
  match_count INTEGER;
BEGIN
  FOR t IN (SELECT owner, table_name, column_name FROM all_tab_columns WHERE owner = 'xxxxxxxxxx' and data_type LIKE '%CHAR%') LOOP
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || t.owner || '.' || t.table_name || ' WHERE '||t.column_name||' LIKE :1'
      INTO match_count USING '%xxxxx-search-string-here-xxxxxx%';
    IF match_count > 0 THEN
      dbms_output.put_line( t.table_name ||' '||t.column_name||' '||match_count );
    END IF;
  END LOOP;
END;
/

```

