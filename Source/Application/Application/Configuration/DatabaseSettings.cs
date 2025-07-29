using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Configuration
{
    public class DatabaseSettings
    {
        public string DataSourceUrl { get; set; }
        public string DataSourcePort { get; set; }
        public string DatabaseName { get; set; }
    }
}
