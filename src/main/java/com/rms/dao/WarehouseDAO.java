package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import com.rms.model.ImportDetail;
import com.rms.model.ImportReceipt;
import com.rms.model.Ingredient;
import com.rms.model.Staff;
import com.rms.model.Supplier;

/**
 * DAO phục vụ Nhân viên Kho: Quản lý Nhà cung cấp, Nguyên liệu & Nhập kho.
 */
public class WarehouseDAO extends DAO {

    public WarehouseDAO() {
        super();
    }

    public ArrayList<Ingredient> getAllIngredients() {
        ArrayList<Ingredient> list = new ArrayList<>();
        String sql = "SELECT id, code, name, unit, unitPrice, stockQuantity, minStockThreshold "
                + "FROM tblIngredient ORDER BY id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ingredient ing = new Ingredient();
                ing.setId(rs.getInt("id"));
                ing.setCode(rs.getString("code"));
                ing.setName(rs.getString("name"));
                ing.setUnit(rs.getString("unit"));
                ing.setUnitPrice(rs.getFloat("unitPrice"));
                ing.setStockQuantity(rs.getFloat("stockQuantity"));
                ing.setMinStockThreshold(rs.getFloat("minStockThreshold"));
                list.add(ing);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Supplier> getAllSuppliers() {
        ArrayList<Supplier> list = new ArrayList<>();
        String sql = "SELECT id, name, address, phone, email, taxCode FROM tblSupplier ORDER BY id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier s = new Supplier();
                s.setId(rs.getInt("id"));
                s.setName(rs.getString("name"));
                s.setAddress(rs.getString("address"));
                s.setPhone(rs.getString("phone"));
                s.setEmail(rs.getString("email"));
                s.setTaxCode(rs.getString("taxCode"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addSupplier(Supplier s) {
        if (s == null || s.getName() == null || s.getName().trim().isEmpty()
                || s.getPhone() == null || s.getPhone().trim().isEmpty()) {
            return false;
        }
        String sql = "INSERT INTO tblSupplier (name, address, phone, email, taxCode) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getName().trim());
            ps.setString(2, s.getAddress() != null ? s.getAddress().trim() : "");
            ps.setString(3, s.getPhone().trim());
            ps.setString(4, s.getEmail() != null ? s.getEmail().trim() : "");
            ps.setString(5, s.getTaxCode() != null ? s.getTaxCode().trim() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public ArrayList<ImportReceipt> getRecentReceipts() {
        ArrayList<ImportReceipt> list = new ArrayList<>();
        String sql = "SELECT ir.id, ir.receiptCode, ir.importDate, ir.totalAmount, ir.note, "
                + "s.id AS supId, s.name AS supName, u.fullName AS staffName "
                + "FROM tblImportReceipt ir "
                + "JOIN tblSupplier s ON ir.supplierId = s.id "
                + "JOIN tblUser u ON ir.staffId = u.id "
                + "ORDER BY ir.importDate DESC, ir.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ImportReceipt ir = new ImportReceipt();
                ir.setId(rs.getInt("id"));
                ir.setReceiptCode(rs.getString("receiptCode"));
                ir.setImportDate(rs.getTimestamp("importDate"));
                ir.setTotalAmount(rs.getFloat("totalAmount"));
                ir.setNote(rs.getString("note"));
                Supplier sup = new Supplier();
                sup.setId(rs.getInt("supId"));
                sup.setName(rs.getString("supName"));
                ir.setSupplier(sup);
                Staff st = new Staff();
                st.setFullName(rs.getString("staffName"));
                ir.setStaff(st);
                list.add(ir);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createImportReceipt(ImportReceipt receipt) {
        if (receipt == null || receipt.getSupplier() == null || receipt.getStaff() == null
                || receipt.getDsChiTiet() == null || receipt.getDsChiTiet().isEmpty()) {
            return false;
        }
        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

            float total = 0f;
            for (ImportDetail d : receipt.getDsChiTiet()) {
                if (d.getIngredient() == null || d.getQuantity() <= 0 || d.getImportPrice() <= 0) {
                    if (manageTransaction) con.rollback();
                    return false;
                }
                d.setSubTotal(d.getQuantity() * d.getImportPrice());
                total += d.getSubTotal();
            }
            receipt.setTotalAmount(total);

            String sqlHead = "INSERT INTO tblImportReceipt (receiptCode, supplierId, staffId, importDate, totalAmount, note) VALUES (?, ?, ?, ?, ?, ?)";
            int recId = -1;
            Timestamp now = new Timestamp(receipt.getImportDate() != null ? receipt.getImportDate().getTime() : System.currentTimeMillis());
            try (PreparedStatement ps = con.prepareStatement(sqlHead, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, receipt.getReceiptCode());
                ps.setInt(2, receipt.getSupplier().getId());
                ps.setInt(3, receipt.getStaff().getId());
                ps.setTimestamp(4, now);
                ps.setFloat(5, total);
                ps.setString(6, receipt.getNote() != null ? receipt.getNote().trim() : "");
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) recId = keys.getInt(1);
                }
            }
            if (recId <= 0) {
                if (manageTransaction) con.rollback();
                return false;
            }
            receipt.setId(recId);

            String sqlDet = "INSERT INTO tblImportDetail (receiptId, ingredientId, quantity, importPrice, subTotal) VALUES (?, ?, ?, ?, ?)";
            String sqlStock = "UPDATE tblIngredient SET stockQuantity = stockQuantity + ?, unitPrice = ? WHERE id = ?";
            try (PreparedStatement psDet = con.prepareStatement(sqlDet);
                 PreparedStatement psStock = con.prepareStatement(sqlStock)) {
                for (ImportDetail d : receipt.getDsChiTiet()) {
                    psDet.setInt(1, recId);
                    psDet.setInt(2, d.getIngredient().getId());
                    psDet.setFloat(3, d.getQuantity());
                    psDet.setFloat(4, d.getImportPrice());
                    psDet.setFloat(5, d.getSubTotal());
                    psDet.addBatch();

                    psStock.setFloat(1, d.getQuantity());
                    psStock.setFloat(2, d.getImportPrice());
                    psStock.setInt(3, d.getIngredient().getId());
                    psStock.addBatch();
                }
                psDet.executeBatch();
                psStock.executeBatch();
            }

            if (manageTransaction) con.commit();
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
}
