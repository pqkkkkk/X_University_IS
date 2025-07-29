using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.Model;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;

namespace Application.DataAccess.MetaData.TableView
{
    class TableViewUserDao : ITableViewDao
    {
        private OracleConnection sqlConnection;
        
        public TableViewUserDao(OracleConnection sqlConnection)
        {
            this.sqlConnection = sqlConnection;
        }
        public List<OracleObject> getAllTable()
        {
            throw new NotImplementedException();
        }

        public List<OracleObject> getAllView()
        {
            throw new NotImplementedException();
        }

        public List<string> GetColumnListOfTableOrView(string tableName)
        {
            var result = new List<string>();
            try
            {
                if (sqlConnection.State != ConnectionState.Open)
                    sqlConnection.Open();

                const string owner = "X_ADMIN";
                const string sql = @"SELECT COLUMN_NAME 
                                     FROM ALL_TAB_COLUMNS 
                                     WHERE OWNER = :owner AND TABLE_NAME = :tableName";

                using var cmd = new OracleCommand(sql, sqlConnection);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.Add("owner", OracleDbType.Varchar2).Value = owner;
                cmd.Parameters.Add("tableName", OracleDbType.Varchar2).Value = tableName.ToUpper();

                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    var columnName = reader["COLUMN_NAME"] as string;
                    if (!string.IsNullOrEmpty(columnName))
                        result.Add(columnName);
                }
            }
            catch (System.Exception e)
            {
                throw new System.Exception(e.Message, e);
            }
            return result;
        }

        public string? GetTextOfView(string viewName)
        {
            string? result = null;

            if (sqlConnection.State != ConnectionState.Open)
            {
                sqlConnection.Open();
            }

            using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_GetTextOfView", sqlConnection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("p_view_name", OracleDbType.Varchar2).Value = viewName.ToUpper();
                OracleParameter clobParam = new OracleParameter("v_result", OracleDbType.Clob)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(clobParam);

                cmd.ExecuteNonQuery();

                if (clobParam.Value != DBNull.Value)
                {
                    OracleClob clob = (OracleClob)clobParam.Value;
                    if(!clob.IsNull)
                        result = clob.Value;
                    clob.Dispose();
                }
            }
            return result;
        }
    }
}
