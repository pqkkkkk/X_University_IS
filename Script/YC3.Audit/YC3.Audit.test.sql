select value
from v$option
where parameter = 'Unified Auditing';

SHOW PARAMETER audit_trail;

SELECT * FROM DBA_AUDIT_TRAIL;

SELECT CURRENT_USER,
       ACTION_NAME,
       OBJECT_NAME,
       EVENT_TIMESTAMP,
       SQL_TEXT, 
       RETURN_CODE,
       FGA_POLICY_NAME
FROM UNIFIED_AUDIT_TRAIL
--WHERE FGA_POLICY_NAME = 'AUDIT_INSERT_UPDATE_DELETE_DANGKY' OR FGA_POLICY_NAME ='AUDIT_NOT_IN_MODIFY_TIME_DANGKY'
ORDER BY EVENT_TIMESTAMP DESC;

SELECT * FROM SYS.AUD$
ORDER BY NTIMESTAMP# DESC;
SELECT * FROM X_ADMIN.DANGKY;
SElECT * FROM X_ADMIN.NHANVIEN;
SELECT * FROM X_ADMIN.MOMON;
-- Hoặc bảng view tiện lợi hơn:
SELECT * FROM DBA_AUDIT_TRAIL;
SELECT * FROM DBA_FGA_AUDIT_TRAIL
ORDER BY TIMESTAMP DESC;
SELECT * FROM UNIFIED_AUDIT_TRAIL ORDER BY EVENT_TIMESTAMP DESC;
SELECT * FROM DBA_AUDIT_POLICIES;

-- 3.1
    -- a
        update  X_ADMIN.DANGKY
        set DIEMTH = 8
        where MASV = 'SV0014' AND MAMM = 'MM013';
        COMMIT;

        BEGIN
        DBMS_FGA.drop_policy(
        object_schema => 'X_ADMIN',
        object_name   => 'DANGKY',
        policy_name   => 'AUDIT_UPDATE_DIEM'
        );
        END;
        /

        select * from X_ADMIN.DANGKY;
    -- b
        BEGIN
            DBMS_FGA.drop_policy(
            object_schema => 'X_ADMIN',
            object_name   => 'NHANVIEN',
            policy_name   => 'AUDIT_SELECT_NHANVIEN'
            );
        END;
        /
        select LUONG, PHUCAP from X_ADMIN.NHANVIEN;
    -- c
        BEGIN
            DBMS_FGA.drop_policy(
            object_schema => 'X_ADMIN',
            object_name   => 'DANGKY',
            policy_name   => 'AUDIT_NOT_IN_MODIFY_TIME_DANGKY'
            );
        END;
        /

        update X_ADMIN.DANGKY
        SET MAMM = 'MM011'
        WHERE MASV = 'SV0010';

        BEGIN
            DBMS_FGA.drop_policy(
            object_schema => 'X_ADMIN',
            object_name   => 'DANGKY',
            policy_name   => 'AUDIT_INSERT_UPDATE_DELETE_DANGKY'
            );
        END;
        /

        update X_ADMIN.DANGKY
        SET MAMM = 'MM009'
        WHERE MASV = 'SV0010';

        SELECT *
        FROM dba_audit_policies
        WHERE object_schema = 'X_ADMIN'
        AND object_name = 'DANGKY';