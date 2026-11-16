package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Category;
import com.rms.model.Dish;

/**
 * Lớp DAO quản lý truy vấn và cập nhật thông tin món ăn (tblDish).
 */
public class DishDAO extends DAO {

    public DishDAO() {
        super();
    }

    /**
     * Tìm kiếm món ăn theo tên (Module 1: NV Quản lý tìm món để sửa).
     */
    public ArrayList<Dish> searchDishByName(String name) {
        return searchDish(name, 0);
    }

    /**
     * Tìm kiếm món ăn theo tên và loại món (Module 2: Khách hàng tìm món theo tên/loại).
     */
    public ArrayList<Dish> searchDish(String name, int categoryId) {
        ArrayList<Dish> list = new ArrayList<>();
        String keyword = (name == null) ? "" : name.trim();
        StringBuilder sql = new StringBuilder(
                "SELECT d.id, d.code, d.name, d.price, d.unit, d.description, d.status, d.image, "
                + "c.id AS catId, c.code AS catCode, c.name AS catName, c.description AS catDesc "
                + "FROM tblDish d JOIN tblCategory c ON d.categoryId = c.id "
                + "WHERE LOWER(d.name) LIKE LOWER(?) ");
        if (categoryId > 0) {
            sql.append("AND d.categoryId = ? ");
        }
        sql.append("ORDER BY d.id");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setString(1, "%" + keyword + "%");
            if (categoryId > 0) {
                ps.setInt(2, categoryId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDish(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết của một món ăn theo mã ID.
     */
    public Dish getDishById(int id) {
        String sql = "SELECT d.id, d.code, d.name, d.price, d.unit, d.description, d.status, d.image, "
                + "c.id AS catId, c.code AS catCode, c.name AS catName, c.description AS catDesc "
                + "FROM tblDish d JOIN tblCategory c ON d.categoryId = c.id "
                + "WHERE d.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDish(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra trùng tên món ăn khi sửa (loại trừ chính món đang sửa).
     */
    public boolean checkDuplicateName(int id, String name) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM tblDish WHERE LOWER(name) = LOWER(?) AND id <> ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setInt(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật thông tin món ăn vào CSDL.
     */
    public boolean updateDish(Dish dish) {
        if (dish == null || dish.getId() <= 0 || dish.getName() == null
                || dish.getName().trim().isEmpty() || dish.getPrice() <= 0
                || dish.getCategory() == null || dish.getCategory().getId() <= 0) {
            return false;
        }
        String sql = "UPDATE tblDish SET name = ?, price = ?, unit = ?, categoryId = ?, "
                + "description = ?, status = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dish.getName().trim());
            ps.setFloat(2, dish.getPrice());
            ps.setString(3, dish.getUnit() != null ? dish.getUnit().trim() : "");
            ps.setInt(4, dish.getCategory().getId());
            ps.setString(5, dish.getDescription() != null ? dish.getDescription().trim() : "");
            ps.setString(6, dish.getStatus() != null ? dish.getStatus().trim() : "Đang phục vụ");
            ps.setInt(7, dish.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Dish mapDish(ResultSet rs) throws Exception {
        Dish d = new Dish();
        d.setId(rs.getInt("id"));
        d.setCode(rs.getString("code"));
        d.setName(rs.getString("name"));
        d.setPrice(rs.getFloat("price"));
        d.setUnit(rs.getString("unit"));
        d.setDescription(rs.getString("description"));
        d.setStatus(rs.getString("status"));
        d.setImage(rs.getString("image"));

        Category c = new Category();
        c.setId(rs.getInt("catId"));
        c.setCode(rs.getString("catCode"));
        c.setName(rs.getString("catName"));
        c.setDescription(rs.getString("catDesc"));
        d.setCategory(c);
        return d;
    }
}
