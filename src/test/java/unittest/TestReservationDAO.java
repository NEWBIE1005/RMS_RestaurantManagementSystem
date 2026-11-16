package unittest;

import java.util.ArrayList;
import org.junit.Assert;
import org.junit.Test;
import com.rms.dao.ReservationDAO;
import com.rms.model.Reservation;

/**
 * Kiểm thử đơn vị cho lớp ReservationDAO (Module 2).
 */
public class TestReservationDAO {
    private final ReservationDAO resDAO = new ReservationDAO();

    @Test
    public void searchBookedTables_testChuan1_TimTheoSoDienThoai() {
        ArrayList<Reservation> list = resDAO.searchBookedTables("0987654321");
        Assert.assertNotNull(list);
        Assert.assertTrue(list.size() >= 2);
        for (Reservation r : list) {
            Assert.assertEquals("0987654321", r.getCustomer().getPhone());
        }
    }

    @Test
    public void searchBookedTables_testChuan2_TimTheoTenKhachHang() {
        ArrayList<Reservation> list = resDAO.searchBookedTables("Hà Anh Khôi");
        Assert.assertNotNull(list);
        Assert.assertTrue(list.size() >= 1);
        Assert.assertEquals("Hà Anh Khôi", list.get(0).getCustomer().getFullName());
    }

    @Test
    public void searchBookedTables_testNgoaiLe1_TuKhoaRongHoacKhongTonTai() {
        Assert.assertEquals(0, resDAO.searchBookedTables("").size());
        Assert.assertEquals(0, resDAO.searchBookedTables("0000000000").size());
    }

    @Test
    public void getReservationById_testChuanVaNgoaiLe() {
        Reservation res = resDAO.getReservationById(1);
        Assert.assertNotNull(res);
        Assert.assertEquals("Bàn 08", res.getTable().getTableNumber());

        Assert.assertNull(resDAO.getReservationById(9999));
    }
}
