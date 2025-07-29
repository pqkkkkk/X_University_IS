SELECT * FROM DBA_SA_LEVELS;
SELECT * FROM DBA_SA_COMPARTMENTS;
SELECT * FROM DBA_SA_GROUPS;
SELECT * FROM DBA_SA_POLICIES;
SELECT * from DBA_SA_LABELS;
SELECT * 
FROM DBA_SA_TABLE_POLICIES 
WHERE TABLE_NAME = 'THONGBAO' AND SCHEMA_NAME = 'X_ADMIN';

-- Gỡ bỏ chính sách khỏi bảng (không xóa)
BEGIN
  SA_POLICY_ADMIN.REMOVE_TABLE_POLICY(
    policy_name => 'NOTIFICATION_POLICY',
    schema_name => 'X_ADMIN',
    table_name  => 'THONGBAO'
  );
END;
/
-- Xóa chính sách 
EXEC SA_SYSDBA.DROP_POLICY('NOTIFICATION_POLICY');

-- CẬP NHẬT NHÃN BẢO MẬT CHO DỮ LIỆU TRONG BẢNG THONGBAO
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'TRGDV') WHERE MATB = 1;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'NV') WHERE MATB = 2;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'SV') WHERE MATB = 3;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'SV:HOA:CS1') WHERE MATB = 4;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'SV:HOA:CS2') WHERE MATB = 5;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'SV:HOA:CS1,CS2') WHERE MATB = 6;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'SV::CS1,CS2') WHERE MATB = 7;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'TRGDV:HOA:CS1') WHERE MATB = 8;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'TRGDV:HOA:CS1,CS2') WHERE MATB = 9;
update THONGBAO set LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'TRGDV:HC:CS1,CS2') WHERE MATB = 10;
UPDATE THONGBAO SET LABEL = CHAR_TO_LABEL('NOTIFICATION_POLICY', 'NV:HC:CS1') WHERE MATB = 11;
COMMIT;
---------------------------- TEST -----------------------------
-- Nhớ tạo người dùng và cấp quyền SELECT cho bảng THONGBAO
-- Test quyền truy cập của người dùng
-- Gán quyền cho NV0019 (đang là TRGDV) quyền đọc được tất cả thông báo (u1)
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0019',
    max_read_label  => 'TRGDV:TOAN,VLY,HOA,HC:CS1,CS2',
    def_label       => 'TRGDV:TOAN,VLY,HOA,HC:CS1,CS2'
  );
END;
/
CONNECT X_NV0019/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng trưởng khoa Hóa cơ sở 2 (u2)
-- CẤP CHO NV0018 nhãn tương ứng
-- u2: TRGDV:H:CS2: trưởng đơn vị phụ trách khoa hóa tại cơ sở 2
CONNECT X_NV0003/123@localhost:11521/ORCLPDB1;
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0018',
    max_read_label  => 'TRGDV:HOA:CS2',
    def_label       => 'TRGDV:HOA:CS2'
  );
END;
/
GRANT XR_TRGDV TO X_NV0018 
-- Kết nối với X_NV0018 và kiểm tra quyền truy cập
CONNECT X_NV0018/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng trưởng khoa Lý cơ sở 2 (u3)
-- CẤP CHO NV0020 nhãn tương ứng
-- u3: TRGDV:L:CS2: truong đơn vị phụ trách khoa lý tại cơ sở 2
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0020',
    max_read_label  => 'TRGDV:VLY:CS2',
    def_label       => 'TRGDV:VLY:CS2'
  );
END;
select * from NHANVIEN;

-- Test quyền của người dùng nhân viên khoa Hóa cơ sở 2 (u4)
-- CẤP CHO NV0012 nhãn tương ứng
-- u4: NV:H:CS2: nhân viên thuộc khoa hóa tại cơ sở 2

BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0012',
    max_read_label  => 'NV:HOA:CS2',
    def_label       => 'NV:HOA:CS2'
  );
