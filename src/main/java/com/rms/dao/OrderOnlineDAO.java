package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Date;
import com.rms.model.OrderOnline;
import com.rms.model.OrderedDish;

/**
 * Lớp DAO xử lý lưu trữ đơn đặt món ăn online theo giao dịch (Transaction).
 */
public class OrderOnlineDAO extends DAO {

    public OrderOnlineDAO() {
        super();
    }

    /**
     * Lưu đơn đặt món online cùng toàn bộ danh sách món đã chọn trong một Transaction.
     */
    public boolean saveOrderOnline(OrderOnline order) {
        if (order == null || order.getReservation() == null || order.getReservation().getId() <= 0
                || order.getDsMonGoi() == null || order.getDsMonGoi().isEmpty()) {
            return false;
        }

        // Kiểm tra lại đơn giá & trạng thái món trực tiếp từ CSDL để bảo đảm tính chính xác
        String sqlCheckDish = "SELECT price, status FROM tblDish WHERE id = ?";
        float total = 0f;
        for (OrderedDish item : order.getDsMonGoi()) {
            if (item == null || item.getDish() == null || item.getDish().getId() <= 0 || item.getQuantity() <= 0) {
                return false;
            }
            try (PreparedStatement psCheck = con.prepareStatement(sqlCheckDish)) {
                psCheck.setInt(1, item.getDish().getId());
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (!rsCheck.next()) {
                        return false;
                    }
                    if (!"Đang phục vụ".equalsIgnoreCase(rsCheck.getString("status"))) {
                        return false;
                    }
                    float dbPrice = rsCheck.getFloat("price");
                    item.setPrice(dbPrice);
                    total += dbPrice * item.getQuantity();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                return false;
            }
        }
        order.setTotalAmount(total);
        if (order.getOrderTime() == null) {
            order.setOrderTime(new Date());
        }
        if (order.getOrderCode() == null || order.getOrderCode().trim().isEmpty()) {
            order.setOrderCode(generateUniqueOrderCode());
        }
        if (order.getStatus() == null || order.getStatus().trim().isEmpty()) {
            order.setStatus("Chờ xác nhận");
        }

        String sqlOrder = "INSERT INTO tblOrderOnline (orderCode, reservationId, orderTime, totalAmount, status, note) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        boolean manageTransaction = false;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) {
                con.setAutoCommit(false);
            }

