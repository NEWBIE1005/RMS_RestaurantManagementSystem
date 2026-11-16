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
                + "AND r.status IN ('Chờ xác nhận', 'Đã xác nhận') "
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

    /**
     * Lấy danh sách đơn đặt bàn phục vụ Nhân viên Bán hàng duyệt / theo dõi.
     */
    public ArrayList<Reservation> getAllReservations(String statusFilter) {
        ArrayList<Reservation> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT r.id AS resId, r.bookingTime, r.numberOfGuests, r.status AS resStatus, r.note, "
                + "u.id AS userId, u.fullName, u.phone, u.email, c.customerCode, c.membershipLevel, c.rewardPoints, "
                + "t.id AS tableId, t.tableNumber, t.capacity, t.floor, t.status AS tableStatus, t.description AS tableDesc "
                + "FROM tblReservation r "
                + "JOIN tblCustomer c ON r.customerId = c.userId "
                + "JOIN tblUser u ON c.userId = u.id "
                + "JOIN tblTable t ON r.tableId = t.id ");
        boolean hasFilter = statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim());
        if (hasFilter) {
            sql.append("WHERE r.status = ? ");
        }
        sql.append("ORDER BY r.bookingTime DESC, r.id DESC");
        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (hasFilter) {
                ps.setString(1, statusFilter.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapReservation(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public boolean updateReservationStatus(int reservationId, String newStatus) {
        if (reservationId <= 0 || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE tblReservation SET status = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus.trim());
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Tạo đơn đặt bàn trực tuyến mới (tìm khách theo SĐT hoặc tạo khách mới nếu chưa có).
     */
    public Reservation createReservation(String fullName, String phone, String email,
                                         int tableId, java.util.Date bookingTime, int guests, String note) {
        if (fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || tableId <= 0 || bookingTime == null || guests <= 0) {
            return null;
        }
        TableDAO tableDAO = new TableDAO();
        Table table = tableDAO.getTableById(tableId);
        if (table == null || guests > table.getCapacity() || tableDAO.isTableConflict(tableId, bookingTime)) {
            return null;
        }

        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

            String cleanPhone = phone.trim();
            int customerUserId = -1;
            String customerCode = "";
            String membershipLevel = "Thành viên";
            int rewardPoints = 0;

            String sqlFindCus = "SELECT u.id, c.customerCode, c.membershipLevel, c.rewardPoints "
                    + "FROM tblUser u JOIN tblCustomer c ON u.id = c.userId WHERE u.phone = ?";
            try (PreparedStatement psFind = con.prepareStatement(sqlFindCus)) {
                psFind.setString(1, cleanPhone);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        customerUserId = rs.getInt("id");
                        customerCode = rs.getString("customerCode");
                        membershipLevel = rs.getString("membershipLevel");
                        rewardPoints = rs.getInt("rewardPoints");
                    }
                }
            }

            if (customerUserId <= 0) {
                String guestUser = "guest_" + cleanPhone + "_" + (System.currentTimeMillis() % 10000);
                String sqlUser = "INSERT INTO tblUser (username, password, fullName, phone, email, address, role) "
                        + "VALUES (?, '123456', ?, ?, ?, '', 'CUSTOMER')";
                try (PreparedStatement psU = con.prepareStatement(sqlUser, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    psU.setString(1, guestUser);
                    psU.setString(2, fullName.trim());
                    psU.setString(3, cleanPhone);
                    psU.setString(4, email != null ? email.trim() : "");
                    psU.executeUpdate();
                    try (ResultSet keys = psU.getGeneratedKeys()) {
                        if (keys.next()) customerUserId = keys.getInt(1);
                    }
                }
                if (customerUserId <= 0) {
                    if (manageTransaction) con.rollback();
                    return null;
                }
                customerCode = "KH" + String.format("%03d", customerUserId);
                String sqlCus = "INSERT INTO tblCustomer (userId, customerCode, membershipLevel, rewardPoints) VALUES (?, ?, 'Thành viên', 0)";
                try (PreparedStatement psC = con.prepareStatement(sqlCus)) {
                    psC.setInt(1, customerUserId);
                    psC.setString(2, customerCode);
                    psC.executeUpdate();
                }
            }

            String sqlRes = "INSERT INTO tblReservation (customerId, tableId, bookingTime, numberOfGuests, status, note) "
                    + "VALUES (?, ?, ?, ?, 'Đã xác nhận', ?)";
            int resId = -1;
            try (PreparedStatement psR = con.prepareStatement(sqlRes, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psR.setInt(1, customerUserId);
                psR.setInt(2, tableId);
                psR.setTimestamp(3, new java.sql.Timestamp(bookingTime.getTime()));
                psR.setInt(4, guests);
                psR.setString(5, note != null ? note.trim() : "");
                psR.executeUpdate();
                try (ResultSet keys = psR.getGeneratedKeys()) {
                    if (keys.next()) resId = keys.getInt(1);
                }
            }
            if (resId <= 0) {
                if (manageTransaction) con.rollback();
                return null;
            }

            if (manageTransaction) con.commit();

            Customer cus = new Customer();
            cus.setId(customerUserId);
            cus.setFullName(fullName.trim());
            cus.setPhone(cleanPhone);
            cus.setEmail(email != null ? email.trim() : "");
            cus.setCustomerCode(customerCode);
            cus.setMembershipLevel(membershipLevel);
            cus.setRewardPoints(rewardPoints);

            Reservation res = new Reservation();
            res.setId(resId);
            res.setCustomer(cus);
            res.setTable(table);
            res.setBookingTime(bookingTime);
            res.setNumberOfGuests(guests);
            res.setStatus("Đã xác nhận");
            res.setNote(note != null ? note.trim() : "");
            return res;
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
