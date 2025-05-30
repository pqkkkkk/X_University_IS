﻿--Tạo procedure để insert 1 dòng trên view_PDT_MOMON dành cho NV PDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_insert_view_PDT_MOMON(
        MaMM IN VARCHAR2,
        MaHP IN VARCHAR2,
        MaGV IN VARCHAR2,
        HK IN INT,
        NAM IN INT
    )
    AS
    BEGIN
        INSERT INTO X_ADMIN.view_PDT_MOMON (MaMM, MaHP, MaGV, HK, NAM)
        VALUES (MaMM, MaHP, MaGV, HK, NAM);
    END X_ADMIN_insert_view_PDT_MOMON;
    /

    GRANT EXECUTE ON X_ADMIN.X_ADMIN_insert_view_PDT_MOMON TO XR_NVPDT;

--Tạo procedure để delete 1 dòng trên view_PDT_MOMON dành cho NVPDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_delete_view_PDT_MOMON(
        Ma IN VARCHAR2
    )
    AS
    BEGIN
        DELETE FROM view_PDT_MOMON
        WHERE MAMM = Ma;
    END X_ADMIN_delete_view_PDT_MOMON;
    /

    GRANT EXECUTE ON X_ADMIN_delete_view_PDT_MOMON TO XR_NVPDT;

--Tạo procedure để update trên view_PDT_MOMON dành cho NVPDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_update_view_PDT_MOMON(
        MaMM_ IN VARCHAR2,
        MaHP_ IN VARCHAR2,
        MaGV_ IN VARCHAR2,
        HK_ IN INT,
        NAM_ IN INT,
        ROW_AFFECTED OUT NUMBER
    )
    AS
        rows1 NUMBER := 0;
        rows2 NUMBER := 0;
    BEGIN
        UPDATE X_ADMIN.view_PDT_MOMON
        SET MaHP = MaHP_,
            MaGV = MaGV_
        WHERE MaMM = MaMM_;
        rows1 := SQL%ROWCOUNT;

        UPDATE X_ADMIN.MOMON
        SET HK = HK_,
            NAM = NAM_
        WHERE MaMM = MaMM_;
        rows2 := SQL%ROWCOUNT;

        ROW_AFFECTED := rows1 + rows2;
    END X_ADMIN_update_view_PDT_MOMON;
    /

    GRANT EXECUTE ON X_ADMIN_update_view_PDT_MOMON TO XR_NVPDT;

-- Procedure để lấy danh sách sinh viên
-- đã đăng ký môn học theo mã môn học
    CREATE OR REPLACE PROCEDURE X_ADMIN_Select_SINHVIEN_Table_ForNVPDT(
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
    GRANT EXECUTE ON X_ADMIN_Select_SINHVIEN_Table_ForNVPDT TO XR_NVPDT;
--Tạo procedure để NVPDT update trường TinhTrang trên bảng SINHVIEN
    CREATE OR REPLACE PROCEDURE X_ADMIN_update_TT_SV (
        MaSV_ IN VARCHAR2,
        TINHTRANG_ IN VARCHAR2,
        ROW_AFFECTED OUT NUMBER
    )
    AS
    BEGIN
        UPDATE X_ADMIN.SINHVIEN
        SET TINHTRANG = TINHTRANG_
        WHERE MASV = MaSV_;

        ROW_AFFECTED := SQL%ROWCOUNT;
    END X_ADMIN_update_TT_SV;
    /

    GRANT EXECUTE ON X_ADMIN.X_ADMIN_update_TT_SV TO XR_NVPDT;
    GRANT UPDATE(TINHTRANG) ON X_ADMIN.SINHVIEN TO XR_NVPDT;

--Tạo procedure để delete 1 dòng trên DANGKY dành cho NVPDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_delete_DANGKY_NVPDT(
        MaSV_         IN  VARCHAR2,
        MaMM_         IN  VARCHAR2,
        rows_affected OUT NUMBER
    )
    AS
    BEGIN
        DELETE FROM X_ADMIN.DANGKY
        WHERE MAMM = MaMM_ AND MASV = MaSV_;
        
        rows_affected := SQL%ROWCOUNT;
    END X_ADMIN_delete_DANGKY_NVPDT;
    /

    GRANT EXECUTE ON X_ADMIN_delete_DANGKY_NVPDT TO XR_NVPDT;


--Tạo procedure để delete 1 dòng trên DANGKY dành cho NVPDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_insert_DANGKY_NVPDT(
        MaSV_ IN VARCHAR2,
        MaMM_ IN VARCHAR2
    )
    AS
    BEGIN
        INSERT INTO X_ADMIN.DANGKY(MASV, MAMM) 
        VALUES(MASV_, MAMM_);
    END X_ADMIN_insert_DANGKY_NVPDT;
    /

    GRANT EXECUTE ON X_ADMIN_insert_DANGKY_NVPDT TO XR_NVPDT;
-- Tạo procedure để update 1 dòng DANGKY dành cho NVPDT
    CREATE OR REPLACE PROCEDURE X_ADMIN_update_DANGKY_NVPDT(
        p_MaSV IN VARCHAR2,
        p_MaMM IN VARCHAR2,
        ROW_AFFECTED OUT NUMBER
    )
    AS
    BEGIN
        UPDATE X_ADMIN.DANGKY
        SET MASV = p_MaSV,
            MAMM = p_MaMM
        WHERE MASV = p_MaSV AND MAMM = p_MaMM;

        ROW_AFFECTED := SQL%ROWCOUNT;
    END X_ADMIN_update_DANGKY_NVPDT;
    /

    GRANT EXECUTE ON X_ADMIN_update_DANGKY_NVPDT TO XR_NVPDT;
COMMIT;