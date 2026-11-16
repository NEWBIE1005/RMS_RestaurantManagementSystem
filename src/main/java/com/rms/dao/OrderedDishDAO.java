package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import com.rms.model.Dish;
import com.rms.model.OrderedDish;

/**
 * Lớp DAO lưu và truy xuất chi tiết món ăn đã gọi trong đơn online (tblOrderedDish).
 */
public class OrderedDishDAO extends DAO {

    public OrderedDishDAO() {
        super();
    }

    /**
     * Lưu một món ăn được gọi vào CSDL gắn với mã đơn orderId.
     */
    public boolean saveOrderedDish(OrderedDish item, int orderId) {
        if (item == null || item.getDish() == null || item.getDish().getId() <= 0
                || item.getQuantity() <= 0 || orderId <= 0) {
            return false;
        }
        String sql = "INSERT INTO tblOrderedDish (orderId, dishId, quantity, price, note) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, item.getDish().getId());
            ps.setInt(3, item.getQuantity());
            ps.setFloat(4, item.getPrice());
            ps.setString(5, item.getNote() != null ? item.getNote() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách chi tiết món ăn đã gọi của một đơn hàng.
     */
    public ArrayList<OrderedDish> getOrderedDishesByOrderId(int orderId) {
        ArrayList<OrderedDish> list = new ArrayList<>();
        String sql = "SELECT od.id, od.quantity, od.price, od.note, "
                + "d.id AS dishId, d.code, d.name, d.unit "
                + "FROM tblOrderedDish od JOIN tblDish d ON od.dishId = d.id "
                + "WHERE od.orderId = ? ORDER BY od.id";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Dish d = new Dish();
                    d.setId(rs.getInt("dishId"));
                    d.setCode(rs.getString("code"));
                    d.setName(rs.getString("name"));
                    d.setUnit(rs.getString("unit"));

                    OrderedDish item = new OrderedDish();
                    item.setId(rs.getInt("id"));
                    item.setDish(d);
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPrice(rs.getFloat("price"));
                    item.setNote(rs.getString("note"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
