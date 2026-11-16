package com.rms.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import com.rms.model.Table;

/**
 * DAO thao tác dữ liệu bàn ăn trong nhà hàng (tblTable).
 */
public class TableDAO extends DAO {

    public TableDAO() {
        super();
    }

    public ArrayList<Table> getAllTables() {
        ArrayList<Table> result = new ArrayList<>();
        String sql = "SELECT id, tableNumber, capacity, floor, status, description FROM tblTable ORDER BY floor ASC, capacity ASC, id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(mapTable(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public ArrayList<Table> getAvailableTables(int minCapacity, Date bookingTime) {
        ArrayList<Table> result = new ArrayList<>();
        String sql = "SELECT t.id, t.tableNumber, t.capacity, t.floor, t.status, t.description "
                + "FROM tblTable t "
                + "WHERE t.capacity >= ? AND t.status <> 'Bảo trì' "
                + (bookingTime != null
                    ? "AND NOT EXISTS (SELECT 1 FROM tblReservation r WHERE r.tableId = t.id "
                      + "AND r.status IN ('Chờ xác nhận', 'Đã xác nhận') "
                      + "AND r.bookingTime BETWEEN ? AND ?) "
                    : "")
                + "ORDER BY t.capacity ASC, t.floor ASC, t.id ASC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, minCapacity));
            if (bookingTime != null) {
                long twoHoursMs = 2L * 60 * 60 * 1000;
                ps.setTimestamp(2, new Timestamp(bookingTime.getTime() - twoHoursMs));
                ps.setTimestamp(3, new Timestamp(bookingTime.getTime() + twoHoursMs));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapTable(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public Table getTableById(int id) {
        String sql = "SELECT id, tableNumber, capacity, floor, status, description FROM tblTable WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTable(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isTableConflict(int tableId, Date bookingTime) {
        if (bookingTime == null) return false;
        String sql = "SELECT COUNT(*) FROM tblReservation WHERE tableId = ? "
                + "AND status IN ('Chờ xác nhận', 'Đã xác nhận') "
                + "AND bookingTime BETWEEN ? AND ?";
        long twoHoursMs = 2L * 60 * 60 * 1000;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tableId);
            ps.setTimestamp(2, new Timestamp(bookingTime.getTime() - twoHoursMs));
            ps.setTimestamp(3, new Timestamp(bookingTime.getTime() + twoHoursMs));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    public boolean updateTableStatus(int tableId, String status) {
        String sql = "UPDATE tblTable SET status = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, tableId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Table mapTable(ResultSet rs) throws Exception {
        Table t = new Table();
        t.setId(rs.getInt("id"));
        t.setTableNumber(rs.getString("tableNumber"));
        t.setCapacity(rs.getInt("capacity"));
        t.setFloor(rs.getInt("floor"));
        t.setStatus(rs.getString("status"));
        t.setDescription(rs.getString("description"));
        return t;
    }
}
