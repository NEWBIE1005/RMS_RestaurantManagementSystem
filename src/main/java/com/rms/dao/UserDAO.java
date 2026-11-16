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
}