END;
-- Đăng nhập vào X_NV0012 và kiểm tra quyền truy cập
CONNECT X_NV0012/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng sinh viên khoa Hóa cơ sở 2 (u5)
-- CẤP CHO SV0011 nhãn tương ứng
-- u5: SV:H:CS2: sinh viên thuộc khoa hóa tại cơ sở 2 (đã có nhãn)

BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_SV0011',
    max_read_label  => 'SV:HOA:CS2',
    def_label       => 'SV:HOA:CS2'
  );
END;
-- Đăng nhập vào X_SV0011 và kiểm tra quyền truy cập
CONNECT X_SV0011/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng trưởng đơn vị đọc thông báo hành chính (u6)
-- CẤP CHO NV0021 nhãn tương ứng
-- u6: TRGDV:HC:CS1,CS2: trưởng đơn vị đọc thông báo hành chính tại cơ sở 1 và 2
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0021',
    max_read_label  => 'TRGDV:HC:CS1,CS2',
    def_label       => 'TRGDV:HC:CS1,CS2'
  );
END;
-- Đăng nhập vào X_NV0021 và kiểm tra quyền truy cập
CONNECT X_NV0021/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng nhân viên đọc được thông báo dành cho nhân viên (u7)
-- CẤP CHO NV0014 nhãn tương ứng
-- u7: NV:T,L,H,HC:CS1,CS2: NV đọc được thông báo dành cho nhân viên
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0014',
    max_read_label  => 'NV:TOAN,VLY,HOA,HC:CS1,CS2',
    def_label       => 'NV:TOAN,VLY,HOA,HC:CS1,CS2'
  );
END;
-- Đăng nhập vào X_NV0014 và kiểm tra quyền truy cập
CONNECT X_NV0014/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Test quyền của người dùng nhân viên đọc được thông báo hành chính tại cơ sở 1 (u8)
-- CẤP CHO NV0013 nhãn tương ứng
-- u8: NV:HC:CS1: nhân viên đọc được thông báo hành chính tại cơ sở 1
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0013',
    max_read_label  => 'NV:HC:CS1',
    def_label       => 'NV:HC:CS1'
  );
END;
-- Đăng nhập vào X_NV0013 và kiểm tra quyền truy cập
CONNECT X_NV0013/123@localhost:11521/ORCLPDB1;
SELECT MATB, NOIDUNG FROM X_ADMIN.THONGBAO;

-- Chưa set label cho người dùng khi tạo user được 
GRANT EXECUTE ON LBACSYS.SA_USER_ADMIN TO XR_NVTCHC;
GRANT EXECUTE ON LBACSYS.SA_LABEL_ADMIN TO XR_NVTCHC;
GRANT EXECUTE ON CHAR_TO_LABEL TO XR_NVTCHC;
GRANT EXECUTE ON SA_POLICY_ADMIN TO XR_NVTCHC;
GRANT EXECUTE ON SA_SYSDBA TO XR_NVTCHC;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO XR_NVTCHC;
GRANT LBAC_DBA TO XR_NVTCHC;
GRANT INHERIT PRIVILEGES ON USER LBACSYS TO XR_NVTCHC;

commit;
SELECT * FROM ROLE_SYS_PRIVS WHERE ROLE = "XR_NVTCHC";
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE = 'XR_NVTCHC';

GRANT XR_NVTCHC TO X_NV0003;
CONNECT X_NV0003/123@localhost:11521/ORCLPDB1;
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS (
    policy_name     => 'NOTIFICATION_POLICY',
    user_name       => 'X_NV0047',
    max_read_label  => 'TRGDV:TOAN,VLY,HOA,HC:CS1,CS2',
    def_label       => 'TRGDV:TOAN,VLY,HOA,HC:CS1,CS2'
  );
END;
BEGIN
  SA_USER_ADMIN.SET_USER_PRIVS (
    policy_name => 'NOTIFICATION_POLICY',
    user_name   => 'X_ADMIN',
    privileges  => 'FULL'
  );
END;
/