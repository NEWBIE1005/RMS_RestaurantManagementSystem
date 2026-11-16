package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import com.rms.model.ImportDetail;
import com.rms.model.Ingredient;

/**
 * DAO thao tác chi tiết từng dòng nhập nguyên liệu (tblImportDetail).
 */
public class ImportDetailDAO extends DAO {

    public ImportDetailDAO() {
        super();
    }

    public boolean saveImportDetail(ImportDetail detail, int receiptId) {
        if (detail == null || receiptId <= 0 || detail.getIngredient() == null
                || detail.getIngredient().getId() <= 0 || detail.getQuantity() <= 0 || detail.getImportPrice() <= 0) {
            return false;
        }
        float subTotal = detail.getQuantity() * detail.getImportPrice();
        detail.setSubTotal(subTotal);

        String sql = "INSERT INTO tblImportDetail (receiptId, ingredientId, quantity, importPrice, subTotal) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, receiptId);
            ps.setInt(2, detail.getIngredient().getId());
            ps.setFloat(3, detail.getQuantity());
            ps.setFloat(4, detail.getImportPrice());
            ps.setFloat(5, subTotal);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) detail.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public ArrayList<ImportDetail> getDetailsByReceiptId(int receiptId) {
        ArrayList<ImportDetail> list = new ArrayList<>();
        String sql = "SELECT dt.id, dt.quantity, dt.importPrice, dt.subTotal, "
                + "i.id AS ingId, i.code, i.name, i.unit "
                + "FROM tblImportDetail dt JOIN tblIngredient i ON dt.ingredientId = i.id "
                + "WHERE dt.receiptId = ? ORDER BY dt.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportDetail d = new ImportDetail();
                    d.setId(rs.getInt("id"));
                    d.setQuantity(rs.getFloat("quantity"));
                    d.setImportPrice(rs.getFloat("importPrice"));
                    d.setSubTotal(rs.getFloat("subTotal"));
                    Ingredient ing = new Ingredient();
                    ing.setId(rs.getInt("ingId"));
                    ing.setCode(rs.getString("code"));
                    ing.setName(rs.getString("name"));
                    ing.setUnit(rs.getString("unit"));
                    d.setIngredient(ing);
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
