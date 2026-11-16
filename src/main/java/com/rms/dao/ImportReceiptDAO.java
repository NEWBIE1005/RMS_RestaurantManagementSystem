package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import com.rms.model.ImportDetail;
import com.rms.model.ImportReceipt;
import com.rms.model.Supplier;
import com.rms.model.WarehouseStaff;

/**
 * DAO quản lý Phiếu nhập nguyên liệu kho (tblImportReceipt), điều phối ImportDetailDAO & IngredientDAO.
 */
public class ImportReceiptDAO extends DAO {

    public ImportReceiptDAO() {
        super();
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
            ImportDetailDAO detDAO = new ImportDetailDAO();
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
                WarehouseStaff st = new WarehouseStaff();
                st.setFullName(rs.getString("staffName"));
                ir.setStaff(st);
                ir.setDsChiTiet(detDAO.getDetailsByReceiptId(ir.getId()));
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
        float total = 0f;
        for (ImportDetail d : receipt.getDsChiTiet()) {
            if (d == null || d.getIngredient() == null || d.getQuantity() <= 0 || d.getImportPrice() <= 0) {
                return false;
            }
            d.setSubTotal(d.getQuantity() * d.getImportPrice());
            total += d.getSubTotal();
        }
        receipt.setTotalAmount(total);

        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

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
                throw new IllegalStateException("Không chèn được bản ghi tblImportReceipt");
            }
            receipt.setId(recId);

            ImportDetailDAO detDAO = new ImportDetailDAO();
            IngredientDAO ingDAO = new IngredientDAO();
            for (ImportDetail d : receipt.getDsChiTiet()) {
                if (!detDAO.saveImportDetail(d, recId)
                        || !ingDAO.addStock(d.getIngredient().getId(), d.getQuantity(), d.getImportPrice())) {
                    throw new IllegalStateException("Không thể lưu chi tiết hoặc cập nhật tồn kho nguyên liệu");
                }
            }

            if (manageTransaction) con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (manageTransaction) con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            return false;
        } finally {
            if (manageTransaction) {
                try { con.setAutoCommit(true); } catch (Exception ex) { ex.printStackTrace(); }
            }
        }
    }
}
