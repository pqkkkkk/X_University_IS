﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.DataAccess.MetaData.User;
using Application.Model;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.UI.Xaml.Automation.Peers;
using Oracle.ManagedDataAccess.Client;

namespace Application.ViewModels
{
    public class UserDataViewModel : BaseViewModel, INotifyPropertyChanged
    {
        public ObservableCollection<Model.User> itemList { get; set; }
        public Model.User? selectedUser { get; set; }
        public IUserDao? userDao { get; set; }
        public List<string> roleList { get; set; } 
        public string selectedRole { get; set; }

    public UserDataViewModel()
        {
            var serviceProvider = (Microsoft.UI.Xaml.Application.Current as App)?.serviceProvider;
            userDao = serviceProvider?.GetService<IUserDao>();

            itemList = new ObservableCollection<Model.User>(userDao.LoadData());
            selectedUser = null;
            roleList = new List<string> { "NHANVIEN", "SINHVIEN" };
            selectedRole = "NHANVIEN";
        }
        private string GetActualNameOfUser(string name)
        {
            return "X_" + name;
        }
        public int CreateItem(object item)
        {
            try
            {
                var user = (Model.User)item;
            
                if (String.IsNullOrEmpty(user.username) || String.IsNullOrEmpty(user.password))
                {
                    return (int)CreateUserResult.InvalidUsernameOrPassword;
                }

                string username = GetActualNameOfUser(user.username);
                if (userDao.CreateUser(username, user.password, user.role))
                {
                    itemList = new ObservableCollection<Model.User>(userDao.LoadData());
                    return (int)CreateUserResult.Success;
                }
                else
                {
                    return (int)CreateUserResult.UserCreationFailed;
                }
            }
            catch (System.Exception e)
            {
                return (int)CreateUserResult.UnknownError;
            }
        }

        public int DeleteItem(object item)
        {
            var user = (Model.User)item;
            
            string username = GetActualNameOfUser(user.username);
            if (userDao.DeleteUser(username))
            {
                itemList.Remove(user);
                return 1;
            }
            else
            {
                return 0;
            }
        }

        public int UpdateItem(object item)
        {
            try
            {
                if (selectedUser == null)
                {
                    return (int)UpdateUserResult.NoSelectedUser;
                }

                string newPassword = ((Model.User)item).password;

                if (String.IsNullOrEmpty(newPassword))
                {
                    return (int)UpdateUserResult.InvalidPassword;
                }
                string username = GetActualNameOfUser(selectedUser.username);
                if (userDao.UpdatePassword(username, newPassword))
                {
                    itemList = new ObservableCollection<Model.User>(userDao.LoadData());
                    return (int)UpdateUserResult.Success;
                }
                else
                {
                    return (int)UpdateUserResult.UserUpdateFailed;
                }
            }
            catch (System.Exception e)
            {
                return (int)UpdateUserResult.UnknownError;
            }
        }

        public void UpdateSelectedItem(object selectedItem)
        {
            selectedUser = (Model.User)selectedItem;
        }

        List<object> BaseViewModel.LoadData()
        {
            throw new NotImplementedException();
        }
        public List<string> GetSuggestions(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return new List<string>();

            return itemList
                .Where(d => d.username.Contains(query, StringComparison.OrdinalIgnoreCase))
                .Select(d => d.username)
                .ToList();
        }
        public void search(string query)
        {
            if (query != "")
            {
                itemList = new ObservableCollection<Model.User>(itemList.Where(item => item.username.ToLower().Contains(query)).ToList());
            }
            else
            {
                itemList = new ObservableCollection<Model.User>(userDao.LoadData().Cast<Model.User>());
            }
        }


        public event PropertyChangedEventHandler? PropertyChanged;
    }
}
