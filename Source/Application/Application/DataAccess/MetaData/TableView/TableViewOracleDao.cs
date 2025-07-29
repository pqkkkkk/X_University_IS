using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.Model;
using Oracle.ManagedDataAccess.Client;

namespace Application.DataAccess.MetaData.TableView
{
    class TableViewOracleDao : ITableViewDao
    {
        private OracleConnection sqlConnection;

        public TableViewOracleDao(OracleConnection oracleConnection)
        {
            sqlConnection = oracleConnection;
        }
        public List<OracleObject> getAllTable()
        {
            if (sqlConnection.State != ConnectionState.Open)
            {
                sqlConnection.Open();
            }
            List<OracleObject> oracleObjects = new List<OracleObject>();
            using (var cmd = new OracleCommand("getAllTablesAndViews", sqlConnection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("p_result", OracleDbType.RefCursor).Direction = ParameterDirection.Output;

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var obj = new OracleObject
                        {
                            objectId = Convert.ToInt32(reader["objectId"]),
                            owner = reader["owner"].ToString(),
                            objectName = reader["objectName"].ToString(),
                            objectType = reader["objectType"].ToString()
                        };

                        oracleObjects.Add(obj);
                    }
                }
            }
            return oracleObjects;  
        }

        public List<OracleObject> getAllView()
        {
            throw new NotImplementedException();
        }

        public List<string> GetColumnListOfTableOrView(string tableName)
        {
            throw new NotImplementedException();
        }

        public string? GetTextOfView(string viewName)
        {
            throw new NotImplementedException();
        }
    }
}
