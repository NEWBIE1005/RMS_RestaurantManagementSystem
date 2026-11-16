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
                + "AND r.status IN ('Chờ xác nhận', 'Đã xác nhận', 'Đang phục vụ') "
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
     * Tạo đơn đặt bàn trực tuyến mới (tìm khách qua CustomerDAO hoặc tạo hồ sơ mới nếu chưa có).
     */
    public Reservation createReservation(String fullName, String phone, String email,
                                         int tableId, java.util.Date bookingTime, int guests, String note) {
        return createReservationInternal(fullName, phone, email, tableId, bookingTime, guests, "Đã xác nhận", note, "Đã đặt");
    }

    /**
     * NV Bán hàng đón tiếp và mở bàn phục vụ ngay cho khách vãng lai tại quầy.
     */
    public Reservation checkInWalkInTable(String fullName, String phone, int tableId, int guests, String note) {
        return createReservationInternal(fullName, phone, "", tableId, new java.util.Date(), guests, "Đang phục vụ", note, "Đang phục vụ");
    }

    private Reservation createReservationInternal(String fullName, String phone, String email,
                                                  int tableId, java.util.Date bookingTime, int guests,
                                                  String resStatus, String note, String nextTableStatus) {
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

            CustomerDAO customerDAO = new CustomerDAO();
            Customer cus = customerDAO.findOrCreateCustomer(fullName.trim(), phone.trim(), email);
            if (cus == null) {
                if (manageTransaction) con.rollback();
                return null;
            }

            String sqlRes = "INSERT INTO tblReservation (customerId, tableId, bookingTime, numberOfGuests, status, note) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";
            int resId = -1;
            try (PreparedStatement psR = con.prepareStatement(sqlRes, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psR.setInt(1, cus.getId());
                psR.setInt(2, tableId);
                psR.setTimestamp(3, new java.sql.Timestamp(bookingTime.getTime()));
                psR.setInt(4, guests);
                psR.setString(5, resStatus);
                psR.setString(6, note != null ? note.trim() : "");
                psR.executeUpdate();
                try (ResultSet keys = psR.getGeneratedKeys()) {
                    if (keys.next()) resId = keys.getInt(1);
                }
            }
            if (resId <= 0) {
                if (manageTransaction) con.rollback();
                return null;
            }

            if ("Đang phục vụ".equals(nextTableStatus) || "Trống".equalsIgnoreCase(table.getStatus())) {
                tableDAO.updateTableStatus(tableId, nextTableStatus);
                table.setStatus(nextTableStatus);
            }

            if (manageTransaction) con.commit();

            Reservation res = new Reservation();
            res.setId(resId);
            res.setCustomer(cus);
            res.setTable(table);
            res.setBookingTime(bookingTime);
            res.setNumberOfGuests(guests);
            res.setStatus(resStatus);
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
