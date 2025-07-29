using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.ConstrainedExecution;
using System.Text;
using System.Threading.Tasks;
using Application.Model;
using Oracle.ManagedDataAccess.Client;

namespace Application.DataAccess.MetaData.TableView
{
    class TableViewXAdminDao : ITableViewDao
    {
        private OracleConnection sqlConnection;

        public TableViewXAdminDao(OracleConnection sqlConnection)
        {
            this.sqlConnection = sqlConnection;
        }
        public List<OracleObject> getAllTable()
        {
            List<OracleObject> oracleObjects = new List<OracleObject>();

            if (sqlConnection.State != System.Data.ConnectionState.Open)
            {
                sqlConnection.Open();
            }

            using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_GetAllInstanceOfSpecificObject", sqlConnection))
            {
                string object_type = "TABLE";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("type", OracleDbType.Varchar2).Value = object_type;
                cmd.Parameters.Add("result_", OracleDbType.RefCursor).Direction = ParameterDirection.Output;

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var oracleObject = new OracleObject
                        {
                            objectName = reader["object_name"].ToString(),
                            objectType = reader["object_type"].ToString(),
                            objectId = Convert.ToInt32(reader["object_id"]),
                            owner = reader["owner"].ToString()

                        };
                        oracleObjects.Add(oracleObject);
                    }
                }
            }
            return oracleObjects;
        }

        public List<OracleObject> getAllView()
        {
            List<OracleObject> oracleObjects = new List<OracleObject>();

            if (sqlConnection.State != System.Data.ConnectionState.Open)
            {
                sqlConnection.Open();
            }

            using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_GetAllInstanceOfSpecificObject", sqlConnection))
            {
                string object_type = "VIEW";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("type", OracleDbType.Varchar2).Value = object_type;
                cmd.Parameters.Add("result_", OracleDbType.RefCursor).Direction = ParameterDirection.Output;

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var oracleObject = new OracleObject
                        {
                            objectName = reader["object_name"].ToString(),
                            objectType = reader["object_type"].ToString(),
                            objectId = Convert.ToInt32(reader["object_id"]),
                            owner = reader["owner"].ToString()

                        };
                        oracleObjects.Add(oracleObject);
                    }
                }
            }
            return oracleObjects;
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
