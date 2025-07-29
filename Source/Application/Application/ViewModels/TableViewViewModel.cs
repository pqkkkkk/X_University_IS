using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.DataAccess.MetaData.Role;
using Application.DataAccess.MetaData.TableView;
using Application.Model;
using Microsoft.Extensions.DependencyInjection;

namespace Application.ViewModels
{
    public class TableViewViewModel : BaseViewModel, INotifyPropertyChanged
    {
        public ITableViewDao tableViewDao;
        public ObservableCollection<OracleObject> itemList { get; set; }
        public OracleObject? selectedObject { get; set; }

        public TableViewViewModel()
        {
            var serviceProvider = (Microsoft.UI.Xaml.Application.Current as App)?.serviceProvider;

            tableViewDao = serviceProvider?.GetService<ITableViewDao>();
            itemList = new ObservableCollection<OracleObject>(LoadData().Cast<OracleObject>());
            selectedObject = null;
        }
        public int CreateItem(object item)
        {
            throw new NotImplementedException();
        }

        public int DeleteItem(object item)
        {
            throw new NotImplementedException();
        }

        public int UpdateItem(object item)
        {
            throw new NotImplementedException();
        }

        public void UpdateSelectedItem(object selectedItem)
        {
            selectedObject = (OracleObject)selectedItem;
        }

        public List<object> LoadData()
        {
            List<Model.OracleObject> tableList = tableViewDao.getAllTable();
            List<Model.OracleObject> viewList = tableViewDao.getAllView();
            tableList.AddRange(viewList);
            return tableList.Cast<object>().ToList();
        }

        public List<string> GetSuggestions(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return new List<string>();

            return itemList
                .Where(d => d.objectName.Contains(query, StringComparison.OrdinalIgnoreCase))
                .Select(d => d.objectName)
                .ToList();
        }

        public void search(string query)
        {
            if (query != "")
            {
                itemList = new ObservableCollection<OracleObject>(itemList.Where(item => item.objectName.ToLower().Contains(query)).ToList());
            }
            else
            {
                itemList = new ObservableCollection<OracleObject>(LoadData().Cast<OracleObject>());
            }
        }

        int BaseViewModel.DeleteItem(object item)
        {
            throw new NotImplementedException();
        }

        public event PropertyChangedEventHandler? PropertyChanged;
    }
}
