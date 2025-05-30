-- SELECT trên bảng MOMON
    CREATE OR REPLACE PROCEDURE X_ADMIN_Select_MOMON_Table_ForTRGDV(
        p_result OUT SYS_REFCURSOR
        )
    AS
    BEGIN
        OPEN p_result FOR
        SELECT * FROM X_ADMIN.view_TRGDV_MOMON;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_Select_MOMON_Table_ForTRGDV TO XR_TRGDV;

-- SELECT trên bảng NHANVIEN
    CREATE OR REPLACE PROCEDURE X_ADMIN_Select_NHANVIEN_Table_ForTRGDV(
        p_result OUT SYS_REFCURSOR)
        AS
        BEGIN
            OPEN p_result FOR
            SELECT * FROM X_ADMIN.view_TRGDV_NV;
        END;
        /
    GRANT EXECUTE ON X_ADMIN_Select_NHANVIEN_Table_ForTRGDV TO XR_TRGDV;

COMMIT;