-- Trước tiên cần tạo pdb để test, tránh ảnh hưởng đến dữ liệu thực tế
-- Tạo tablespace để test trên pdb mới tạo (thay đổi đường dẫn theo hệ thống của bạn)
-- vì em đã tạo tablespace rồi nên em sẽ không tạo lại nữa
    create tablespace users datafile 'c:\AppStorage\oracle-db\oradata\XE\XEPDB3\users01.dbf' 
    size 10M autoextend on next 10M maxsize unlimited;
    CREATE USER local_user_xepdb3 IDENTIFIED BY 123;
    GRANT CONNECT, RESOURCE TO local_user_xepdb3;
    GRANT CREATE TABLE, CREATE SESSION TO local_user_xepdb3;
    alter USER local_user_xepdb3 quota unlimited on USERS;
    COMMIT;
-- Tạo data để test
    CREATE TABLE local_user_xepdb3.PITR_DATA_TEST
    (
        ID NUMBER,
        NAME VARCHAR2(50),
        AGE NUMBER
    ) TABLESPACE USERS;
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (1, 'John Doe', 30);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (2, 'Jane Smith', 25);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (3, 'Alice Johnson', 28);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (4, 'Bob Brown', 35);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (5, 'Charlie Davis', 22);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (6, 'Diana Evans', 27);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (7, 'Ethan Foster', 31);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (8, 'Fiona Green', 29);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (9, 'George Harris', 33);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (10, 'Hannah Ivers', 26);
    INSERT INTO local_user_xepdb3.PITR_DATA_TEST (ID, NAME, AGE) VALUES (11, 'Ian Johnson', 24);
    COMMIT;

-- Lấy SCN tại thời điểm trước khi thực hiện xóa dữ liệu để sử dụng trong PITR recovery với RMAN
    SELECT TIMESTAMP_TO_SCN(sysdate) from v$database;
-- Xóa data để test phục hồi
    DELETE FROM local_user_xepdb3.PITR_DATA_TEST WHERE ID IN (1, 2, 3, 4,5);
    COMMIT;
-- Đóng PDB để thực hiện recovery
    ALTER PLUGGABLE DATABASE XEPDB3 CLOSE IMMEDIATE;
-- Chạy recovery PITR để khôi phục dữ liệu trước thời điểm xóa DL với RMAN  (chạy trên CLI RMAN, không phải trong SQL*Plus)
    -- RMAN> CONNECT TARGET /
    -- RMAN> run{
    -- 2> set until scn = 29823471;
    -- 3> restore pluggable database xepdb3;
    -- 4> recover pluggable database xepdb3;
    -- 5> alter pluggable database xepdb3 open resetlogs;
    -- 6> }
-- Kết nối lại vào PDB và truy vấn dữ liệu để kiểm tra kết quả phục hồi
    SELECT * FROM local_user_xepdb3.PITR_DATA_TEST;