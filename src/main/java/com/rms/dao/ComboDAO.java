package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import com.rms.model.Combo;
import com.rms.model.ComboDish;
import com.rms.model.Dish;

/**
 * DAO quản lý Thực đơn Combo (tblCombo & tblComboDish).
 */
public class ComboDAO extends DAO {

    public ComboDAO() {
        super();
    }

    public ArrayList<Combo> getAllCombos() {
        ArrayList<Combo> result = new ArrayList<>();
        String sql = "SELECT id, name, discountRate, totalPrice, description FROM tblCombo ORDER BY id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Combo c = new Combo();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setDiscountRate(rs.getFloat("discountRate"));
                c.setTotalPrice(rs.getFloat("totalPrice"));
                c.setDescription(rs.getString("description"));
                c.setDsComboDish(getComboDishes(c.getId()));
                result.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public Combo getComboById(int id) {
        String sql = "SELECT id, name, discountRate, totalPrice, description FROM tblCombo WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Combo c = new Combo();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setDiscountRate(rs.getFloat("discountRate"));
                    c.setTotalPrice(rs.getFloat("totalPrice"));
                    c.setDescription(rs.getString("description"));
                    c.setDsComboDish(getComboDishes(c.getId()));
                    return c;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private ArrayList<ComboDish> getComboDishes(int comboId) {
        ArrayList<ComboDish> list = new ArrayList<>();
        String sql = "SELECT cd.id, cd.quantity, d.id AS dishId, d.code, d.name, d.price, d.unit, d.status "
                + "FROM tblComboDish cd "
                + "JOIN tblDish d ON cd.dishId = d.id "
                + "WHERE cd.comboId = ? ORDER BY cd.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, comboId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ComboDish cd = new ComboDish();
                    cd.setId(rs.getInt("id"));
                    cd.setQuantity(rs.getInt("quantity"));
                    Dish d = new Dish();
                    d.setId(rs.getInt("dishId"));
                    d.setCode(rs.getString("code"));
                    d.setName(rs.getString("name"));
                    d.setPrice(rs.getFloat("price"));
                    d.setUnit(rs.getString("unit"));
                    d.setStatus(rs.getString("status"));
                    cd.setDish(d);
                    list.add(cd);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createCombo(Combo combo) {
        if (combo == null || combo.getName() == null || combo.getName().trim().isEmpty()
                || combo.getDsComboDish() == null || combo.getDsComboDish().isEmpty()) {
            return false;
        }
        if (combo.getDiscountRate() < 0 || combo.getDiscountRate() > 80) {
            return false;
        }

        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) {
                con.setAutoCommit(false);
            }

            float rawSum = 0f;
            String sqlPrice = "SELECT price FROM tblDish WHERE id = ?";
            for (ComboDish item : combo.getDsComboDish()) {
                if (item.getDish() == null || item.getQuantity() <= 0) {
                    if (manageTransaction) con.rollback();
                    return false;
                }
                try (PreparedStatement psP = con.prepareStatement(sqlPrice)) {
                    psP.setInt(1, item.getDish().getId());
                    try (ResultSet rs = psP.executeQuery()) {
                        if (!rs.next()) {
                            if (manageTransaction) con.rollback();
                            return false;
                        }
                        rawSum += rs.getFloat("price") * item.getQuantity();
                    }
                }
            }
            float discountedTotal = Math.round(rawSum * (100f - combo.getDiscountRate()) / 100f);
            combo.setTotalPrice(discountedTotal);

            String sqlInsertCombo = "INSERT INTO tblCombo (name, discountRate, totalPrice, description) VALUES (?, ?, ?, ?)";
            int generatedComboId = -1;
            try (PreparedStatement ps = con.prepareStatement(sqlInsertCombo, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, combo.getName().trim());
                ps.setFloat(2, combo.getDiscountRate());
                ps.setFloat(3, discountedTotal);
                ps.setString(4, combo.getDescription() != null ? combo.getDescription().trim() : "");
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        generatedComboId = keys.getInt(1);
                    }
                }
            }
            if (generatedComboId <= 0) {
                if (manageTransaction) con.rollback();
                return false;
            }
            combo.setId(generatedComboId);

            String sqlInsertItem = "INSERT INTO tblComboDish (comboId, dishId, quantity) VALUES (?, ?, ?)";
            try (PreparedStatement psItem = con.prepareStatement(sqlInsertItem)) {
                for (ComboDish item : combo.getDsComboDish()) {
                    psItem.setInt(1, generatedComboId);
                    psItem.setInt(2, item.getDish().getId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.addBatch();
                }
                psItem.executeBatch();
            }

            if (manageTransaction) {
                con.commit();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (manageTransaction) con.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            if (manageTransaction) {
                try {
                    con.setAutoCommit(true);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public boolean deleteCombo(int comboId) {
        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement("DELETE FROM tblComboDish WHERE comboId = ?");
                 PreparedStatement ps2 = con.prepareStatement("DELETE FROM tblCombo WHERE id = ?")) {
                ps1.setInt(1, comboId);
                ps1.executeUpdate();
                ps2.setInt(1, comboId);
                int rows = ps2.executeUpdate();
                if (manageTransaction) con.commit();
                return rows > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (manageTransaction) con.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            if (manageTransaction) {
                try {
                    con.setAutoCommit(true);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}
