package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.SupplierStat;

/**
 * DAO thống kê số lần nhập hàng và giá trị cung ứng theo Nhà cung cấp (SupplierStat).
 */
public class SupplierStatDAO extends DAO {

    public SupplierStatDAO() {
        super();
    }

    public ArrayList<SupplierStat> getSupplierStatistics() {
        ArrayList<SupplierStat> list = new ArrayList<>();
        String sql = "SELECT s.id, s.name, s.address, s.phone, s.email, s.taxCode, "
                + "COUNT(ir.id) AS totalReceipts, "
                + "COALESCE(SUM(ir.totalAmount), 0) AS totalSupplyValue "
                + "FROM tblSupplier s "
                + "LEFT JOIN tblImportReceipt ir ON s.id = ir.supplierId "
                + "GROUP BY s.id, s.name, s.address, s.phone, s.email, s.taxCode "
                + "ORDER BY totalSupplyValue DESC, s.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SupplierStat st = new SupplierStat();
                st.setId(rs.getInt("id"));
                st.setName(rs.getString("name"));
                st.setAddress(rs.getString("address"));
                st.setPhone(rs.getString("phone"));
                st.setEmail(rs.getString("email"));
                st.setTaxCode(rs.getString("taxCode"));
                st.setTotalReceipts(rs.getInt("totalReceipts"));
                st.setTotalSupplyValue(rs.getFloat("totalSupplyValue"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
