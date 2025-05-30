-- Create admin user
CREATE USER X_ADMIN IDENTIFIED BY 123;
GRANT CONNECT TO X_ADMIN WITH ADMIN OPTION;
GRANT RESOURCE TO X_ADMIN WITH ADMIN OPTION;
GRANT CREATE USER, ALTER USER, DROP USER TO X_ADMIN;
GRANT CREATE SESSION TO X_ADMIN WITH ADMIN OPTION;
GRANT SELECT ANY DICTIONARY TO X_ADMIN;
GRANT CREATE ROLE TO X_ADMIN;
GRANT GRANT ANY PRIVILEGE TO X_ADMIN;
GRANT CREATE SESSION TO X_ADMIN;
GRANT CREATE ANY CONTEXT TO X_ADMIN;
GRANT ADMINISTER DATABASE TRIGGER TO X_ADMIN;
GRANT CREATE ANY VIEW TO X_ADMIN;
GRANT EXECUTE ON DBMS_RLS TO X_ADMIN;
GRANT CREATE VIEW TO X_ADMIN;
GRANT CREATE TRIGGER TO X_ADMIN;
GRANT DBA TO X_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_COMPONENTS TO X_ADMIN WITH GRANT OPTION;
GRANT EXECUTE ON LBACSYS.sa_user_admin TO X_ADMIN WITH GRANT OPTION;
GRANT EXECUTE ON LBACSYS.sa_label_admin TO X_ADMIN WITH GRANT OPTION;
GRANT EXECUTE ON sa_policy_admin TO X_ADMIN WITH GRANT OPTION;
GRANT EXECUTE ON char_to_label TO X_ADMIN WITH GRANT OPTION;
GRANT INHERIT PRIVILEGES ON USER LBACSYS TO X_ADMIN WITH GRANT OPTION;
GRANT LBAC_DBA TO X_ADMIN;
GRANT EXECUTE ON sa_sysdba TO X_ADMIN;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO X_ADMIN;
GRANT SELECT ON DBA_SA_COMPARTMENTS TO X_ADMIN WITH GRANT OPTION;
GRANT SELECT ON DBA_SA_LEVELS TO X_ADMIN WITH GRANT OPTION;
GRANT SELECT ON DBA_SA_GROUPS TO X_ADMIN WITH GRANT OPTION;
GRANT SELECT ON DBA_SA_LABELS TO X_ADMIN WITH GRANT OPTION;

ALTER USER X_ADMIN QUOTA UNLIMITED ON USERS;

COMMIT;

