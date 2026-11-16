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

    /**
     * Kiểm tra trùng mã món ăn (code).
     */
    public boolean checkDuplicateCode(String code) {
        if (code == null || code.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM tblDish WHERE UPPER(code) = UPPER(?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Thêm món ăn mới vào thực đơn (tblDish).
     */
    public boolean insertDish(Dish d) {
        if (d == null || d.getCode() == null || d.getCode().trim().isEmpty()
                || d.getName() == null || d.getName().trim().isEmpty()
                || d.getPrice() <= 0 || d.getCategory() == null || d.getCategory().getId() <= 0) {
            return false;
        }
        if (checkDuplicateCode(d.getCode()) || checkDuplicateName(0, d.getName())) {
            return false;
        }
        String sql = "INSERT INTO tblDish (categoryId, code, name, price, unit, description, status, image) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getCategory().getId());
            ps.setString(2, d.getCode().trim().toUpperCase());
            ps.setString(3, d.getName().trim());
            ps.setFloat(4, d.getPrice());
            ps.setString(5, (d.getUnit() != null && !d.getUnit().trim().isEmpty()) ? d.getUnit().trim() : "Đĩa");
            ps.setString(6, d.getDescription() != null ? d.getDescription().trim() : "");
            ps.setString(7, (d.getStatus() != null && !d.getStatus().trim().isEmpty()) ? d.getStatus().trim() : "Đang phục vụ");
            ps.setString(8, d.getImage() != null ? d.getImage().trim() : "");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        d.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa món ăn nếu chưa phát sinh trong đơn gọi/combo, ngược lại chuyển trạng thái 'Ngừng phục vụ'.
     */
    public String deleteOrDeactivateDish(int dishId) {
        if (dishId <= 0) return "ERROR";
        try {
            int refCount = 0;
            try (PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) FROM tblOrderedDish WHERE dishId = ?");
                 PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) FROM tblComboDish WHERE dishId = ?")) {
                ps1.setInt(1, dishId);
                try (ResultSet rs = ps1.executeQuery()) { if (rs.next()) refCount += rs.getInt(1); }
                ps2.setInt(1, dishId);
                try (ResultSet rs = ps2.executeQuery()) { if (rs.next()) refCount += rs.getInt(1); }
            }
            if (refCount > 0) {
                try (PreparedStatement psUp = con.prepareStatement("UPDATE tblDish SET status = 'Ngừng phục vụ' WHERE id = ?")) {
                    psUp.setInt(1, dishId);
                    return psUp.executeUpdate() > 0 ? "DEACTIVATED" : "ERROR";
                }
            } else {
                try (PreparedStatement psDel = con.prepareStatement("DELETE FROM tblDish WHERE id = ?")) {
                    psDel.setInt(1, dishId);
                    return psDel.executeUpdate() > 0 ? "DELETED" : "ERROR";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR";
        }
    }
}
