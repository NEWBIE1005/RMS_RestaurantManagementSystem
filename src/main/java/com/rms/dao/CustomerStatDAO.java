package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.CustomerStat;

/**
 * DAO thống kê lượt đặt bàn và chi tiêu theo Khách hàng (CustomerStat).
 */
public class CustomerStatDAO extends DAO {

    public CustomerStatDAO() {
        super();
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
}
