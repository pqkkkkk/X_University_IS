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
using Application.ViewModels.User;
using System.Threading.Tasks;
using Application.ViewModels;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Application.Views.User
{
    public sealed partial class NVPDTDashboardUC : UserControl
    {
        public delegate void TabViewChangedEventHandler(string tabView);
        public event TabViewChangedEventHandler? TabViewChanged;
        public delegate void AddedNewItemEventHandler();
        public event AddedNewItemEventHandler? AddedNewItem;
        public NVPDTViewModel viewModel { get; set; }
        public NVPDTDashboardUC()
        {
            viewModel = new NVPDTViewModel();
            this.InitializeComponent();
            TabViewChanged += dataContent.SetDataSource;
            AddedNewItem += dataContent.UpdateSelectedItemOfDataListAfterAddNewItem;
        }
        private async void SaveItem(object item)
        {
            int result = viewModel.SaveItem(item);
            if (result == 1)
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Success",
                    Content = "Save successfully",
                    CloseButtonText = "OK"
                };

                await notification.ShowAsync();
            }
            else
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Failed",
                    Content = "Save failed",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();
            }
        }

        private async void OnDeleteClicked(object obj)
        {
            int deleteResult = viewModel.DeleteItem(obj);
            if (deleteResult == 0)
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Error",
                    Content = "You dont't have permission for delete to this table",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();
            }
            else
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Success",
                    Content = "Delete successfully",
                    CloseButtonText = "OK"
                };

                await notification.ShowAsync();
            }
        }

        private async void OnAddClicked()
        {
            int addResult = viewModel.AddItem();

            if (addResult == 0)
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Error",
                    Content = "You dont't have permission for add to this table",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();
            }
        }

        private void OnUpdateClicked()
        {
        }

        private void CheckTheColumnOfRowIsEditable(object sender, Event.BeginningEditEvent e)
        {
            e.canEdit = viewModel.CheckTheColumnOfRowIsEditable(e.columnName);
        }

        private void OnTabViewChanged(NavigationView sender, NavigationViewSelectionChangedEventArgs args)
        {
            var selectedItem = sender.SelectedItem as Model.OracleObject;
            if (selectedItem == null)
            {
                return;
            }
            string selectedTab = selectedItem.objectName;
            viewModel.UpdateSelectedTabView(selectedTab);
            TabViewChanged?.Invoke(selectedTab);
        }
    }
}
