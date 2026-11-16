package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import com.rms.model.Bill;
import com.rms.model.Customer;
import com.rms.model.OrderOnline;
import com.rms.model.Reservation;
import com.rms.model.Staff;
import com.rms.model.Table;

/**
 * DAO xử lý thanh toán hóa đơn tại bàn và tích điểm khách hàng (tblBill).
 */
public class BillDAO extends DAO {

    public BillDAO() {
        super();
    }

    public Bill createPaymentBill(int orderId, int staffUserId, float discount, String paymentMethod) {
        if (orderId <= 0 || staffUserId <= 0 || discount < 0) {
            return null;
        }
        boolean manageTransaction = true;
        try {
            manageTransaction = con.getAutoCommit();
            if (manageTransaction) con.setAutoCommit(false);

            String sqlOrder = "SELECT o.id, o.orderCode, o.totalAmount, o.status, o.reservationId, "
                    + "r.customerId, r.tableId "
                    + "FROM tblOrderOnline o "
                    + "JOIN tblReservation r ON o.reservationId = r.id "
                    + "WHERE o.id = ?";
            float totalAmount;
            String orderCode;
            String orderStatus;
            int reservationId;
            int customerId;
            try (PreparedStatement psO = con.prepareStatement(sqlOrder)) {
                psO.setInt(1, orderId);
                try (ResultSet rs = psO.executeQuery()) {
                    if (!rs.next()) {
                        if (manageTransaction) con.rollback();
                        return null;
                    }
                    orderCode = rs.getString("orderCode");
                    totalAmount = rs.getFloat("totalAmount");
                    orderStatus = rs.getString("status");
                    reservationId = rs.getInt("reservationId");
                    customerId = rs.getInt("customerId");
                }
            }

            if ("Đã thanh toán".equalsIgnoreCase(orderStatus) || "Đã hủy".equalsIgnoreCase(orderStatus)) {
                if (manageTransaction) con.rollback();
                return null;
            }

            float finalAmount = Math.max(0f, totalAmount - discount);
            String billCode = "HD-" + new SimpleDateFormat("yyMMddHHmmss").format(new Date()) + "-" + orderId;
            Timestamp now = new Timestamp(System.currentTimeMillis());

            String sqlBill = "INSERT INTO tblBill (billCode, orderId, staffId, paymentTime, totalAmount, discount, finalAmount, paymentMethod) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            int billId = -1;
            try (PreparedStatement psB = con.prepareStatement(sqlBill, Statement.RETURN_GENERATED_KEYS)) {
                psB.setString(1, billCode);
                psB.setInt(2, orderId);
                psB.setInt(3, staffUserId);
                psB.setTimestamp(4, now);
                psB.setFloat(5, totalAmount);
                psB.setFloat(6, discount);
                psB.setFloat(7, finalAmount);
                psB.setString(8, (paymentMethod != null && !paymentMethod.trim().isEmpty()) ? paymentMethod.trim() : "Tiền mặt");
                psB.executeUpdate();
                try (ResultSet keys = psB.getGeneratedKeys()) {
                    if (keys.next()) billId = keys.getInt(1);
                }
            }
            if (billId <= 0) {
                if (manageTransaction) con.rollback();
                return null;
            }

            try (PreparedStatement psUpO = con.prepareStatement("UPDATE tblOrderOnline SET status = 'Đã thanh toán' WHERE id = ?");
                 PreparedStatement psUpR = con.prepareStatement("UPDATE tblReservation SET status = 'Hoàn thành' WHERE id = ?")) {
                psUpO.setInt(1, orderId);
                psUpO.executeUpdate();
                psUpR.setInt(1, reservationId);
                psUpR.executeUpdate();
            }

            int earnedPoints = (int) (finalAmount / 10000f);
            if (earnedPoints > 0) {
                try (PreparedStatement psPts = con.prepareStatement(
                        "UPDATE tblCustomer SET rewardPoints = rewardPoints + ?, "
                        + "membershipLevel = CASE "
                        + "  WHEN rewardPoints + ? >= 1500 THEN 'Vàng' "
                        + "  WHEN rewardPoints + ? >= 500 THEN 'Bạc' "
                        + "  ELSE membershipLevel END "
                        + "WHERE userId = ?")) {
                    psPts.setInt(1, earnedPoints);
                    psPts.setInt(2, earnedPoints);
                    psPts.setInt(3, earnedPoints);
                    psPts.setInt(4, customerId);
                    psPts.executeUpdate();
                }
            }

            if (manageTransaction) con.commit();

            Bill bill = new Bill();
            bill.setId(billId);
            bill.setBillCode(billCode);
            OrderOnline ord = new OrderOnline();
            ord.setId(orderId);
            ord.setOrderCode(orderCode);
            bill.setOrderOnline(ord);
            Staff staff = new Staff();
            staff.setId(staffUserId);
            bill.setStaff(staff);
            bill.setPaymentTime(now);
            bill.setTotalAmount(totalAmount);
            bill.setDiscount(discount);
            bill.setFinalAmount(finalAmount);
            bill.setPaymentMethod(paymentMethod);
            return bill;
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

    public ArrayList<Bill> getRecentBills() {
        ArrayList<Bill> list = new ArrayList<>();
        String sql = "SELECT b.id, b.billCode, b.paymentTime, b.totalAmount, b.discount, b.finalAmount, b.paymentMethod, "
                + "o.orderCode, t.tableNumber, cu.fullName AS customerName, su.fullName AS staffName "
                + "FROM tblBill b "
                + "JOIN tblOrderOnline o ON b.orderId = o.id "
                + "JOIN tblReservation r ON o.reservationId = r.id "
                + "JOIN tblTable t ON r.tableId = t.id "
                + "JOIN tblUser cu ON r.customerId = cu.id "
                + "JOIN tblUser su ON b.staffId = su.id "
                + "ORDER BY b.paymentTime DESC, b.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Bill b = new Bill();
                b.setId(rs.getInt("id"));
                b.setBillCode(rs.getString("billCode"));
                b.setPaymentTime(rs.getTimestamp("paymentTime"));
                b.setTotalAmount(rs.getFloat("totalAmount"));
                b.setDiscount(rs.getFloat("discount"));
                b.setFinalAmount(rs.getFloat("finalAmount"));
                b.setPaymentMethod(rs.getString("paymentMethod"));

                Customer cu = new Customer();
                cu.setFullName(rs.getString("customerName"));
                Table tbl = new Table();
                tbl.setTableNumber(rs.getString("tableNumber"));
                Reservation res = new Reservation();
                res.setCustomer(cu);
                res.setTable(tbl);
                OrderOnline o = new OrderOnline();
                o.setOrderCode(rs.getString("orderCode"));
                o.setReservation(res);
                b.setOrderOnline(o);

                Staff st = new Staff();
                st.setFullName(rs.getString("staffName"));
                b.setStaff(st);
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
