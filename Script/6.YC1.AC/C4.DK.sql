--Cài VPD cho từng vai trò với thao tác SELECT:
   CREATE OR REPLACE FUNCTION DANGKY_SELECT(
      p_schema VARCHAR2,
      p_object_name VARCHAR2
   ) RETURN VARCHAR2 
   AS
      username VARCHAR2(10);
      v_mamm VARCHAR2(10);
      isSV INTEGER;
      isGV INTEGER;
      isNVPKT INTEGER;
      isNVPDT INTEGER;
      isAdmin INTEGER;
   BEGIN
      username := SUBSTR(SYS_CONTEXT('X_UNIVERSITY_CONTEXT','USER_NAME'),1);
      isSV := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_SV');
      isGV := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_GV');
      isNVPKT := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_NVPKT');
      isNVPDT := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_NVPDT');
      isAdmin := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_ADMIN');

      IF isAdmin >= 1 THEN
         RETURN '1=1';
      ELSIF isSV >= 1 THEN
         RETURN 'MASV = ''' || username || '''';
      ELSIF isNVPKT >= 1 THEN
         RETURN '1=1';
      ELSIF isNVPDT >= 1 THEN
         RETURN 'MAMM IN (
            SELECT MaMM 
            FROM X_ADMIN.MOMON
            WHERE CURRENT_DATE - TRUNC(TO_DATE(NAM || ''-'' || 
               CASE HK WHEN 1 THEN ''09'' WHEN 2 THEN ''01'' WHEN 3 THEN ''05'' END, ''YYYY-MM'')) 
               BETWEEN 0 AND 13
            )';
      ELSIF isGV >= 1 THEN
         RETURN  'MAMM IN (SELECT MAMM FROM X_ADMIN.MOMON WHERE MAGV = ''' || username || ''')';
      ELSE
         RETURN '1=0';
      END IF;
   END DANGKY_SELECT;
   /

   --Gắn hàm thực hiện chính sách DANGKY_SELECT vào bảng DANGKY:
   BEGIN
   DBMS_RLS.ADD_POLICY(
         object_schema   => 'X_ADMIN',
         object_name     => 'DANGKY',
         policy_name     => 'DANGKY_SELECT',
         function_schema => 'X_ADMIN',
         policy_function => 'DANGKY_SELECT',
         statement_types => 'SELECT',
         update_check    => TRUE
      );
   END;
   /

   BEGIN
      DBMS_RLS.DROP_POLICY(
          object_schema   => 'X_ADMIN',
          object_name     => 'DANGKY',
          policy_name     => 'DANGKY_SELECT'
      );
   END;
   COMMIT;



--Cài VPD cho từng vai trò với thao tác INSERT, UPDATE, DELETE với các trường MASV, MAMM:
   CREATE OR REPLACE FUNCTION DANGKY_INS_DEL_UPD
      (p_schema VARCHAR2, p_obj VARCHAR2)
   RETURN VARCHAR2 
   AS
      username VARCHAR2(10);
      isSV INTEGER;
      isNVPKT INTEGER;
      isNVPDT INTEGER;

  BEGIN
     username := SUBSTR(SYS_CONTEXT('X_UNIVERSITY_CONTEXT','USER_NAME'),1);
     isSV := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_SV');
     isNVPKT := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_NVPKT');
     isNVPDT := SYS_CONTEXT('X_UNIVERSITY_CONTEXT', 'IS_NVPDT');

     IF isSV >= 1 THEN
       RETURN 'MASV = ''' || username || ''' AND MAMM IN (
       SELECT MaMM 
       FROM X_ADMIN.MOMON
       WHERE CURRENT_DATE - TRUNC(TO_DATE(NAM || ''-'' || 
          CASE HK WHEN 1 THEN ''09'' WHEN 2 THEN ''01'' WHEN 3 THEN ''05'' END, ''YYYY-MM'')) 
          BETWEEN 0 AND 13
       )';

     ELSIF isNVPDT >= 1 THEN
       RETURN 'MAMM IN (
       SELECT MaMM 
       FROM X_ADMIN.MOMON
       WHERE CURRENT_DATE - TRUNC(TO_DATE(NAM || ''-'' || 
          CASE HK WHEN 1 THEN ''09'' WHEN 2 THEN ''01'' WHEN 3 THEN ''05'' END, ''YYYY-MM'')) 
          BETWEEN 0 AND 13
       )';

     ELSIF isNVPKT >= 1 THEN
        RETURN '1=1';
     ELSE 
        RETURN '1=0';
     END IF;
  END DANGKY_INS_DEL_UPD;
  /

   BEGIN
   DBMS_RLS.ADD_POLICY(
         object_schema   => 'X_ADMIN',
         object_name     => 'DANGKY',
         policy_name     => 'DANGKY_INS_DEL_UPD',
         function_schema => 'X_ADMIN',
         policy_function => 'DANGKY_INS_DEL_UPD',
         statement_types => 'INSERT, UPDATE, DELETE',
         update_check    => TRUE
      );
   END;
   /

   BEGIN
      DBMS_RLS.DROP_POLICY(
          object_schema   => 'X_ADMIN',
          object_name     => 'DANGKY',
          policy_name     => 'DANGKY_INS_DEL_UPD'
      );
   END;
   /
GRANT SELECT ON X_ADMIN.DANGKY TO XR_GV;
GRANT SELECT, UPDATE(DIEMTH, DIEMCT, DIEMCK, DIEMTK) ON X_ADMIN.DANGKY TO XR_NVPKT;
GRANT SELECT, DELETE, INSERT ON X_ADMIN.DANGKY TO XR_SV;
GRANT SELECT, DELETE, INSERT ON X_ADMIN.DANGKY TO XR_NVPDT;

COMMIT;