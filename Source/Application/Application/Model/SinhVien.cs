﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Model
{
    public class SinhVien : IPersistable, INotifyPropertyChanged
    {
        public string? maSV { get; set; }
        public string? hoTen { get; set; }
        public string? phai { get; set; }
        public DateTime? ngSinh { get; set; }
        public string? dChi { get; set; }
        public string? dt { get; set; }
        public string? khoa { get; set; }
        public string? TINHTRANG { get; set; }
        public bool? isInDB { get; set; }
        public string? coSo { get; set; }

        public SinhVien()
        {
            maSV = "Mã SV";
            hoTen = "Họ tên";
            phai = "Phái";
            ngSinh = DateTime.Now;
            dChi = "Địa chỉ";
            dt = "Điện thoại";
            khoa = "Khoa";
            TINHTRANG = "Tình trạng";
            coSo = "Cơ sở";
        }
        public event PropertyChangedEventHandler? PropertyChanged;
    }
}
