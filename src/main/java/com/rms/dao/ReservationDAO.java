package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Customer;
import com.rms.model.Reservation;
import com.rms.model.Table;

/**
 * Lớp DAO tìm kiếm và lấy thông tin bàn đặt trước của khách hàng (tblReservation).
 */
public class ReservationDAO extends DAO {

    public ReservationDAO() {
        super();
    }

    /**
     * Tìm kiếm bàn đã đặt theo Tên khách hàng hoặc Số điện thoại.
     */
    public ArrayList<Reservation> searchBookedTables(String keyword) {
        ArrayList<Reservation> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) {
            return list;
        }
        String kw = "%" + keyword.trim() + "%";
        String sql = "SELECT r.id AS resId, r.bookingTime, r.numberOfGuests, r.status AS resStatus, r.note, "
                + "u.id AS userId, u.fullName, u.phone, u.email, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints, "
                + "t.id AS tableId, t.tableNumber, t.capacity, t.floor, t.status AS tableStatus, t.description AS tableDesc "
                + "FROM tblReservation r "
                + "JOIN tblCustomer c ON r.customerId = c.userId "
                + "JOIN tblUser u ON c.userId = u.id "
                + "JOIN tblTable t ON r.tableId = t.id "
                + "WHERE (LOWER(u.fullName) LIKE LOWER(?) OR u.phone LIKE ?) "
                + "AND r.status <> 'Đã hủy' "
                + "ORDER BY r.bookingTime ASC";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, kw);
            ps.setString(2, kw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservation(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết đơn đặt bàn theo ID.
     */
    public Reservation getReservationById(int id) {
        String sql = "SELECT r.id AS resId, r.bookingTime, r.numberOfGuests, r.status AS resStatus, r.note, "
                + "u.id AS userId, u.fullName, u.phone, u.email, "
                + "c.customerCode, c.membershipLevel, c.rewardPoints, "
                + "t.id AS tableId, t.tableNumber, t.capacity, t.floor, t.status AS tableStatus, t.description AS tableDesc "
                + "FROM tblReservation r "
                + "JOIN tblCustomer c ON r.customerId = c.userId "
                + "JOIN tblUser u ON c.userId = u.id "
                + "JOIN tblTable t ON r.tableId = t.id "
                + "WHERE r.id = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapReservation(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Reservation mapReservation(ResultSet rs) throws Exception {
        Customer cus = new Customer();
        cus.setId(rs.getInt("userId"));
        cus.setFullName(rs.getString("fullName"));
        cus.setPhone(rs.getString("phone"));
        cus.setEmail(rs.getString("email"));
        cus.setCustomerCode(rs.getString("customerCode"));
        cus.setMembershipLevel(rs.getString("membershipLevel"));
        cus.setRewardPoints(rs.getInt("rewardPoints"));

        Table tbl = new Table();
        tbl.setId(rs.getInt("tableId"));
        tbl.setTableNumber(rs.getString("tableNumber"));
        tbl.setCapacity(rs.getInt("capacity"));
        tbl.setFloor(rs.getInt("floor"));
        tbl.setStatus(rs.getString("tableStatus"));
        tbl.setDescription(rs.getString("tableDesc"));

        Reservation res = new Reservation();
        res.setId(rs.getInt("resId"));
        res.setBookingTime(rs.getTimestamp("bookingTime"));
        res.setNumberOfGuests(rs.getInt("numberOfGuests"));
        res.setStatus(rs.getString("resStatus"));
        res.setNote(rs.getString("note"));
        res.setCustomer(cus);
        res.setTable(tbl);
        return res;
    }
}
