﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.DataAccess.DangKy;
using Application.DataAccess.DonVi;
using Application.DataAccess.HocPhan;
using Application.DataAccess.MoMon;
using Application.DataAccess.NhanVien;
using Application.DataAccess.SinhVien;
using Application.DataAccess;
using Oracle.ManagedDataAccess.Client;
using System.Diagnostics;
using System.Collections;
using Application.Model;
using Windows.Media.Devices;
using Application.DataAccess.MetaData.TableView;
using Application.DataAccess.MetaData.Privilege;
using Application.DataAccess.ThongBao;

namespace Application.ViewModels.User
{
    public class NVCTSVViewModel : INotifyPropertyChanged
    {
        private readonly Helper.Helper helper;
        public string selectedTabView { get; set; }
        public ObservableCollection<Model.OracleObject> tabViewList { get; set; }

        public Dictionary<string, IBaseDao> daoList { get; set; }
        private readonly ITableViewDao tableViewDao;
        private readonly IPrivilegeDao privilegeDao;

        public Dictionary<string, Func<object>> newItemFactoryMap { get; set; }
        private readonly Dictionary<string, IList> listMap;
        private readonly Dictionary<string, IList> editableColumnMap;
        private readonly Dictionary<string, IList> permissionMap;
        public ObservableCollection<Model.DangKy> dangKyList { get; set; }
        public ObservableCollection<Model.DonVi> donViList { get; set; }
        public ObservableCollection<Model.HocPhan> hocPhanList { get; set; }
        public ObservableCollection<Model.MoMon> moMonList { get; set; }
        public ObservableCollection<Model.NhanVien> nhanVienList { get; set; }
        public ObservableCollection<Model.SinhVien> sinhVienList { get; set; }
        public ObservableCollection<Model.ThongBao> thongbaoList { get; set; }


