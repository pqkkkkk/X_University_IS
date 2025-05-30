-- SEND NOTIFICATION
    CREATE OR REPLACE PROCEDURE SendNotification (
        p_noidung IN NVARCHAR2,
        p_label IN NVARCHAR2)
    AS
    BEGIN
        INSERT INTO X_ADMIN.THONGBAO (NOIDUNG, LABEL)
        VALUES (p_noidung, CHAR_TO_LABEL('NOTIFICATION_POLICY', p_label));
    COMMIT;
    END SendNotification;
    /
-- GET NOTIFICATION
    CREATE OR REPLACE PROCEDURE getNotification (
        p_result OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN p_result FOR
        SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;
    END getNotification;
    /
-- Load bảng thông báo
CREATE OR REPLACE PROCEDURE X_ADMIN_Select_THONGBAO_Table (
    p_result OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_result FOR
    SELECT MATB, NGAYTB ,NOIDUNG FROM X_ADMIN.THONGBAO;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        OPEN p_result FOR SELECT 'Error occurred' AS MATB, 'Error occurred' AS NGAYTB, 'Error occurred' AS NOIDUNG FROM DUAL;
END X_ADMIN_Select_THONGBAO_Table;
/
GRANT EXECUTE ON X_ADMIN.X_ADMIN_Select_THONGBAO_Table TO PUBLIC;
COMMIT;
-- Lấy các level của policy
CREATE OR REPLACE PROCEDURE X_ADMIN_GetLevels(
    p_result OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_result FOR
    SELECT SHORT_NAME, LONG_NAME FROM DBA_SA_LEVELS
    WHERE POLICY_NAME = 'NOTIFICATION_POLICY';

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        OPEN p_result FOR SELECT 'Error occurred' AS SHORT_NAME, 'Error occurred' AS LONG_NAME FROM DUAL;
END X_ADMIN_GetLevels;
/
-- Lấy các compartments của policy
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetDepartments(
        p_result OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN p_result FOR
        SELECT SHORT_NAME, LONG_NAME FROM DBA_SA_COMPARTMENTS
        WHERE POLICY_NAME = 'NOTIFICATION_POLICY';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            OPEN p_result FOR SELECT 'Error occurred' AS COMPARTMENT_NAME FROM DUAL;
    END X_ADMIN_GetDepartments;
    /
-- Lấy các groups của policy
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetGroups(
        p_result OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN p_result FOR
        SELECT SHORT_NAME, LONG_NAME FROM DBA_SA_GROUPS
        WHERE POLICY_NAME = 'NOTIFICATION_POLICY';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            OPEN p_result FOR SELECT 'Error occurred' AS GROUP_NAME FROM DUAL;
    END X_ADMIN_GetGroups;
    /
-- Gán nhãn bảo mật cho người dùng
CREATE OR REPLACE PROCEDURE X_ADMIN_SetUserLabels(
    policy_name IN VARCHAR2,
    user_name IN VARCHAR2,
    max_read_label IN VARCHAR2,
    def_label IN VARCHAR2
)
AUTHID DEFINER
AS
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => policy_name,
        user_name => user_name,
        max_read_label => max_read_label,
        def_label => def_label
    );
    DBMS_OUTPUT.PUT_LINE('User labels set successfully for ' || user_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error setting user labels: ' || SQLERRM);
        RAISE;
END X_ADMIN_SetUserLabels;
/

-- Kiểm tra user có tồn tại trong bảng
    CREATE OR REPLACE PROCEDURE X_ADMIN_checkExistInTable(
        p_name IN VARCHAR2,
        p_table IN VARCHAR2,
        p_exist OUT NUMBER
    )
    AS
    BEGIN
        IF p_table = 'NHANVIEN' THEN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_table || ' WHERE MANV = :name' INTO p_exist USING p_name;
        ELSIF p_table = 'SINHVIEN' THEN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_table || ' WHERE MASV = :name' INTO p_exist USING p_name;
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_exist := 0;
                DBMS_OUTPUT.PUT_LINE('No data found for ' || p_name || ' in ' || p_table);
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error checking existence: ' || SQLERRM);
                RAISE;
    END X_ADMIN_checkExistInTable;
    /

-- tạo nhãn bảo mật
    CREATE OR REPLACE PROCEDURE X_ADMIN_CreateSecurityLabel(
        v_actual IN VARCHAR2,
        role_name IN VARCHAR2,
        v_label OUT VARCHAR2
    )
    AS
        p_donvi VARCHAR2(10);
        p_coso VARCHAR2(10);
        p_vaitro VARCHAR2(10);
        v_isKhoa NUMBER;
    BEGIN
        IF UPPER(role_name) = 'NHANVIEN' THEN
            SELECT MADV, COSO, VAITRO INTO p_donvi, p_coso, p_vaitro
            FROM X_ADMIN.NHANVIEN
            WHERE MANV = v_actual;
            -- Các nhân viên không phải là giáo viên và trưởng đơn vị các khoa sẽ thuộc department HC
            SELECT COUNT(*) INTO v_isKhoa
            FROM X_ADMIN.DONVI
            WHERE LoaiDV = 'Khoa' AND MADV = p_donvi;

            if UPPER(p_vaitro) = 'TRGDV' AND v_isKhoa > 0 THEN
                v_label := p_vaitro || ':' || p_donvi || ':' || p_coso;
            ELSIF UPPER(p_vaitro) = 'GV' THEN
                v_label := 'NV:' || p_donvi || ':' || p_coso;
            ELSE
                v_label := 'NV:HC:' || p_coso;
            END IF;

        ELSIF UPPER(role_name) = 'SINHVIEN' THEN
            
            SELECT KHOA, COSO INTO p_donvi, p_coso
            FROM X_ADMIN.SINHVIEN
            WHERE MASV = v_actual;

            v_label := 'SV:' || p_donvi || ':' || p_coso;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating security label: ' || SQLERRM);
            RAISE;
    END X_ADMIN_CreateSecurityLabel;
    /
-- kiểm tra user tồn tại
    CREATE OR REPLACE PROCEDURE X_ADMIN_checkExistUser(
        name_ in VARCHAR2,
        exist out NUMBER
    )
    AS 
    BEGIN 

        SELECT COUNT(*) INTO exist
        FROM ALL_USERS 
        WHERE USERNAME = name_;
    END;
    /

-- TẠO USER
    CREATE OR REPLACE PROCEDURE X_ADMIN_createUser(
        user_name IN VARCHAR2, 
        pwd IN VARCHAR2,
        p_role IN VARCHAR2
    )
    AS
        v_exist NUMBER;
        v_label VARCHAR2(100);
        x_vaitro VARCHAR2(20);
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER ' || user_name || ' IDENTIFIED BY "' || pwd || '"';

        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || user_name;
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || user_name;
        EXECUTE IMMEDIATE 'GRANT RESOURCE TO ' || user_name;
        X_ADMIN.X_ADMIN_checkExistInTable(SUBSTR(user_name, 3), p_role, v_exist);
        IF v_exist != 0 THEN 
            BEGIN
                X_ADMIN.X_ADMIN_CREATESECURITYLABEL(SUBSTR(user_name, 3), p_role, v_label);
                X_ADMIN.X_ADMIN_SETUSERLABELS('NOTIFICATION_POLICY', user_name, v_label, v_label);
            END;
        END IF;

        DBMS_OUTPUT.PUT_LINE('User ' || user_name || ' created successfully.');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            RAISE;
    END;
    /
-- Xoá user
    CREATE OR REPLACE PROCEDURE X_ADMIN_deleteUser(user_name in VARCHAR2)
    AS
    BEGIN
        EXECUTE IMMEDIATE 'DROP USER ' || user_name || ' CASCADE';
        DBMS_OUTPUT.PUT_LINE('User dropped successfully.');
        EXCEPTION
        WHEN OTHERS THEN    
        DBMS_OUTPUT.PUT_LINE('USER NOT EXIST');
        RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_deleteUser TO XR_NVTCHC;

    CREATE OR REPLACE PROCEDURE X_ADMIN_updatePassword(
        username in VARCHAR2,
        new_pwd in VARCHAR2
        )
    AS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER USER ' || username || ' IDENTIFIED BY ' || new_pwd;
        EXCEPTION 
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
-- Get all users
    CREATE OR REPLACE PROCEDURE X_ADMIN_getAllUsers(user_list OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN user_list FOR
        SELECT * FROM all_users
        WHERE username LIKE 'X\_%' ESCAPE '\';
    END;
    /

----------------------------------------------------------------------
-- Check role exist 
    CREATE OR REPLACE PROCEDURE X_ADMIN_checkRoleExist(
        roleName IN VARCHAR2,
        exist out NUMBER
    ) 
    AS
    BEGIN
        SELECT COUNT(*) INTO exist
        FROM user_role_privs
        WHERE GRANTED_ROLE = UPPER(roleName);
    END;
    /

-- Create Role
    CREATE OR REPLACE PROCEDURE X_ADMIN_createRole(user_role in VARCHAR2)
    AS
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || user_role;
        DBMS_OUTPUT.PUT_LINE('Role created successfully.');
        EXCEPTION 
            WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            RAISE;
    END;
    /

-- DROP ROLE
    CREATE OR REPLACE PROCEDURE X_ADMIN_dropRole(user_role in VARCHAR2)
    AS
    BEGIN
        EXECUTE IMMEDIATE 'DROP ROLE ' || user_role;
        DBMS_OUTPUT.PUT_LINE('Role dropped successfully.');
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Role not exist.');
            RAISE;
    END;
    /

-- Lấy tất cả các role của user hiện tại
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetAllRoles(
        role_list OUT SYS_REFCURSOR
    ) 
    AS
    BEGIN
        OPEN role_list FOR
            SELECT GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE, OS_GRANTED, COMMON, INHERITED
            FROM user_role_privs;
    END;
    /
-- Lấy danh sách của kiểu object tương ứng (table, view, procedure, function...)
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetAllInstanceOfSpecificObject(
        type IN VARCHAR2, 
        result_ OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('>> Đã nhận tham số object_type: ' || UPPER(type));

        OPEN result_ FOR
        SELECT *
        FROM ALL_OBJECTS
        WHERE OBJECT_TYPE = UPPER(type) AND OWNER = 'X_ADMIN';

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Lỗi: ' || SQLERRM);
    END;
    /

-- Lấy danh sách các cột của table hoặc view
    CREATE OR REPLACE PROCEDURE X_ADMIN_getColumns(
        object_name IN VARCHAR2, 
        result OUT SYS_REFCURSOR
    ) 
    AS
    BEGIN
        OPEN result FOR
            SELECT COLUMN_NAME
            FROM USER_TAB_COLUMNS
            WHERE TABLE_NAME = UPPER(object_name)
            ORDER BY COLUMN_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            OPEN result FOR SELECT 'Table not found' AS COLUMN_NAME FROM DUAL;
        WHEN OTHERS THEN
            OPEN result FOR SELECT 'Error: ' AS COLUMN_NAME FROM DUAL;
    END;
    /
-- Thu hồi quyền cho user/role trên table, view, procedure, function
    CREATE OR REPLACE PROCEDURE X_ADMIN_RevokePrivilegesOfUserOnSpecificObjectType(
        privilege_ IN VARCHAR2,    -- Quyền cần thu hồi
        name_ IN VARCHAR2,         -- Tên user/role muốn thu hồi quyền
        object_ IN VARCHAR2        -- Tên object (table, view, ...)
    )
    AS
    BEGIN
        EXECUTE IMMEDIATE 'REVOKE ' || privilege_ || ' ON ' || object_ || ' FROM ' || name_;
        DBMS_OUTPUT.PUT_LINE('Revoke Privilege successfully from' || name_ || ' on ' || object_ );
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END;
    /
-- Cấp quyền cho user/role trên table, view trên 1 số cột nhất định
    CREATE OR REPLACE PROCEDURE X_ADMIN_GrantPrivilegesOnSpecificColumnsOfTableOrView (
        p_withGrantOption IN VARCHAR2,
        p_privilege IN VARCHAR2,
        p_user    IN VARCHAR2,
        p_columns IN VARCHAR2,
        p_object  IN VARCHAR2 
    )
    AS
        sqlQuery VARCHAR2(4000);
    BEGIN
        sqlQuery := 'GRANT ' || p_privilege || ' (' || p_columns || ') ON ' || p_object || ' TO ' || p_user;
        IF p_withGrantOption = 'YES' THEN
            sqlQuery := sqlQuery || ' WITH GRANT OPTION';
        END IF;

        DBMS_OUTPUT.PUT_LINE('Executing SQL: ' || sqlQuery);

        EXECUTE IMMEDIATE sqlQuery;
        DBMS_OUTPUT.PUT_LINE('Grant privileges on specific columns successfully.');
    EXCEPTION
        WHEN OTHERS THEN
        RAISE;
    END;
    /
-- Lấy danh sách role của user
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetUserRoles(
        p_username IN VARCHAR2, 
        p_roles OUT SYS_REFCURSOR
    ) 
    AS
    BEGIN
        OPEN p_roles FOR
            SELECT * 
            FROM dba_role_privs 
            WHERE GRANTEE = UPPER(p_username);
    END;
    /

-- grant role cho 1 user
    CREATE OR REPLACE PROCEDURE X_ADMIN_grantRole(
        role_name in VARCHAR2,
        user_name in VARCHAR2,
        withGrantOption in VARCHAR2 -- Nếu có truyền 'YES', không truyền 'NO'
        )
    AS
        sqlQuery VARCHAR2(4000);  -- câu lệnh SQL 
    BEGIN
        sqlQuery := 'GRANT ' || role_name || ' TO ' || user_name;
        IF withGrantOption = 'YES' THEN
            sqlQuery:= sqlQuery || ' WITH ADMIN OPTION';
        END IF;
        EXECUTE IMMEDIATE sqlQuery;
        DBMS_OUTPUT.PUT_LINE('Grant roles succesfully');
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_grantRole TO XR_NVTCHC;
-- revoke role khỏi 1 user
    CREATE OR REPLACE PROCEDURE X_ADMIN_revokeRoleFromUser(
        role_ IN VARCHAR2,        
        user_name IN VARCHAR2         
    )
    AS
    BEGIN
        EXECUTE IMMEDIATE 'REVOKE ' || role_ || ' FROM ' || user_name;
        DBMS_OUTPUT.PUT_LINE('Revoke role successfully from ' || user_name);
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END;
    /
-- Lấy danh sách quyền của user/role trên table, view, procedure, function
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetPrivilegesOfUserOnSpecificObjectType(
        name_ IN VARCHAR2,  
        object_type IN VARCHAR2 ,
        result_ OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN result_ FOR
        SELECT *
        FROM DBA_TAB_PRIVS 
        WHERE GRANTEE = UPPER(name_)
        AND TYPE = UPPER(object_type);
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR:' || SQLERRM);
    END;
    /
-- Cấp quyền cho user/role trên table, view, procedure, function
    CREATE OR REPLACE PROCEDURE X_ADMIN_grantPrivileges(
        -- Truyền vào quyền cần cấp, cứ viết theo format của câu SQL nếu muốn cấp nhiều quyền (string là được)
        privilege_ in VARCHAR2, 
        name_ in VARCHAR2, -- Tên user hoặc role muốn cấp
        object_ in VARCHAR2, -- tên object được cấp (table, views,...)
        withGrantOption in VARCHAR2 -- Nếu có truyền 'YES', không truyền 'NO'
        )
    AS
        sqlQuery VARCHAR2(4000);  -- câu lệnh SQL 
    BEGIN
        sqlQuery := 'GRANT ' || privilege_ || ' ON ' || object_ || ' TO ' || name_;
        IF withGrantOption = 'YES' THEN
            sqlQuery:= sqlQuery || ' WITH GRANT OPTION';
        END IF;
        EXECUTE IMMEDIATE sqlQuery;
        DBMS_OUTPUT.PUT_LINE('Grant priviledges succesfully');
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            RAISE;
    END;
    /
-- Lấy danh sách quyền trên cột
    CREATE OR REPLACE PROCEDURE X_ADMIN_GetColumnPrivilegesOfUser(
        name_ IN VARCHAR2,  
        result_ OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN result_ FOR
        SELECT * 
        FROM DBA_COL_PRIVS 
        WHERE GRANTEE = UPPER(name_);
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR:' || SQLERRM);
    END;
    /

    COMMIT;
