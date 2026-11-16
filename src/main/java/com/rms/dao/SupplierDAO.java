package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import com.rms.model.Supplier;

/**
 * DAO quản lý thông tin Nhà cung cấp nguyên liệu (tblSupplier).
 */
public class SupplierDAO extends DAO {

    public SupplierDAO() {
        super();
    }

    public ArrayList<Supplier> getAllSuppliers() {
        ArrayList<Supplier> list = new ArrayList<>();
        String sql = "SELECT id, name, address, phone, email, taxCode FROM tblSupplier ORDER BY id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapSupplier(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Supplier getSupplierById(int id) {
        String sql = "SELECT id, name, address, phone, email, taxCode FROM tblSupplier WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSupplier(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addSupplier(Supplier s) {
        if (s == null || s.getName() == null || s.getName().trim().isEmpty()
                || s.getPhone() == null || s.getPhone().trim().isEmpty()) {
            return false;
        }
        String sql = "INSERT INTO tblSupplier (name, address, phone, email, taxCode) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, s.getName().trim());
            ps.setString(2, s.getAddress() != null ? s.getAddress().trim() : "");
            ps.setString(3, s.getPhone().trim());
            ps.setString(4, s.getEmail() != null ? s.getEmail().trim() : "");
            ps.setString(5, s.getTaxCode() != null ? s.getTaxCode().trim() : "");
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) s.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupplier(Supplier s) {
        if (s == null || s.getId() <= 0 || s.getName() == null || s.getName().trim().isEmpty()
                || s.getPhone() == null || s.getPhone().trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE tblSupplier SET name = ?, address = ?, phone = ?, email = ?, taxCode = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getName().trim());
            ps.setString(2, s.getAddress() != null ? s.getAddress().trim() : "");
            ps.setString(3, s.getPhone().trim());
            ps.setString(4, s.getEmail() != null ? s.getEmail().trim() : "");
            ps.setString(5, s.getTaxCode() != null ? s.getTaxCode().trim() : "");
            ps.setInt(6, s.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Supplier mapSupplier(ResultSet rs) throws Exception {
        Supplier s = new Supplier();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setAddress(rs.getString("address"));
        s.setPhone(rs.getString("phone"));
        s.setEmail(rs.getString("email"));
        s.setTaxCode(rs.getString("taxCode"));
        return s;
    }
}
