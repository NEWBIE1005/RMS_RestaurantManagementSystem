package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Category;
import com.rms.model.DishStat;

/**
 * DAO thống kê số lượng gọi và doanh thu theo từng Món ăn (DishStat).
 */
public class DishStatDAO extends DAO {

    public DishStatDAO() {
        super();
    }

    public ArrayList<DishStat> getDishStatistics() {
        ArrayList<DishStat> list = new ArrayList<>();
        String sql = "SELECT d.id, d.code, d.name, d.price, d.unit, d.status, "
                + "c.id AS catId, c.code AS catCode, c.name AS catName, "
                + "COALESCE(SUM(CASE WHEN o.id IS NOT NULL AND o.status <> 'Đã hủy' THEN od.quantity ELSE 0 END), 0) AS totalQty, "
                + "COALESCE(SUM(CASE WHEN o.id IS NOT NULL AND o.status <> 'Đã hủy' THEN od.quantity * od.price ELSE 0 END), 0) AS totalRev "
                + "FROM tblDish d "
                + "JOIN tblCategory c ON d.categoryId = c.id "
                + "LEFT JOIN tblOrderedDish od ON d.id = od.dishId "
                + "LEFT JOIN tblOrderOnline o ON od.orderId = o.id "
                + "GROUP BY d.id, d.code, d.name, d.price, d.unit, d.status, c.id, c.code, c.name "
                + "ORDER BY totalRev DESC, totalQty DESC, d.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DishStat st = new DishStat();
                st.setId(rs.getInt("id"));
                st.setCode(rs.getString("code"));
                st.setName(rs.getString("name"));
                st.setPrice(rs.getFloat("price"));
                st.setUnit(rs.getString("unit"));
                st.setStatus(rs.getString("status"));
                Category cat = new Category();
                cat.setId(rs.getInt("catId"));
                cat.setCode(rs.getString("catCode"));
                cat.setName(rs.getString("catName"));
                st.setCategory(cat);
                st.setTotalOrderedQty(rs.getInt("totalQty"));
                st.setTotalRevenue(rs.getFloat("totalRev"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
