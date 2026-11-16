package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import com.rms.model.Customer;

/**
 * DAO quản lý thông tin Khách hàng & thẻ thành viên tích điểm (tblCustomer).
 */
public class CustomerDAO extends DAO {

    public CustomerDAO() {
        super();
    }

    public ArrayList<Customer> getAllCustomers() {
        ArrayList<Customer> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.password, u.fullName, u.phone, u.email, u.address, u.role, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints "
                + "FROM tblCustomer c JOIN tblUser u ON c.userId = u.id "
                + "ORDER BY c.rewardPoints DESC, u.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCustomer(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Customer getCustomerByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return null;
        String sql = "SELECT u.id, u.username, u.password, u.fullName, u.phone, u.email, u.address, u.role, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints "
                + "FROM tblUser u JOIN tblCustomer c ON u.id = c.userId WHERE u.phone = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCustomer(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Customer createMembershipCustomer(String fullName, String phone, String email, String address, String level) {
        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            return null;
        }
        String cleanPhone = phone.trim();
        if (getCustomerByPhone(cleanPhone) != null) {
            return null;
        }
        return insertCustomerRecord(fullName, cleanPhone, email, address, level);
    }

    /**
     * Tìm khách theo SĐT hoặc tạo nhanh hồ sơ khách hàng mới khi đặt bàn / nhận khách tại quầy.
     */
    public Customer findOrCreateCustomer(String fullName, String phone, String email) {
        if (phone == null || phone.trim().isEmpty()) return null;
        Customer existing = getCustomerByPhone(phone.trim());
        if (existing != null) return existing;
        return insertCustomerRecord(fullName, phone.trim(), email, "", "Thành viên");
    }

    public boolean addRewardPoints(int customerUserId, int earnedPoints) {
        if (customerUserId <= 0 || earnedPoints <= 0) return false;
        String sql = "UPDATE tblCustomer SET rewardPoints = rewardPoints + ?, "
                + "membershipLevel = CASE "
                + "  WHEN rewardPoints + ? >= 1500 THEN 'Gold' "
                + "  WHEN rewardPoints + ? >= 500 THEN 'Silver' "
                + "  ELSE membershipLevel END "
                + "WHERE userId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, earnedPoints);
            ps.setInt(2, earnedPoints);
            ps.setInt(3, earnedPoints);
            ps.setInt(4, customerUserId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Customer insertCustomerRecord(String fullName, String cleanPhone, String email, String address, String level) {
        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

            String username = "kh_" + cleanPhone + "_" + (System.currentTimeMillis() % 1000);
            int userId = -1;
            String sqlU = "INSERT INTO tblUser (username, password, fullName, phone, email, address, role) "
                    + "VALUES (?, '123456', ?, ?, ?, ?, 'CUSTOMER')";
            try (PreparedStatement psU = con.prepareStatement(sqlU, Statement.RETURN_GENERATED_KEYS)) {
                psU.setString(1, username);
                psU.setString(2, fullName.trim());
                psU.setString(3, cleanPhone);
                psU.setString(4, email != null ? email.trim() : "");
                psU.setString(5, address != null ? address.trim() : "");
                psU.executeUpdate();
                try (ResultSet keys = psU.getGeneratedKeys()) {
                    if (keys.next()) userId = keys.getInt(1);
                }
            }
            if (userId <= 0) {
                if (manageTransaction) con.rollback();
                return null;
            }
            String cusCode = "KH" + String.format("%03d", userId);
            String memLevel = (level != null && !level.trim().isEmpty()) ? level.trim() : "Thành viên";
            try (PreparedStatement psC = con.prepareStatement(
                    "INSERT INTO tblCustomer (userId, customerCode, membershipLevel, rewardPoints) VALUES (?, ?, ?, 0)")) {
                psC.setInt(1, userId);
                psC.setString(2, cusCode);
                psC.setString(3, memLevel);
                psC.executeUpdate();
            }
            if (manageTransaction) con.commit();

            Customer cus = new Customer();
            cus.setId(userId);
            cus.setUsername(username);
            cus.setFullName(fullName.trim());
            cus.setPhone(cleanPhone);
            cus.setEmail(email != null ? email.trim() : "");
            cus.setAddress(address != null ? address.trim() : "");
            cus.setRole("CUSTOMER");
            cus.setCustomerCode(cusCode);
            cus.setMembershipLevel(memLevel);
            cus.setRewardPoints(0);
            return cus;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (manageTransaction) con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            return null;
        } finally {
            if (manageTransaction) {
                try { con.setAutoCommit(true); } catch (Exception ex) { ex.printStackTrace(); }
            }
        }
    }

    private Customer mapCustomer(ResultSet rs) throws Exception {
        Customer c = new Customer();
        c.setId(rs.getInt("id"));
        c.setUsername(rs.getString("username"));
        c.setPassword(rs.getString("password"));
        c.setFullName(rs.getString("fullName"));
        c.setPhone(rs.getString("phone"));
        c.setEmail(rs.getString("email"));
        c.setAddress(rs.getString("address"));
        c.setRole(rs.getString("role"));
        c.setCustomerCode(rs.getString("customerCode"));
        c.setMembershipLevel(rs.getString("membershipLevel"));
        c.setRewardPoints(rs.getInt("rewardPoints"));
        return c;
    }
}