        public NVCTSVViewModel()
        {
            helper = new Helper.Helper();

            var tableList = (Microsoft.UI.Xaml.Application.Current as App)?.tableList;
            tabViewList = new ObservableCollection<Model.OracleObject>(tableList);
            selectedTabView = "DANGKY";

            var serviceProvider = (Microsoft.UI.Xaml.Application.Current as App)?.serviceProvider;
            var sqlConnection = serviceProvider?.GetService(typeof(OracleConnection)) as OracleConnection;

            tableViewDao = new TableViewUserDao(sqlConnection);
            privilegeDao = new PrivilegeUserDao(sqlConnection);
            daoList = new Dictionary<string, IBaseDao>();
            daoList.Add("DANGKY", new DangKyNVCTSVDao());
            daoList.Add("DONVI", new DonViNVCTSVDao());
            daoList.Add("HOCPHAN", new HocPhanNVCTSVDao());
            daoList.Add("MOMON", new MoMonNVCTSVDao());
            daoList.Add("NHANVIEN", new NhanVienNVCBDao(sqlConnection));
            daoList.Add("SINHVIEN", new SinhVienNVCTSVDao(sqlConnection));
            daoList.Add("THONGBAO", new ThongBaoXAdminDao(sqlConnection));

            dangKyList = new ObservableCollection<Model.DangKy>();
            donViList = new ObservableCollection<Model.DonVi>();
            hocPhanList = new ObservableCollection<Model.HocPhan>();
            moMonList = new ObservableCollection<Model.MoMon>();
            nhanVienList = new ObservableCollection<Model.NhanVien>(daoList["NHANVIEN"].Load(null).Cast<Model.NhanVien>().ToList());
            sinhVienList = new ObservableCollection<Model.SinhVien>(daoList["SINHVIEN"].Load(null).Cast<Model.SinhVien>().ToList());
            thongbaoList = new ObservableCollection<Model.ThongBao>(daoList["THONGBAO"].Load(null).Cast<Model.ThongBao>());

            newItemFactoryMap = new Dictionary<string, Func<object>>
            {
                ["DANGKY"] = () => new Model.DangKy { isInDB = false },
                ["DONVI"] = () => new Model.DonVi() {},
                ["HOCPHAN"] = () => new Model.HocPhan() {},
                ["MOMON"] = () => new Model.MoMon() { isInDB = false},
                ["NHANVIEN"] = () => new Model.NhanVien() { isInDB = false},
                ["SINHVIEN"] = () => new Model.SinhVien { isInDB = false },
            };

            listMap = new Dictionary<string, IList>
            {
                {  "DANGKY", dangKyList },
                { "DONVI", donViList },
                { "HOCPHAN", hocPhanList },
                { "MOMON", moMonList },
                { "NHANVIEN", nhanVienList },
                {"SINHVIEN", sinhVienList},
                {"THONGBAO", thongbaoList}
            };
            editableColumnMap = LoadEditableColumnsOfUser();
            permissionMap = LoadPrivilegesOfUser();
        }
        public Dictionary<string, IList> LoadPrivilegesOfUser()
        {
            Dictionary<string, IList> result = new Dictionary<string, IList>();

            var tableList = (Microsoft.UI.Xaml.Application.Current as App)?.tableList;

            if (tableList == null)
                return result;

            foreach (var table in tableList)
            {
                result.Add(table.objectName.ToUpper(), new List<string> { });
            }

            List<Model.Privilege> privileges = privilegeDao.GetPrivilegesOfUserOnSpecificObjectType("XR_NVTCHC", "TABLE");

            foreach (var privilege in privileges)
            {
                string tableName = privilege.tableName.ToUpper();
                if (result.TryGetValue(tableName, out var permissionList))
                {
                    if (permissionList.Contains(privilege.privilege) == false)
                        permissionList.Add(privilege.privilege);
                }
            }
            foreach (var privilege in privileges)
            {
                string viewName = privilege.tableName.ToUpper();
                string? textOfView = tableViewDao.GetTextOfView(viewName);
                if (textOfView == null)
                    continue;

                string tableName = helper.GetTableNameFromTextOfView(textOfView).ToUpper();
                if (tableName.Contains("X_ADMIN") == true)
                {
                    tableName = tableName.Replace("X_ADMIN.", "");
                }

                if (result.TryGetValue(tableName, out var permissionList))
                {
                    if (permissionList.Contains(privilege.privilege) == false)
                        permissionList.Add(privilege.privilege);
                }

            }
            return result;
        }
        public Dictionary<string, IList> LoadEditableColumnsOfUser()
        {
            Dictionary<string, IList> result = new Dictionary<string, IList>();

            var tableList = (Microsoft.UI.Xaml.Application.Current as App)?.tableList;

            if (tableList == null)
                return result;

            foreach (var table in tableList)
            {
                result.Add(table.objectName.ToUpper(), new List<string> { });
            }

            List<Model.Privilege> privileges = privilegeDao.GetPrivilegesOfUserOnSpecificObjectType("XR_NVTCHC", "TABLE");

            foreach (var privilege in privileges)
            {
                string tableName = privilege.tableName.ToUpper();

                if (result.TryGetValue(tableName, out var columnList))
                {
                    if (privilege.privilege == "UPDATE")
                    {
                        if (privilege.columnName != "")
                            columnList.Add(privilege.columnName);
                        else
                        {
                            List<string> columnListOfTable = tableViewDao.GetColumnListOfTableOrView(tableName);
                            foreach (var column in columnListOfTable)
                            {
                                if (columnList.Contains(column) == false)
                                    columnList.Add(column);
                            }
                        }
                    }
                }
            }
            foreach (var privilege in privileges)
            {
                string viewName = privilege.tableName.ToUpper();
                string? textOfView = tableViewDao.GetTextOfView(viewName);
                if (textOfView == null)
                    continue;

                string tableName = helper.GetTableNameFromTextOfView(textOfView).ToUpper();
                if (tableName.Contains("X_ADMIN") == true)
                {
                    tableName = tableName.Replace("X_ADMIN.", "");
                }

                if (result.TryGetValue(tableName, out var columnList))
                {
                    if (privilege.privilege == "UPDATE")
                    {
                        if (privilege.columnName != "")
                            columnList.Add(privilege.columnName);
                        else
                        {
                            List<string> columnListOfTable = tableViewDao.GetColumnListOfTableOrView(viewName);
                            foreach (var column in columnListOfTable)
                            {
                                if (columnList.Contains(column) == false)
                                    columnList.Add(column);
                            }
                        }
                    }
                }

            }
            return result;
        }
        public int DeleteItem(object item)
        {
            try
            {
                var dao = daoList[selectedTabView.ToUpper()];

                if (item is IPersistable e)
                {
                    if (e.isInDB == true)
                    {
                        dao.Delete(item);
                    }

                    var list = listMap[selectedTabView.ToUpper()];
                    list.Remove(item);
                }
                else
                {
                    var list = listMap[selectedTabView.ToUpper()];
                    list.Remove(item);
                }
                return 1;
            }
            catch (System.Exception ex)
            {
                Debug.WriteLine(ex.Message);
                return 0;
            }
        }
        public int SaveItem(object item)
        {
            try
            {
                var dao = daoList[selectedTabView.ToUpper()];

                if(item is IPersistable e)
                {
                    if (e.isInDB == true)
                    {
                        dao.Update(item);
                    }
                    else
                    {
                        bool result = dao.Add(item);
                        if (!result)
                        {
                            if(listMap.TryGetValue(selectedTabView.ToUpper(), out var list))
                            {
                                list.Remove(item);
                            }
                            throw new System.Exception("Add failed");
                        }
                        e.isInDB = true;
                    }
                }

                return 1;
            }
            catch (System.Exception ex)
            {
                Debug.WriteLine(ex.Message);
                return 0;
            }
            
        }
        public int AddItem()
        {
            if (permissionMap.TryGetValue(selectedTabView.ToUpper(), out var permissionList))
            {
                if (permissionList.Contains("insert".ToUpper()) == false)
                {
                    return 0;
                }
            }

            if (listMap.TryGetValue(selectedTabView.ToUpper(), out var list)
                && newItemFactoryMap.TryGetValue(selectedTabView.ToUpper(), out var factory))
            {
                var newItem = factory();
                list.Add(newItem);
                return 1;
            }

            return 0;
        }
        public bool CheckTheColumnOfRowIsEditable(string columnName)
        {
            if(editableColumnMap.TryGetValue(selectedTabView.ToUpper(), out var list))
            {
                return list.Contains(columnName.ToUpper());
            }

            return false;
        }
        public void UpdateSelectedTabView(string selectedTabView)
        {
            this.selectedTabView = selectedTabView.ToUpper();
        }
        public event PropertyChangedEventHandler? PropertyChanged;
    }
}
