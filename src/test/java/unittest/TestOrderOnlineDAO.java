package unittest;

import java.util.ArrayList;
import java.util.Date;
import org.junit.Assert;
import org.junit.Test;
import com.rms.dao.DAO;
import com.rms.dao.DishDAO;
import com.rms.dao.OrderOnlineDAO;
import com.rms.dao.OrderedDishDAO;
import com.rms.dao.ReservationDAO;
import com.rms.model.Dish;
import com.rms.model.OrderOnline;
import com.rms.model.OrderedDish;
import com.rms.model.Reservation;

/**
 * Kiểm thử đơn vị cho lớp OrderOnlineDAO và OrderedDishDAO (Module 2).
 */
public class TestOrderOnlineDAO {
    private final OrderOnlineDAO orderDAO = new OrderOnlineDAO();
    private final OrderedDishDAO itemDAO = new OrderedDishDAO();
    private final ReservationDAO resDAO = new ReservationDAO();
    private final DishDAO dishDAO = new DishDAO();

    @Test
    public void saveOrderOnline_testChuan1_NhieuMonThanhCong() {
        try {
            DAO.con.setAutoCommit(false);

            Reservation res = resDAO.getReservationById(1);
            Dish d1 = dishDAO.getDishById(1);
            Dish d2 = dishDAO.getDishById(3);
            Assert.assertNotNull(res);
            Assert.assertNotNull(d1);
            Assert.assertNotNull(d2);

            ArrayList<OrderedDish> items = new ArrayList<>();
            OrderedDish od1 = new OrderedDish();
            od1.setDish(d1);
            od1.setQuantity(1);
            od1.setPrice(d1.getPrice());
            items.add(od1);

            OrderedDish od2 = new OrderedDish();
            od2.setDish(d2);
            od2.setQuantity(2);
            od2.setPrice(d2.getPrice());
            items.add(od2);

            OrderOnline order = new OrderOnline();
            order.setOrderCode("ORD-TEST-001");
            order.setReservation(res);
            order.setOrderTime(new Date());
            order.setStatus("Chờ xác nhận");
            order.setNote("Test unit");
            order.setDsMonGoi(items);

            boolean ok = orderDAO.saveOrderOnline(order);
            Assert.assertTrue(ok);
            Assert.assertTrue(order.getId() > 0);
            Assert.assertEquals(d1.getPrice() + 2 * d2.getPrice(), order.getTotalAmount(), 0.01f);

            ArrayList<OrderedDish> savedItems = itemDAO.getOrderedDishesByOrderId(order.getId());
            Assert.assertEquals(2, savedItems.size());
        } catch (Exception e) {
            Assert.fail(e.getMessage());
        } finally {
            try {
                DAO.con.rollback();
                DAO.con.setAutoCommit(true);
            } catch (Exception ignored) {}
        }
    }

    @Test
    public void saveOrderOnline_testNgoaiLe1_DonTrongHoacThieuBanDat() {
        OrderOnline emptyOrder = new OrderOnline();
        emptyOrder.setReservation(resDAO.getReservationById(1));
        Assert.assertFalse(orderDAO.saveOrderOnline(emptyOrder));

        Assert.assertFalse(orderDAO.saveOrderOnline(null));
    }
}
