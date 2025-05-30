-- SELECT TRÊN BẢNG ĐĂNG KÝ
    CREATE OR REPLACE PROCEDURE X_ADMIN_SELECT_DANGKY_TABLE_FOR_NVPKT(
        p_result OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN p_result FOR
        SELECT * FROM X_ADMIN.DANGKY;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_SELECT_DANGKY_TABLE_FOR_NVPKT TO XR_NVPKT;

-- -- UPDATE TRÊN BẢNG ĐĂNG KÝ
    CREATE OR REPLACE PROCEDURE X_ADMIN_UPDATE_DANGKY_TABLE_FOR_NVPKT(
        p_MAMM IN VARCHAR2, 
        p_MASV IN VARCHAR2,
        p_DIEMTH IN NUMBER,
        p_DIEMCT IN NUMBER,
        p_DIEMCK IN NUMBER,
        p_DIEMTK IN NUMBER
        )
    AS
    BEGIN
        UPDATE X_ADMIN.DANGKY
        SET DIEMTH = P_DIEMTH,
            DIEMCT = P_DIEMCT,
            DIEMCK = p_DIEMCK,
            DIEMTK = p_DIEMTK
        WHERE MAMM = p_MAMM AND MASV = p_MASV;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END;
    /
    GRANT EXECUTE ON X_ADMIN_UPDATE_DANGKY_TABLE_FOR_NVPKT TO XR_NVPKT;

COMMIT;