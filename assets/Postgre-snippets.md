# Postgre Snippets

<details>
<sumary>Full creation script</sumary>

```sql
-- ------------------------------------------------------------------------------------
-- WITH "pgadmin" - connected to default database postgres
-- ------------------------------------------------------------------------------------
​
-- 1. Base roles
​
CREATE ROLE "r_environment_app_name_dba" NOLOGIN;
CREATE ROLE "r_environment_app_name_rw" NOLOGIN;
CREATE ROLE "r_environment_app_name_ro" NOLOGIN;
​
-- 2. DBA user
CREATE ROLE "u_environment_app_name_dba" LOGIN CREATEDB CREATEROLE ENCRYPTED PASSWORD '<PASSWORD>' VALID UNTIL 'infinity' CONNECTION LIMIT 5;
GRANT "r_environment_app_name_dba" to "u_environment_app_name_dba";
​
-- 3. Create database
CREATE DATABASE "environment" with ENCODING='UTF8' owner="pgadmin" connection LIMIT=-1;
GRANT CONNECT ON DATABASE "environment" to "u_environment_app_name_dba";
​
-- ------------------------------------------------------------------------------------
-- WITH "pgadmin" - connected to database environment
-- ------------------------------------------------------------------------------------
​
-- 1. Creation of the schema with DBA as owner
CREATE SCHEMA "app_name_sch" AUTHORIZATION "u_environment_app_name_dba";
ALTER ROLE "r_environment_app_name_dba" in database "environment" set search_path = "app_name_sch";
ALTER ROLE "r_environment_app_name_rw" in database "environment" set search_path = "app_name_sch";
ALTER ROLE "r_environment_app_name_ro" in database "environment" set search_path = "app_name_sch";
​
-- 2. DBA privileges for the schema
GRANT USAGE ON SCHEMA "app_name_sch" to "r_environment_app_name_dba";
GRANT ALL PRIVILEGES ON SCHEMA "app_name_sch" TO "r_environment_app_name_dba";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "app_name_sch" to "r_environment_app_name_dba";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "app_name_sch" TO "r_environment_app_name_dba";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA "app_name_sch" TO "r_environment_app_name_dba";
​
-- 3. RW privileges for the schema
GRANT USAGE ON SCHEMA "app_name_sch" TO "r_environment_app_name_rw";
GRANT CREATE ON SCHEMA "app_name_sch" to "r_environment_app_name_rw";
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "app_name_sch" to "r_environment_app_name_rw";
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_name_sch" GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO "r_environment_app_name_rw";
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_name_sch" GRANT SELECT, UPDATE ON SEQUENCES TO "r_environment_app_name_rw";
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_name_sch" GRANT EXECUTE ON FUNCTIONS TO "r_environment_app_name_rw";
​
-- 4. RO privileges for the schema
GRANT USAGE ON SCHEMA "app_name_sch" TO "r_environment_app_name_ro";
GRANT SELECT ON ALL TABLES IN SCHEMA "app_name_sch" TO "r_environment_app_name_ro";
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_name_sch" GRANT SELECT ON TABLES TO "r_environment_app_name_ro";
​
-- 5. Application user
CREATE ROLE "u_environment_app_name" LOGIN ENCRYPTED PASSWORD '<PASSWORD>' VALID UNTIL 'infinity';
GRANT "r_environment_app_name_rw" to "u_environment_app_name";
​
-- 6. Other functional and nominative accounts
-- CREATE ROLE "u_xxxxxx_ro" LOGIN ENCRYPTED PASSWORD 'PASSWORD' VALID UNTIL 'infinity' CONNECTION LIMIT 5;
-- GRANT "r_environment_app_name_ro" TO u_xxxxxx_ro;
​
```

</details>



<details>
<sumary>Privileges monitoring</sumary>

```sql
-- List users
SELECT * FROM pg_roles where rolname like '%app_name%' and rolcanlogin = true;
SELECT * FROM pg_user;
​
-- Privileges on tables
SELECT grantee, table_schema, table_name, array_agg(privilege_type) as privileges
FROM  information_schema.role_table_grants
WHERE grantee like '%%'
group by grantee, table_schema, table_name
order by 1, 2, 3;
​
-- Privileges on schemas
SELECT n.nspname AS schema, r.rolname AS grantee, has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS usage, has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS create
FROM pg_namespace n, pg_roles r
WHERE n.nspowner = r.oid and r.rolname like '%%' and n.nspname not like 'pg_%' and n.nspname not in ('cron', 'public', 'information_schema')
order by 1, 2, 3;
​
-- List users and roles
SELECT r.rolname as username, r.rolsuper as is_superuser, r.rolcreatedb as can_create_db, r.rolconnlimit as connection_limit, r.rolvaliduntil as valid_until, array_agg(m.rolname) as member_of
FROM pg_roles r LEFT JOIN pg_auth_members am ON r.oid = am.member LEFT JOIN pg_roles m ON am.roleid = m.oid
WHERE r.rolcanlogin = true GROUP BY r.rolname, r.rolsuper, r.rolcreatedb, r.rolconnlimit, r.rolvaliduntil ORDER BY r.rolname;
​
-- Database ownership
SELECT datname AS database_name, pg_catalog.pg_get_userbyid(datdba) AS owner FROM pg_database ORDER BY datname;
​
-- Schema ownership
SELECT n.nspname AS schema_name, r.rolname AS owner FROM pg_namespace n JOIN pg_roles r ON n.nspowner = r.oid
WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname <> 'information_schema' ORDER BY schema_name;
​
-- Object ownership
SELECT n.nspname AS schema, c.relname AS object_name, CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'S' THEN 'sequence' WHEN 'm' THEN 'materialized view' ELSE c.relkind END AS object_type, r.rolname AS owner
FROM pg_class c JOIN pg_roles r ON r.oid = c.relowner JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('cron', 'pg_catalog', 'information_schema', 'pg_toast') AND c.relkind IN ('r', 'v', 'S', 'm')
ORDER BY owner, schema, object_type, object_name;
​
-- Default privileges
SELECT defacl.defaclrole::regrole AS role, n.nspname AS schema, defacl.defaclobjtype AS object_type, defacl.defaclacl AS privileges
FROM pg_default_acl defacl
JOIN pg_namespace n ON defacl.defaclnamespace = n.oid;
​
```
  
</details>


<details>
<sumary>User administration</sumary>

```sql

-- Force password update on first login
CREATE USER new_developer WITH PASSWORD 'PASSWORD' CONNECTION LIMIT 3 PASSWORD_REQUIRED;
​
-- Update existing password
ALTER USER app_prod_webapp WITH PASSWORD 'PASSWORD';
​
-- Revoke/Grant access
ALTER USER u_xxxxxx_ro WITH NOLOGIN; -- WITH LOGIN;
``

</details>
