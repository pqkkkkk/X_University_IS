using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.ApplicationModel;
using Windows.ApplicationModel.Activation;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;
using Microsoft.UI.Xaml.Shapes;
using Microsoft.Extensions.DependencyInjection;
using Oracle.ManagedDataAccess.Client;
using System.Threading.Tasks;
using Application.DataAccess.MetaData;
using Application.ViewModels;
using Application.DataAccess.MetaData.Privilege;
using Application.DataAccess.MetaData.Role;
using Application.DataAccess.MetaData.User;
using Application.DataAccess.MetaData.TableView;
using Microsoft.Windows.ApplicationModel.WindowsAppRuntime;
using Application.DataAccess.ThongBao;
using Microsoft.Extensions.Configuration;
using Application.Configuration;

namespace Application
{
    public partial class App : Microsoft.UI.Xaml.Application
    {
        public IServiceProvider? serviceProvider { get; private set; }
        public IConfiguration configuration { get; private set; }
        public DatabaseSettings databaseSettings { get; set; }
        public List<Model.OracleObject> tableList { get; set; } = new List<Model.OracleObject>();

        public App()
        {
            //LoadEnvVariables();
            databaseSettings = new DatabaseSettings();
            this.InitializeComponent();
        }

        protected override void OnLaunched(Microsoft.UI.Xaml.LaunchActivatedEventArgs args)
        {
            m_databaseConnectionWindow = new DatabaseConnectionWindow();
            m_databaseConnectionWindow.ConnectionEstablished += HandleConnectionEstablished;
            m_databaseConnectionWindow.Activate();
            //m_window = new MainWindow();
            //m_window.signInClicked += OnSignInClicked;
            //m_window.Activate();
        }
        public void LoadEnvVariables()
        {
            string configFolder = System.IO.Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "MyApp");
            string externalConfigPath = System.IO.Path.Combine(configFolder, "appsettings.json");
            if (!File.Exists(externalConfigPath))
            {
                Directory.CreateDirectory(configFolder);
                string defaultConfigPath = System.IO.Path.Combine(AppContext.BaseDirectory, "appsettings.json");
                File.Copy(defaultConfigPath, externalConfigPath);
            }

            var builder = new ConfigurationBuilder();
            if (File.Exists(externalConfigPath))
            {
                builder.AddJsonFile(externalConfigPath, optional: false, reloadOnChange: true);
            }
            else
            {

                builder
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
            }

            configuration = builder.Build();
            databaseSettings = new DatabaseSettings();
            configuration.GetSection("DatabaseSettings").Bind(databaseSettings);

        }
        private void HandleConnectionEstablished(string dataSourceUrl, string dataSourcePort, string databaseName)
        {
            databaseSettings.DataSourceUrl = dataSourceUrl;
            databaseSettings.DataSourcePort = dataSourcePort;
            databaseSettings.DatabaseName = databaseName;

           
            m_window = new MainWindow();
            m_window.signInClicked += OnSignInClicked;
            m_window.Activate();

            if (m_databaseConnectionWindow != null)
            {
                m_databaseConnectionWindow.Close();
            }
        }
        private async  void OnSignInClicked(string username, string password, string role)
        {
            try
            {
                string actual_username = "X_" + username.ToUpper();
                string actual_role = "XR_" + role.ToUpper();
                if (role != "ADMIN")
                {
                    var adminConnectString = $"User Id=X_ADMIN;Password=123;Data Source={databaseSettings.DataSourceUrl}:{databaseSettings.DataSourcePort}/{databaseSettings.DatabaseName}";
                    var adminConnection = new OracleConnection(adminConnectString);

                    IPrivilegeDao privilegeDao = new PrivilegeXAdminDao(adminConnection);
                    var roleOfUserList = privilegeDao.GetAllRolesOfUser(actual_username);

                    bool isRoleValid = roleOfUserList.Any(x => x.name.Equals(role));
                    if (!isRoleValid)
                    {
                        throw new System.Exception("Invalid role");
                    }

                    ITableViewDao tableViewDao = new TableViewXAdminDao(adminConnection);
                    tableList = tableViewDao.getAllTable();
                    tableList.RemoveAll(x => x.objectName == "USER_ROLES");

                }

                string connectionString = "";
                
                if(username.Equals("sys"))
                    connectionString = $"User Id={actual_username};Password={password};Data Source={databaseSettings.DataSourceUrl}:{databaseSettings.DataSourcePort}/{databaseSettings.DatabaseName};DBA Privilege=SYSDBA";
                else
                    connectionString = $"User Id={actual_username};Password={password};Data Source={databaseSettings.DataSourceUrl}:{databaseSettings.DataSourcePort}/{databaseSettings.DatabaseName}";

                var sqlConnection = new OracleConnection(connectionString);
                await sqlConnection.OpenAsync();

                var services = new ServiceCollection();
                // Đăng ký OracleConnection
                services.AddSingleton(sqlConnection);
                // Đăng ký PrivilegeOracleDao
                services.AddSingleton<IPrivilegeDao, PrivilegeXAdminDao>();
                services.AddSingleton<IRoleDao, RoleXAdminDao>();
                services.AddSingleton<IUserDao, UserXAdminDao>();
                services.AddSingleton<ITableViewDao, TableViewXAdminDao>();
                services.AddSingleton<IThongBaoDao, ThongBaoXAdminDao>();
                serviceProvider = services.BuildServiceProvider();

                m_window.SignInSuccessHandler(role);
            }
            catch (System.Exception ex)
            {
                m_window.SignInFailedHandler();
                Console.WriteLine(ex.Message);

                if (ex.InnerException != null)
                {
                    Console.WriteLine(ex.InnerException.Message);
                }
            }
            finally
            {
                if (serviceProvider != null)
                {
                    var sqlConnection = serviceProvider.GetService<OracleConnection>();
                    if (sqlConnection != null && sqlConnection.State == System.Data.ConnectionState.Open)
                    {
                        sqlConnection.Close();
                    }

                }
            }
        }

        private MainWindow? m_window;
        private DatabaseConnectionWindow? m_databaseConnectionWindow;
    }
}
