-- select all tables which this user created
SELECT * FROM ALL_ALL_TABLES WHERE OWNER = 'SYS' ORDER BY TABLE_NAME;

-- select all users
SELECT * FROM ALL_USERS;

-- select all views
SELECT VIEW_NAME FROM ALL_VIEWS WHERE OWNER = 'c##admin';
-- select all stored procedures
SELECT OBJECT_NAME FROM ALL_OBJECTS WHERE OBJECT_TYPE = 'PROCEDURE' AND OWNER = 'c##admin';

-- select all users (only for dba)
SELECT username FROM dba_users ORDER BY username;

-- select all tables which this user created (only for dba)
SELECT * FROM dba_tables WHERE  OWNER = 'C##ADMIN1';
SELECT * FROM user_tables WHERE table_name = 'NHANVIEN';
-- select all role which this user created (only for dba)
SELECT * FROM dba_roles WHERE ORACLE_MAINTAINED = 'N' ORDER BY role;

-- select all role which this user has (only for dba)
SELECT * FROM user_role_privs;

-- select all privileges which this user has
SELECT *
FROM user_sys_privs WHERE privilege LIKE '%ANY%';
--  select all privileges which this user has on tables
SELECT * FROM user_tab_privs WHERE grantee = 'X_SV0001';

SELECT * FROM user_col_privs;
-- select all privileges which specific role has
SELECT *
FROM role_tab_privs WHERE ROLE = 'XR_SV';


-- DBA Views
SELECT * FROM DBA_USERS;
SELECT * FROM DBA_SYS_PRIVS;
SELECT * FROM DBA_ROLES;
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'X_SV0001';
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE LIKE 'XR_%';
SELECT * FROM ROLE_TAB_PRIVS;
SELECT * FROM DBA_COL_PRIVS;
-- get all procedures of a user
SELECT * FROM DBA_OBJECTS WHERE OBJECT_TYPE = 'PROCEDURE' AND OBJECT_NAME LIKE '%Privilege%';
SELECT * FROM v$database;
SELECT * FROM v$pdbs;

-- Query metadata of X_ADMIN schema
    -- Tables 
    SELECT *
    FROM   all_objects
    WHERE  owner = 'X_ADMIN' and object_type = 'TABLE';

            SELECT *
        FROM ALL_OBJECTS
        WHERE OBJECT_TYPE = UPPER('Table') AND OWNER = 'X_ADMIN';

    -- Views
    SELECT view_name
    FROM   all_views
    WHERE  owner = 'X_ADMIN';

    -- Procedures and Functions
    SELECT *
    FROM   all_objects
    WHERE  owner = 'X_ADMIN' AND object_type IN ('TABLE');

    -- Roles
    SELECT *
    FROM   user_role_privs 
    WHERE  grantee LIKE 'X_%';
    SELECT * 
    FROM ROLE_TAB_PRIVS WHERE ROLE LIKE 'XR_%';
    SELECT * FROM all_users;

SELECT * 
FROM DBA_POLICIES
WHERE OBJECT_NAME = 'DANGKY';

SELECT *
FROM   all_objects
WHERE  owner = 'X_ADMIN'
AND  object_type = 'VIEW';

SELECT *
FROM USER_TAB_PRIVS;
SELECT * 
FROM USER_COL_PRIVS;
SELECT * 
FROM ROLE_TAB_PRIVS WHERE OWNER = 'X_ADMIN';

SELECT * FROM ALL_VIEWS WHERE OWNER = 'X_ADMIN';

SELECT *
FROM ALL_TAB_COLUMNS
WHERE TABLE_NAME = 'NHANVIEN' AND OWNER = 'X_ADMIN';

SELECT * FROM DBA_TABLESPACES;
