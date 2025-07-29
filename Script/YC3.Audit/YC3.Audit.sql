-- 1. Bật tắt audit
  ALTER SESSION SET CONTAINER =CDB$ROOT;
  ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE;
  ALTER SESSION SET CONTAINER =CDB$ROOT;
  ALTER SYSTEM SET audit_trail=NONE SCOPE=SPFILE;
  show parameter audit_trail;
-- 2. Dùng Standard Audit
  AUDIT SELECT ON X_ADMIN.DANGKY BY ACCESS;
  COMMIT;
  AUDIT SELECT ON X_ADMIN.NHANVIEN BY ACCESS WHENEVER NOT SUCCESSFUL;
  AUDIT SELECT ON X_ADMIN.MOMON BY ACCESS WHENEVER SUCCESSFUL;
  COMMIT;
-- 3. Dùng Fine-Grained Audit
  -- a. Hành vi cập nhật quan hệ ĐANGKY tại các trường liên quan đến điểm số nhưng
  --người đó không thuộc vai trò “NV PKT”.
    BEGIN
      DBMS_FGA.add_policy(
        object_schema   => 'X_ADMIN',
        object_name     => 'DANGKY',
        policy_name     => 'AUDIT_UPDATE_DIEM',
        audit_condition => 'SYS_CONTEXT(''X_UNIVERSITY_CONTEXT'', ''IS_NVPKT'') < 1',
        audit_column    => 'DIEMTH, DIEMCT, DIEMCK, DIEMTK',
        statement_types => 'UPDATE',
        enable          => TRUE
      );
    END;
    /
    COMMIT;
  -- b. Hành vi của người dùng (không thuộc vai trò “NV TCHC”) có thể đọc trên
  --trường LUONG, PHUCAP của người khác hoặc cập nhật ở quan hệ NHANVIEN.
    -- Tạo function để kiểm tra có vi phạm chính sách select bảng NHANVIEN hay không
      CREATE OR REPLACE FUNCTION VIOLATE_SELECT_NHANVIEN_POLICY(
        p_current_username IN VARCHAR2,
        p_actual_username IN VARCHAR2
      )
        RETURN NUMBER DETERMINISTIC
        AS
          p_is_nvtchc NUMBER;
        BEGIN
          p_is_nvtchc := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_NVTCHC');
          IF p_is_nvtchc < 1 AND p_current_username != p_actual_username THEN
            RETURN 1; -- Vi phạm chính sách
          ELSE
            RETURN 0; -- Không vi phạm chính sách
          END IF;
        END VIOLATE_SELECT_NHANVIEN_POLICY;
        /
    BEGIN
      DBMS_FGA.add_policy(
        object_schema   => 'X_ADMIN',
        object_name     => 'NHANVIEN',
        policy_name     => 'AUDIT_SELECT_NHANVIEN',
        audit_condition => 'X_ADMIN.VIOLATE_SELECT_NHANVIEN_POLICY(SYS_CONTEXT(''X_UNIVERSITY_CONTEXT'', ''USER_NAME''), MANV) = 1',
        audit_column    => 'LUONG, PHUCAP',
        statement_types => 'SELECT',
        enable          => TRUE
      );
    END;
    /
    COMMIT;
  -- c. Hành vi thêm, xóa, sửa trên quan hệ DANGKY của sinh viên nhưng trên dòng
  --dữ liệu của sinh viên khác hoặc thực hiện hiệu chỉnh đăng ký học phần ngoài
  --thời gian cho phép hiệu chỉnh đăng ký học phần.

    --Tạo function để kiểm tra có nằm trong thời gian hiệu chỉnh học phần hay không
      CREATE OR REPLACE FUNCTION isInModifyTime(
        p_maMM IN VARCHAR2
        )
        RETURN NUMBER
        DETERMINISTIC
      AS
        v_count NUMBER;
      BEGIN
        SELECT COUNT(*) INTO v_count
        FROM X_ADMIN.MOMON
        WHERE MaMM = p_maMM
        AND CURRENT_DATE 
              - TRUNC(
                  TO_DATE(
                    NAM || '-' ||
                    CASE HK 
                      WHEN 1 THEN '09'
                      WHEN 2 THEN '01'
                      WHEN 3 THEN '05'
                    END,
                  'YYYY-MM')
                )
            BETWEEN 0 AND 13;
        
        IF v_count > 0 THEN
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;
      END isInModifyTime;
      /

    BEGIN
      DBMS_FGA.add_policy(
        object_schema   => 'X_ADMIN',
        object_name     => 'DANGKY',
        policy_name     => 'AUDIT_NOT_IN_MODIFY_TIME_DANGKY',
        audit_condition => 'X_ADMIN.isInModifyTime(MAMM) = 0',
        statement_types => 'INSERT, UPDATE, DELETE',
        enable          => TRUE
      );
    END;
    /
    COMMIT;

    --thêm xóa sửa trên dòng dữ liệu của sinh viên khác
      CREATE OR REPLACE FUNCTION get_audit_condition(
        v_is_student IN NUMBER,
        v_username IN VARCHAR2,
        v_masv IN VARCHAR2) RETURN NUMBER
      AS
      BEGIN
        IF v_is_student >=1 AND v_masv != v_username THEN
          RETURN 1;
        ELSE 
        RETURN 0;
        END IF;
      END;
      /

    BEGIN
      DBMS_FGA.add_policy(
        object_schema   => 'X_ADMIN',
        object_name     => 'DANGKY',
        policy_name     => 'AUDIT_INSERT_UPDATE_DELETE_DANGKY',
        audit_condition => 'X_ADMIN.get_audit_condition(SYS_CONTEXT(''X_UNIVERSITY_CONTEXT'', ''IS_SV''), SYS_CONTEXT(''X_UNIVERSITY_CONTEXT'', ''USER_NAME''), MASV) = 1',
        statement_types => 'INSERT, UPDATE, DELETE'
      );
    END;
    /
    COMMIT;



