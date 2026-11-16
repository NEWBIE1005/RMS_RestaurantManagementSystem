package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Category;
import com.rms.model.CustomerStat;
import com.rms.model.DishStat;
import com.rms.model.IngredientStat;
import com.rms.model.SupplierStat;

/**
 * DAO tổng hợp các báo cáo thống kê phục vụ Nhân viên Quản lý.
 */
public class StatDAO extends DAO {

    public StatDAO() {
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

    public ArrayList<IngredientStat> getIngredientStatistics() {
        ArrayList<IngredientStat> list = new ArrayList<>();
        String sql = "SELECT i.id, i.code, i.name, i.unit, i.unitPrice, i.stockQuantity, i.minStockThreshold, "
                + "COALESCE(SUM(dt.quantity), 0) AS totalImportedQty, "
                + "COALESCE(SUM(dt.subTotal), 0) AS totalImportCost "
                + "FROM tblIngredient i "
                + "LEFT JOIN tblImportDetail dt ON i.id = dt.ingredientId "
                + "GROUP BY i.id, i.code, i.name, i.unit, i.unitPrice, i.stockQuantity, i.minStockThreshold "
                + "ORDER BY (i.stockQuantity - i.minStockThreshold) ASC, i.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                IngredientStat st = new IngredientStat();
                st.setId(rs.getInt("id"));
                st.setCode(rs.getString("code"));
                st.setName(rs.getString("name"));
                st.setUnit(rs.getString("unit"));
                st.setUnitPrice(rs.getFloat("unitPrice"));
                st.setStockQuantity(rs.getFloat("stockQuantity"));
                st.setMinStockThreshold(rs.getFloat("minStockThreshold"));
                st.setTotalImportedQty(rs.getFloat("totalImportedQty"));
                st.setTotalImportCost(rs.getFloat("totalImportCost"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<CustomerStat> getCustomerStatistics() {
        ArrayList<CustomerStat> list = new ArrayList<>();
        String sql = "SELECT u.id, u.fullName, u.phone, u.email, c.customerCode, c.membershipLevel, c.rewardPoints, "
                + "COUNT(DISTINCT r.id) AS totalRes, "
                + "COALESCE(SUM(CASE WHEN o.id IS NOT NULL AND o.status <> 'Đã hủy' THEN o.totalAmount ELSE 0 END), 0) AS totalSpent "
                + "FROM tblCustomer c "
                + "JOIN tblUser u ON c.userId = u.id "
                + "LEFT JOIN tblReservation r ON c.userId = r.customerId "
                + "LEFT JOIN tblOrderOnline o ON r.id = o.reservationId "
                + "GROUP BY u.id, u.fullName, u.phone, u.email, c.customerCode, c.membershipLevel, c.rewardPoints "
                + "ORDER BY totalSpent DESC, totalRes DESC, u.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerStat st = new CustomerStat();
                st.setId(rs.getInt("id"));
                st.setFullName(rs.getString("fullName"));
                st.setPhone(rs.getString("phone"));
                st.setEmail(rs.getString("email"));
                st.setCustomerCode(rs.getString("customerCode"));
                st.setMembershipLevel(rs.getString("membershipLevel"));
                st.setRewardPoints(rs.getInt("rewardPoints"));
                st.setTotalReservations(rs.getInt("totalRes"));
                st.setTotalSpent(rs.getFloat("totalSpent"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<SupplierStat> getSupplierStatistics() {
        ArrayList<SupplierStat> list = new ArrayList<>();
        String sql = "SELECT s.id, s.name, s.address, s.phone, s.email, s.taxCode, "
                + "COUNT(ir.id) AS totalReceipts, "
                + "COALESCE(SUM(ir.totalAmount), 0) AS totalSupplyValue "
                + "FROM tblSupplier s "
                + "LEFT JOIN tblImportReceipt ir ON s.id = ir.supplierId "
                + "GROUP BY s.id, s.name, s.address, s.phone, s.email, s.taxCode "
                + "ORDER BY totalSupplyValue DESC, s.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SupplierStat st = new SupplierStat();
                st.setId(rs.getInt("id"));
                st.setName(rs.getString("name"));
                st.setAddress(rs.getString("address"));
                st.setPhone(rs.getString("phone"));
                st.setEmail(rs.getString("email"));
                st.setTaxCode(rs.getString("taxCode"));
                st.setTotalReceipts(rs.getInt("totalReceipts"));
                st.setTotalSupplyValue(rs.getFloat("totalSupplyValue"));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
