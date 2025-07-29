CREATE OR REPLACE PROCEDURE X_ADMIN_Select_SINHVIEN_Table_ForNVCTSV(
    p_result OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN p_result FOR
        SELECT * FROM X_ADMIN.SINHVIEN;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
GRANT EXECUTE ON X_ADMIN_Select_SINHVIEN_Table_ForNVCTSV TO XR_NVCTSV;

CREATE OR REPLACE PROCEDURE X_ADMIN_Insert_SINHVIEN_Table_ForNVCTSV(
    p_maSV IN VARCHAR2,
    p_hoTen IN VARCHAR2,
    p_phai IN VARCHAR2,
    p_ngSinh IN DATE,
    p_dChi IN VARCHAR2,
    p_dt IN VARCHAR2,
    p_khoa IN VARCHAR2,
    p_coso IN VARCHAR2)
    AS
    BEGIN
        INSERT INTO X_ADMIN.SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DCHI, DT, KHOA, COSO)
        VALUES (p_maSV, p_hoTen, p_phai, p_ngSinh, p_dChi, p_dt, p_khoa, p_coso);

        INSERT INTO X_ADMIN.USER_ROLES (USERNAME, ROLENAME)
        VALUES (p_maSV, 'XR_SV');
        -- X_ADMIN.X_ADMIN_CREATEUSER('X_' || p_maSV, '123');
        -- X_ADMIN.X_ADMIN_GRANTROLE('XR_SV','X_' || p_maSV, 'NO');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
GRANT EXECUTE ON X_ADMIN_Insert_SINHVIEN_Table_ForNVCTSV TO XR_NVCTSV;

CREATE OR REPLACE PROCEDURE X_ADMIN_Update_SINHVIEN_Table_ForNVCTSV(
    p_maSV IN VARCHAR2,
    p_hoTen IN VARCHAR2,
    p_phai IN VARCHAR2,
    p_ngSinh IN DATE,
    p_dChi IN VARCHAR2,
    p_dt IN VARCHAR2,
    p_khoa IN VARCHAR2,
    P_coso IN VARCHAR2)
    AS
    BEGIN
        UPDATE X_ADMIN.SINHVIEN
        SET HOTEN = p_hoTen, PHAI = p_phai, NGSINH = p_ngSinh, DCHI = p_dChi, DT = p_dt, KHOA = p_khoa, COSO = p_coso
        WHERE MASV = p_maSV;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
GRANT EXECUTE ON X_ADMIN_Update_SINHVIEN_Table_ForNVCTSV TO XR_NVCTSV;

CREATE OR REPLACE PROCEDURE X_ADMIN_Delete_SINHVIEN_Table_ForNVCTSV(
    rowAffected OUT INTEGER,
    p_maSV IN VARCHAR2)
    AS
    BEGIN
        DELETE FROM X_ADMIN.SINHVIEN
        WHERE MASV = p_maSV;
        EXECUTE IMMEDIATE 'DELETE FROM X_ADMIN.USER_ROLES WHERE USERNAME = ''' || p_maSV || ''' AND ROLENAME = ''XR_SV''';
        --X_ADMIN.X_ADMIN_DELETEUSER('X_' || p_maSV);
        
        rowAffected := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
GRANT EXECUTE ON X_ADMIN_Delete_SINHVIEN_Table_ForNVCTSV TO XR_NVCTSV;
COMMIT;