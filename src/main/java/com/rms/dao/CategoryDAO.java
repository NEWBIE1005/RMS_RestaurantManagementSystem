package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Category;

/**
 * Lớp DAO truy xuất dữ liệu danh mục loại món ăn (tblCategory).
 */
public class CategoryDAO extends DAO {

    public CategoryDAO() {
        super();
    }

    /**
     * Lấy toàn bộ danh sách loại món ăn.
     */
    public ArrayList<Category> getAllCategories() {
        ArrayList<Category> list = new ArrayList<>();
        String sql = "SELECT id, code, name, description FROM tblCategory ORDER BY id";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setCode(rs.getString("code"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
