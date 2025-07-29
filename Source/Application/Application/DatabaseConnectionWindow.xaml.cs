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

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Application
{
    public sealed partial class DatabaseConnectionWindow : Window
    {
        public delegate void ConnectionEstablishedHandler(string dataSourceUrl, string dataSourcePort, string databaseName);
        public event ConnectionEstablishedHandler ConnectionEstablished;
        public DatabaseConnectionWindow()
        {
            this.InitializeComponent();
        }

        private async void ContinueButton_Click(object sender, RoutedEventArgs e)
        {
            string dataSourceUrl = DataSourceUrlTextBox.Text;
            string dataSourcePort = DataSourcePortTextBox.Text;
            string databaseName = DatabaseNameTextBox.Text;

            if (string.IsNullOrWhiteSpace(dataSourceUrl) || string.IsNullOrWhiteSpace(dataSourcePort) || string.IsNullOrWhiteSpace(databaseName))
            {
                ContentDialog errorDialog = new ContentDialog
                {
                    Title = "Error",
                    Content = "Please fill in all fields.",
                    CloseButtonText = "OK"
                };
                await errorDialog.ShowAsync();
            }
            else
            {
                ConnectionEstablished?.Invoke(dataSourceUrl, dataSourcePort, databaseName);
                this.Close();
            }
        }
    }
}
