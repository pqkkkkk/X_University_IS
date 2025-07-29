-- Tạo user để test với dữ liệu chỉ thuộc schema của user này,
-- vì em tạo rồi nên em không tạo lại nữa, chỉ cần chạy phần export và import thôi
    CREATE USER datapump_test_user IDENTIFIED BY 123;
    GRANT CONNECT, RESOURCE TO datapump_test_user;
    GRANT CREATE TABLE, CREATE SESSION TO datapump_test_user;
    ALTER USER datapump_test_user QUOTA UNLIMITED ON USERS;
    COMMIT;
-- Tạo data trong schema của user trên để test
    CREATE TABLE DATAPUMP_TEST_USER.DATA_TEST
    (
        ID NUMBER,
        NAME VARCHAR2(50),
        AGE NUMBER
    );
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (1, 'John Doe', 30);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (2, 'Jane Smith', 25);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (3, 'Alice Johnson', 28);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (4, 'Bob Brown', 35);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (5, 'Charlie Davis', 22);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (6, 'Diana Evans', 27);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (7, 'Ethan Foster', 31);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (8, 'Fiona Green', 29);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (9, 'George Harris', 33);
    INSERT INTO DATAPUMP_TEST_USER.DATA_TEST (ID, NAME, AGE) VALUES (10, 'Hannah Ivers', 26);
    COMMIT;

    SELECT * FROM DATAPUMP_TEST_USER.DATA_TEST;
-- Tạo directory object (thay đổi đường dẫn theo hệ thống của bạn)
-- Đường dẫn này là nơi lưu trữ file .dmp và .log sau khi export
-- vì em tạo rồi nên em không tạo lại nữa, chỉ cần chạy phần export và import thôi
    CREATE OR REPLACE DIRECTORY datapump_dir AS 'C:\AppStorage\oracle-datadump-exports';
    GRANT READ, WRITE ON DIRECTORY datapump_dir TO datapump_test_user;

-- Export dữ liệu từ schema của user datapump_test_user
    DECLARE
        h1 NUMBER;
    BEGIN
        -- Mở job export
        h1 := DBMS_DATAPUMP.OPEN(
            operation   => 'EXPORT',
            job_mode    => 'SCHEMA',
            job_name    => 'datapump_test_job10'
        );
        -- Chỉ định nơi xuất file .dmp và .log
        DBMS_DATAPUMP.ADD_FILE(
            handle      => h1,
            filename    => 'datatestbackup.dmp',
            directory   => 'DATAPUMP_DIR'
        );
        DBMS_DATAPUMP.ADD_FILE(
            handle      => h1,
            filename    => 'datatestbackup.log',
            directory   => 'DATAPUMP_DIR',
            filetype    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE
        );
        -- Chỉ định schema cần export (cách đúng trong SCHEMA mode)
        DBMS_DATAPUMP.METADATA_FILTER(h1,
        'SCHEMA_EXPR',
        'IN (''DATAPUMP_TEST_USER'')');
        -- Bắt đầu chạy
        DBMS_DATAPUMP.START_JOB(h1);
        -- Đóng job
        DBMS_DATAPUMP.DETACH(h1);
    END;
    /

-- Tạo user để import dữ liệu vào
-- vì em tạo rồi nên em không tạo lại nữa, chỉ cần chạy phần export và import thôi
    CREATE USER datapump_test_user_import IDENTIFIED BY 123;
    GRANT CONNECT, RESOURCE TO datapump_test_user_import;
    GRANT CREATE TABLE, CREATE SESSION TO datapump_test_user_import;
    ALTER USER datapump_test_user_import QUOTA UNLIMITED ON USERS;
    COMMIT;
-- Import dữ liệu vào schema của user datapump_test_user_import
    DECLARE
        h2 NUMBER;
    BEGIN
        -- Mở job IMPORT
        h2 := DBMS_DATAPUMP.OPEN(
            operation => 'IMPORT',
            job_mode  => 'SCHEMA',
            job_name  => 'datapump_import_job6'
        );
        -- Gán file dump cần import
        DBMS_DATAPUMP.ADD_FILE(
            handle    => h2,
            filename  => 'datatestbackup.dmp',
            directory => 'DATAPUMP_DIR'
        );
        -- Gán file log để theo dõi quá trình import
        DBMS_DATAPUMP.ADD_FILE(
            handle    => h2,
            filename  => 'datatestimport.log',
            directory => 'DATAPUMP_DIR',
            filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE
        );
        DBMS_DATAPUMP.metadata_remap(
                handle     => h2,
                name       => 'REMAP_SCHEMA',
                old_value  => 'DATAPUMP_TEST_USER',
                value      => 'DATAPUMP_TEST_USER_IMPORT');
        -- Bắt đầu job
        DBMS_DATAPUMP.START_JOB(h2);
        -- Tách khỏi job
        DBMS_DATAPUMP.DETACH(h2);
    END;
    /

    DROP TABLE datapump_test_user_import.DATA_TEST;
    SELECT * FROM datapump_test_user_import.DATA_TEST;
COMMIT;