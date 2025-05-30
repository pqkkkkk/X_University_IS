﻿using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DataAccess.MoMon
{
    class MoMonNVPDTDao : IMoMonDao
    {
        private OracleConnection sqlConnection;
        public MoMonNVPDTDao(OracleConnection sqlConnection)
        {
            this.sqlConnection = sqlConnection;
        }

        public bool Add(object obj)
        {
            try
            {
                if (sqlConnection.State != ConnectionState.Open)
                {
                    sqlConnection.Open();
                }
                Model.MoMon mm = (Model.MoMon)obj;
                using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_insert_view_PDT_MOMON", sqlConnection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new OracleParameter("MaMM", mm.MAMM));
                    cmd.Parameters.Add(new OracleParameter("MaHP", mm.MAHP));
                    cmd.Parameters.Add(new OracleParameter("MaGV", mm.MAGV));
                    cmd.Parameters.Add(new OracleParameter("HK", mm.HK));
                    cmd.Parameters.Add(new OracleParameter("NAM", mm.NAM));
                    cmd.ExecuteNonQuery();
                    sqlConnection.Close();
                    return true;
                }
            }
            catch (System.Exception e)
            {
                sqlConnection.Close();
                return false;
            }
        }

        public bool Delete(object obj)
        {
            try
            {
                if (sqlConnection.State != ConnectionState.Open)
                {
                    sqlConnection.Open();
                }
                Model.MoMon mm = (Model.MoMon)obj;
                using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_delete_view_PDT_MOMON", sqlConnection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new OracleParameter("Ma", mm.MAMM));
                    cmd.ExecuteNonQuery();
                    sqlConnection.Close();
                    return true;
                }
            }
            catch (System.Exception e)
            {
                sqlConnection.Close();
                return false;
            }
        }

        public List<object> Load(object obj)
        {
            if (sqlConnection.State != ConnectionState.Open)
            {
                sqlConnection.Open();
            }
            List<Model.MoMon> result = new List<Model.MoMon>();
            using (var cmd = new OracleCommand("SELECT * FROM X_ADMIN.view_PDT_MOMON", sqlConnection))
            {
                cmd.CommandType = CommandType.Text;

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var mm = new Model.MoMon
                        {
                            MAMM = reader["maMM"].ToString(),
                            MAHP = reader["maHP"].ToString(),
                            MAGV = reader["maGV"].ToString(),
                            HK = reader["hk"] == DBNull.Value ? (int?)null : Convert.ToInt32(reader["hk"]),
                            NAM = reader["nam"] == DBNull.Value ? (int?)null : Convert.ToInt32(reader["nam"]),
                        }
                        ;
                        mm.isInDB = true;
                        result.Add(mm);
                    }
                }
            }

            return result.Cast<object>().ToList();
        }

        public bool Update(object obj)
        {
            try
            {
                if (sqlConnection.State != ConnectionState.Open)
                {
                    sqlConnection.Open();
                }
                Model.MoMon mm = (Model.MoMon)obj;
                using (var cmd = new OracleCommand("X_ADMIN.X_ADMIN_update_view_PDT_MOMON", sqlConnection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new OracleParameter("MaMM_", mm.MAMM));
                    cmd.Parameters.Add(new OracleParameter("MaHP_", mm.MAHP));
                    cmd.Parameters.Add(new OracleParameter("MaGV_", mm.MAGV));
                    cmd.Parameters.Add(new OracleParameter("HK_", mm.HK));
                    cmd.Parameters.Add(new OracleParameter("NAM_", mm.NAM));

                    var rowAffectedParam = new OracleParameter("ROW_AFFECTED", OracleDbType.Int32);
                    rowAffectedParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(rowAffectedParam);

                    cmd.ExecuteNonQuery();
                    int rowsAffected = ((OracleDecimal)rowAffectedParam.Value).ToInt32();
                    sqlConnection.Close();
                    return rowsAffected > 0;
                }
            }
            catch (System.Exception e)
            {
                sqlConnection.Close();
                return false;
            }
        }
    }
}
