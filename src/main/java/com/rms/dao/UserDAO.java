package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.rms.model.Customer;
import com.rms.model.Staff;
import com.rms.model.User;

/**
 * Lớp DAO xác thực đăng nhập người dùng (Staff / Customer).
 */
public class UserDAO extends DAO {

    public UserDAO() {
        super();
    }

    public User checkLogin(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        String sql = "SELECT u.*, s.staffCode, s.position, s.salary, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints "
                + "FROM tblUser u "
                + "LEFT JOIN tblStaff s ON u.id = s.userId "
                + "LEFT JOIN tblCustomer c ON u.id = c.userId "
                + "WHERE u.username = ? AND u.password = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    if ("CUSTOMER".equalsIgnoreCase(role)) {
                        Customer cus = new Customer();
                        fillBaseUser(cus, rs);
                        cus.setCustomerCode(rs.getString("customerCode"));
                        cus.setMembershipLevel(rs.getString("membershipLevel"));
                        cus.setRewardPoints(rs.getInt("rewardPoints"));
                        return cus;
                    } else {
                        Staff st = new Staff();
                        fillBaseUser(st, rs);
                        st.setStaffCode(rs.getString("staffCode"));
                        st.setPosition(rs.getString("position"));
                        st.setSalary(rs.getFloat("salary"));
                        return st;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private void fillBaseUser(User u, ResultSet rs) throws Exception {
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("fullName"));
        u.setPhone(rs.getString("phone"));
        u.setEmail(rs.getString("email"));
        u.setAddress(rs.getString("address"));
        u.setRole(rs.getString("role"));
    }

    /**
     * Lấy danh sách khách hàng thành viên (phục vụ Nhân viên Bán hàng quản lý thẻ thành viên).
     */
    public java.util.ArrayList<Customer> getAllCustomers() {
        java.util.ArrayList<Customer> list = new java.util.ArrayList<>();
        String sql = "SELECT u.id, u.username, u.password, u.fullName, u.phone, u.email, u.address, u.role, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints "
                + "FROM tblCustomer c JOIN tblUser u ON c.userId = u.id "
                + "ORDER BY c.rewardPoints DESC, u.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Customer c = new Customer();
                fillBaseUser(c, rs);
                c.setCustomerCode(rs.getString("customerCode"));
                c.setMembershipLevel(rs.getString("membershipLevel"));
                c.setRewardPoints(rs.getInt("rewardPoints"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đăng ký / tạo thẻ thành viên cho khách hàng mới.
     */
    public Customer createMembershipCustomer(String fullName, String phone, String email, String address, String level) {
        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            return null;
        }
        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

            String cleanPhone = phone.trim();
            try (PreparedStatement psDup = con.prepareStatement("SELECT id FROM tblUser WHERE phone = ?")) {
                psDup.setString(1, cleanPhone);
                try (ResultSet rs = psDup.executeQuery()) {
                    if (rs.next()) {
                        if (manageTransaction) con.rollback();
                        return null;
                    }
                }
            }

            String username = "kh_" + cleanPhone;
            int userId = -1;
            String sqlU = "INSERT INTO tblUser (username, password, fullName, phone, email, address, role) "
                    + "VALUES (?, '123456', ?, ?, ?, ?, 'CUSTOMER')";
            try (PreparedStatement psU = con.prepareStatement(sqlU, java.sql.Statement.RETURN_GENERATED_KEYS)) {
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
            try {
                if (manageTransaction) con.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return null;
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
