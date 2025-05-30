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

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Application.Views.User
{
    public sealed partial class NVCTSVDashboardUC : UserControl
    {
        public delegate void TabViewChangedEventHandler(string tabView);
        public event TabViewChangedEventHandler? TabViewChanged;
        public delegate void AddedNewItemEventHandler();
        public event AddedNewItemEventHandler? AddedNewItem;

        public NVCTSVViewModel viewModel { get; set; }
        public NVCTSVDashboardUC()
        {
            viewModel = new NVCTSVViewModel();
            this.InitializeComponent();
            TabViewChanged += dataContent.SetDataSource;
            AddedNewItem += dataContent.UpdateSelectedItemOfDataListAfterAddNewItem;
        }
        private  async void OnAddClicked()
        {
            int addResult = viewModel.AddItem();

            if(addResult == 0)
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Failed",
                    Content = "You do not have permission to add new item",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();
                return;
            }

            AddedNewItem?.Invoke();
        }

        private async void SaveItem(object item)
        {
            int result =  viewModel.SaveItem(item);

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
            else {
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

        private async void OnDeleteClicked(object item)
        {
            if (item == null)
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Failed",
                    Content = "Please select an item to delete",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();

                return;
            }

            int deleteResult = viewModel.DeleteItem(item);
            if (deleteResult == 1)
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
            else
            {
                var notification = new ContentDialog
                {
                    XamlRoot = this.XamlRoot,
                    Title = "Failed",
                    Content = "Delete failed",
                    CloseButtonText = "OK"
                };
                await notification.ShowAsync();
            }
        }

        private void CheckCanEditSelectedColumn(object sender, Event.BeginningEditEvent e)
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
