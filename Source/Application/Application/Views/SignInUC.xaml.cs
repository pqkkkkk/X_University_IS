using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;
using System.Collections.ObjectModel;
using Oracle.ManagedDataAccess.Client;
using Application.DataAccess.MetaData.Role;
using Application.Configuration;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Application.Views
{
    public sealed partial class SignInUC : UserControl
    {
        public delegate void SignInClickedHandler(string username, string password, string role);
        public event SignInClickedHandler signInClicked;
        public ObservableCollection<Model.Role> roleList { get; set; }
        public SignInUC()
        {
            DatabaseSettings databaseSettings = (Microsoft.UI.Xaml.Application.Current as App)?.databaseSettings;
            string adminConnectString = $"User Id=X_ADMIN;Password=123;Data Source={databaseSettings.DataSourceUrl}:{databaseSettings.DataSourcePort}/{databaseSettings.DatabaseName}";
            
            var sqlConnection = new OracleConnection(adminConnectString);
            IRoleDao roleDao = new RoleXAdminDao(sqlConnection);

            roleList = new ObservableCollection<Model.Role>(roleDao.GetAllRoles());
            roleList.Remove(roleList.FirstOrDefault(x => x.name.Equals("CONNECT")));
            roleList.Remove(roleList.FirstOrDefault(x => x.name.Equals("RESOURCE")));
            roleList.Add(new Model.Role { name = "ADMIN" });

            this.InitializeComponent();
        }

        private void SignInClickedHandlerInSignInUC(object sender, RoutedEventArgs e)
        {
            string username = usernameBox.Text;
            string password = passwordBox.Password;
            string role = roleCombobox.SelectedItem != null ? ((Model.Role)roleCombobox.SelectedItem).name : string.Empty;

            signInClicked?.Invoke(username, password, role);
        }
    }
}
