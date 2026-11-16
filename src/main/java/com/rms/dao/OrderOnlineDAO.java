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

        float total = 0f;
        for (OrderedDish item : order.getDsMonGoi()) {
            if (item == null || item.getDish() == null || item.getQuantity() <= 0) {
                return false;
            }
            total += item.getPrice() * item.getQuantity();
        }
        order.setTotalAmount(total);
        if (order.getOrderTime() == null) {
            order.setOrderTime(new Date());
        }
        if (order.getOrderCode() == null || order.getOrderCode().trim().isEmpty()) {
            order.setOrderCode("ORD-" + System.currentTimeMillis());
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
}