            int generatedOrderId = -1;
            try (PreparedStatement ps = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, order.getOrderCode());
                ps.setInt(2, order.getReservation().getId());
                ps.setTimestamp(3, new Timestamp(order.getOrderTime().getTime()));
                ps.setFloat(4, order.getTotalAmount());
                ps.setString(5, order.getStatus());
                ps.setString(6, order.getNote() != null ? order.getNote() : "");
                int affected = ps.executeUpdate();
                if (affected == 0) {
                    throw new IllegalStateException("Không thể chèn bản ghi tblOrderOnline");
                }
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        generatedOrderId = keys.getInt(1);
                    }
                }
            }
            if (generatedOrderId <= 0) {
                throw new IllegalStateException("Không lấy được ID đơn gọi món vừa tạo");
            }
            order.setId(generatedOrderId);

            OrderedDishDAO itemDAO = new OrderedDishDAO();
            for (OrderedDish item : order.getDsMonGoi()) {
                if (!itemDAO.saveOrderedDish(item, generatedOrderId)) {
                    throw new IllegalStateException("Không thể lưu món ăn: " + item.getDish().getName());
                }
            }

            if (manageTransaction) {
                con.commit();
            }
            return true;
        } catch (Exception e) {
            if (manageTransaction) {
                try {
                    con.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
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

    /**
     * Sinh mã đơn gọi món online duy nhất theo thời gian thực.
     */
    public static synchronized String generateUniqueOrderCode() {
        String ts = new java.text.SimpleDateFormat("yyMMddHHmmss").format(new java.util.Date());
        int rand = new java.util.Random().nextInt(900) + 100;
        return "ORD-" + ts + "-" + rand;
    }

    /**
     * Lấy danh sách đơn gọi món online (dùng cho Nhân viên Bán hàng & tra cứu lịch sử).
     */
    public java.util.ArrayList<OrderOnline> getOrdersByKeyword(String keyword) {
        java.util.ArrayList<OrderOnline> result = new java.util.ArrayList<>();
        String clean = keyword == null ? "" : keyword.trim();
        String sql = "SELECT o.id, o.orderCode, o.orderTime, o.totalAmount, o.status, o.note, "
                + "r.id AS resId, r.bookingTime, r.numberOfGuests, r.status AS resStatus, "
                + "t.id AS tableId, t.tableNumber, t.capacity, t.floor, "
                + "u.id AS cusId, u.fullName, u.phone "
                + "FROM tblOrderOnline o "
                + "JOIN tblReservation r ON o.reservationId = r.id "
                + "JOIN tblTable t ON r.tableId = t.id "
                + "JOIN tblCustomer c ON r.customerId = c.userId "
                + "JOIN tblUser u ON c.userId = u.id "
                + (!clean.isEmpty()
                    ? "WHERE LOWER(o.orderCode) LIKE LOWER(?) OR u.phone LIKE ? OR LOWER(u.fullName) LIKE LOWER(?) "
                    : "")
                + "ORDER BY o.orderTime DESC, o.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (!clean.isEmpty()) {
                String p = "%" + clean + "%";
                ps.setString(1, p);
                ps.setString(2, p);
                ps.setString(3, p);
            }
            OrderedDishDAO odDAO = new OrderedDishDAO();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderOnline ord = mapOrderOnline(rs);
                    ord.setDsMonGoi(odDAO.getOrderedDishesByOrderId(ord.getId()));
                    result.add(ord);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public java.util.ArrayList<OrderOnline> getAllOrders(String statusFilter) {
        java.util.ArrayList<OrderOnline> result = new java.util.ArrayList<>();
        boolean hasFilter = statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim());
        String sql = "SELECT o.id, o.orderCode, o.orderTime, o.totalAmount, o.status, o.note, "
                + "r.id AS resId, r.bookingTime, r.numberOfGuests, r.status AS resStatus, "
                + "t.id AS tableId, t.tableNumber, t.capacity, t.floor, "
                + "u.id AS cusId, u.fullName, u.phone "
                + "FROM tblOrderOnline o "
                + "JOIN tblReservation r ON o.reservationId = r.id "
                + "JOIN tblTable t ON r.tableId = t.id "
                + "JOIN tblCustomer c ON r.customerId = c.userId "
                + "JOIN tblUser u ON c.userId = u.id "
                + (hasFilter ? "WHERE o.status = ? " : "")
                + "ORDER BY o.orderTime DESC, o.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (hasFilter) {
                ps.setString(1, statusFilter.trim());
            }
            OrderedDishDAO odDAO = new OrderedDishDAO();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderOnline ord = mapOrderOnline(rs);
                    ord.setDsMonGoi(odDAO.getOrderedDishesByOrderId(ord.getId()));
                    result.add(ord);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        if (orderId <= 0 || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE tblOrderOnline SET status = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus.trim());
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private OrderOnline mapOrderOnline(ResultSet rs) throws Exception {
        com.rms.model.Customer cus = new com.rms.model.Customer();
        cus.setId(rs.getInt("cusId"));
        cus.setFullName(rs.getString("fullName"));
        cus.setPhone(rs.getString("phone"));

        com.rms.model.Table tbl = new com.rms.model.Table();
        tbl.setId(rs.getInt("tableId"));
        tbl.setTableNumber(rs.getString("tableNumber"));
        tbl.setCapacity(rs.getInt("capacity"));
        tbl.setFloor(rs.getInt("floor"));

        com.rms.model.Reservation res = new com.rms.model.Reservation();
        res.setId(rs.getInt("resId"));
        res.setBookingTime(rs.getTimestamp("bookingTime"));
        res.setNumberOfGuests(rs.getInt("numberOfGuests"));
        res.setStatus(rs.getString("resStatus"));
        res.setCustomer(cus);
        res.setTable(tbl);

        OrderOnline ord = new OrderOnline();
        ord.setId(rs.getInt("id"));
        ord.setOrderCode(rs.getString("orderCode"));
        ord.setOrderTime(rs.getTimestamp("orderTime"));
        ord.setTotalAmount(rs.getFloat("totalAmount"));
        ord.setStatus(rs.getString("status"));
        ord.setNote(rs.getString("note"));
        ord.setReservation(res);
        return ord;
    }
}
