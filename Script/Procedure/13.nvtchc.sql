-- SELECT TRÊN BẢNG NHÂN VIÊN
    CREATE OR REPLACE PROCEDURE X_ADMIN_SELECT_NHANVIEN_TABLE_FOR_NVTCHC(
        p_result OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN p_result FOR
        SELECT * FROM X_ADMIN.NHANVIEN;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_SELECT_NHANVIEN_TABLE_FOR_NVTCHC TO XR_NVTCHC;
-- UPDATE TRÊN BẢNG NHÂN VIÊN
    CREATE OR REPLACE PROCEDURE X_ADMIN_UPDATE_NHANVIEN_TABLE_FOR_NVTCHC (
        MaNLD    IN VARCHAR2,
        p_HoTen    IN VARCHAR2,
        p_PHAI     IN VARCHAR2,
        NgaySinh IN DATE,
        p_Luong    IN INTEGER,
        p_PhuCap   IN INTEGER,
        SDT      IN VARCHAR2,
        p_VaiTro   IN VARCHAR2,
        p_MaDV     IN VARCHAR2,
        p_row_affected OUT INTEGER
    ) AS
    BEGIN
        UPDATE X_ADMIN.NHANVIEN
        SET
            HOTEN  = p_HoTen,
            PHAI   = p_PHAI,
            NGSINH = NgaySinh,
            LUONG  = p_Luong,
            PHUCAP = p_PhuCap,
            DT     = SDT,
            VAITRO = p_VaiTro,
            MADV   = p_MaDV
        WHERE MANV = MaNLD;

        p_row_affected := SQL%ROWCOUNT;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_UPDATE_NHANVIEN_TABLE_FOR_NVTCHC TO XR_NVTCHC;
-- DELETE TRÊN BẢNG NHÂN VIÊN
    CREATE OR REPLACE PROCEDURE X_ADMIN_DELETE_NHANVIEN_TABLE_FOR_NVTCHC(
        MaNLD IN VARCHAR2,
        VaiTro IN VARCHAR2)
    AS 
    BEGIN
        EXECUTE IMMEDIATE 'DELETE FROM X_ADMIN.NHANVIEN WHERE MANV = ''' || MaNLD || '''';
        EXECUTE IMMEDIATE 'DELETE FROM X_ADMIN.USER_ROLES WHERE USERNAME = ''' || MaNLD || ''' AND ROLENAME = ''XR_' || VaiTro || '''';
        X_ADMIN.X_ADMIN_DELETEUSER('X_' || MaNLD);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_DELETE_NHANVIEN_TABLE_FOR_NVTCHC TO XR_NVTCHC;
-- INSERT TRÊN BẢNG NHÂN VIÊN
    CREATE OR REPLACE PROCEDURE X_ADMIN_INSERT_NHANVIEN_TABLE_FOR_NVTCHC(
        MaNLD IN VARCHAR2,
        HoTen IN VARCHAR2,
        PHAI IN VARCHAR2,
        NgaySinh IN DATE,
        Luong IN INTEGER,
        PhuCap IN INTEGER,
        SDT IN VARCHAR2,
        VaiTro IN VARCHAR2,
        MaDV IN VARCHAR2,
        COSO IN VARCHAR2)
    AUTHID DEFINER
    AS
        v_label VARCHAR2(100);
        v_isKhoa NUMBER := 0;
    BEGIN
        INSERT INTO X_ADMIN.NHANVIEN 
            (MANV, HOTEN, PHAI, NGSINH, LUONG, PHUCAP, DT, VAITRO, MADV, COSO)
        VALUES (MaNLD, HoTen, PHAI, NgaySinh, Luong, PhuCap, SDT, VaiTro, MaDV, COSO);

        INSERT INTO X_ADMIN.USER_ROLES (USERNAME, ROLENAME)
        VALUES (MaNLD, 'XR_' || VaiTro);    
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_INSERT_NHANVIEN_TABLE_FOR_NVTCHC TO XR_NVTCHC;

COMMIT;