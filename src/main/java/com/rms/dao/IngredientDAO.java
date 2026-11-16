package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import com.rms.model.Ingredient;

/**
 * DAO quản lý Nguyên liệu và tồn kho (tblIngredient).
 */
public class IngredientDAO extends DAO {

    public IngredientDAO() {
        super();
    }

    public ArrayList<Ingredient> getAllIngredients() {
        ArrayList<Ingredient> list = new ArrayList<>();
        String sql = "SELECT id, code, name, unit, unitPrice, stockQuantity, minStockThreshold "
                + "FROM tblIngredient ORDER BY id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapIngredient(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ingredient getIngredientById(int id) {
        String sql = "SELECT id, code, name, unit, unitPrice, stockQuantity, minStockThreshold "
                + "FROM tblIngredient WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapIngredient(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addIngredient(Ingredient ing) {
        if (ing == null || ing.getCode() == null || ing.getCode().trim().isEmpty()
                || ing.getName() == null || ing.getName().trim().isEmpty() || ing.getUnitPrice() <= 0) {
            return false;
        }
        String sql = "INSERT INTO tblIngredient (code, name, unit, unitPrice, stockQuantity, minStockThreshold) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, ing.getCode().trim().toUpperCase());
            ps.setString(2, ing.getName().trim());
            ps.setString(3, ing.getUnit() != null && !ing.getUnit().trim().isEmpty() ? ing.getUnit().trim() : "kg");
            ps.setFloat(4, ing.getUnitPrice());
            ps.setFloat(5, Math.max(0f, ing.getStockQuantity()));
            ps.setFloat(6, Math.max(0f, ing.getMinStockThreshold()));
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) ing.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addStock(int ingredientId, float addedQty, float latestUnitPrice) {
        if (ingredientId <= 0 || addedQty <= 0 || latestUnitPrice <= 0) return false;
        String sql = "UPDATE tblIngredient SET stockQuantity = stockQuantity + ?, unitPrice = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setFloat(1, addedQty);
            ps.setFloat(2, latestUnitPrice);
            ps.setInt(3, ingredientId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Ingredient mapIngredient(ResultSet rs) throws Exception {
        Ingredient ing = new Ingredient();
        ing.setId(rs.getInt("id"));
        ing.setCode(rs.getString("code"));
        ing.setName(rs.getString("name"));
        ing.setUnit(rs.getString("unit"));
        ing.setUnitPrice(rs.getFloat("unitPrice"));
        ing.setStockQuantity(rs.getFloat("stockQuantity"));
        ing.setMinStockThreshold(rs.getFloat("minStockThreshold"));
        return ing;
    }
}
