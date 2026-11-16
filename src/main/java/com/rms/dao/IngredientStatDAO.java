package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.IngredientStat;

/**
 * DAO thống kê tồn kho và lượng nhập từng Nguyên liệu (IngredientStat).
 */
public class IngredientStatDAO extends DAO {

    public IngredientStatDAO() {
        super();
    }

    public ArrayList<IngredientStat> getIngredientStatistics() {
        ArrayList<IngredientStat> list = new ArrayList<>();
        String sql = "SELECT i.id, i.code, i.name, i.unit, i.unitPrice, i.stockQuantity, i.minStockThreshold, "
                + "COALESCE(SUM(dt.quantity), 0) AS totalImportedQty, "
                + "COALESCE(SUM(dt.subTotal), 0) AS totalImportCost "
                + "FROM tblIngredient i "
                + "LEFT JOIN tblImportDetail dt ON i.id = dt.ingredientId "
                + "GROUP BY i.id, i.code, i.name, i.unit, i.unitPrice, i.stockQuantity, i.minStockThreshold "
                + "ORDER BY (i.stockQuantity - i.minStockThreshold) ASC, i.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                IngredientStat st = new IngredientStat();
                st.setId(rs.getInt("id"));
                st.setCode(rs.getString("code"));
                st.setName(rs.getString("name"));
                st.setUnit(rs.getString("unit"));
                st.setUnitPrice(rs.getFloat("unitPrice"));
                st.setStockQuantity(rs.getFloat("stockQuantity"));
                st.setMinStockThreshold(rs.getFloat("minStockThreshold"));
                st.setTotalImportedQty(rs.getFloat("totalImportedQty"));
                st.setTotalImportCost(rs.getFloat("totalImportCost"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
