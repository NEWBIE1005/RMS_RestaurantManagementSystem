package unittest;

import java.util.ArrayList;
import org.junit.Assert;
import org.junit.Test;
import com.rms.dao.DAO;
import com.rms.dao.DishDAO;
import com.rms.model.Category;
import com.rms.model.Dish;

/**
 * Kiểm thử đơn vị cho lớp DishDAO (Module 1 & Module 2).
 */
public class TestDishDAO {
    private final DishDAO dishDAO = new DishDAO();

    @Test
    public void searchDishByName_testChuan1_TimThayNhieuMon() {
        ArrayList<Dish> list = dishDAO.searchDishByName("Lẩu");
        Assert.assertNotNull(list);
        Assert.assertTrue(list.size() >= 2);
        for (Dish d : list) {
            Assert.assertTrue(d.getName().toLowerCase().contains("lẩu"));
        }
    }

    @Test
    public void searchDishByName_testNgoaiLe1_KhongTimThay() {
        ArrayList<Dish> list = dishDAO.searchDishByName("MonKhongTonTaiXYZ");
        Assert.assertNotNull(list);
        Assert.assertEquals(0, list.size());
    }

    @Test
    public void searchDish_testChuan2_TheoTenVaTheLoai() {
        ArrayList<Dish> list = dishDAO.searchDish("Bò", 2);
        Assert.assertNotNull(list);
        Assert.assertTrue(list.size() >= 1);
        for (Dish d : list) {
            Assert.assertEquals(2, d.getCategory().getId());
        }
    }

    @Test
    public void getDishById_testChuan1_TonTai() {
        Dish d = dishDAO.getDishById(1);
        Assert.assertNotNull(d);
        Assert.assertEquals("D01", d.getCode());
    }

    @Test
    public void getDishById_testNgoaiLe1_KhongTonTai() {
        Dish d = dishDAO.getDishById(9999);
        Assert.assertNull(d);
    }

    @Test
    public void updateDish_testChuan1_CapNhatThanhCongVaRollback() {
        try {
            DAO.con.setAutoCommit(false);
            Dish original = dishDAO.getDishById(1);
            Assert.assertNotNull(original);

            Dish edited = new Dish();
            edited.setId(original.getId());
            edited.setName("Lẩu Thái Hải Sản Đặc Biệt");
            edited.setPrice(420000f);
            edited.setUnit("Nồi VIP");
            edited.setDescription("Cập nhật từ unit test");
            edited.setStatus("Đang phục vụ");
            Category c = new Category();
            c.setId(1);
            edited.setCategory(c);

            boolean ok = dishDAO.updateDish(edited);
            Assert.assertTrue(ok);

            Dish fetched = dishDAO.getDishById(1);
            Assert.assertNotNull(fetched);
            Assert.assertEquals("Lẩu Thái Hải Sản Đặc Biệt", fetched.getName());
            Assert.assertEquals(420000f, fetched.getPrice(), 0.01f);
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
    public void updateDish_testNgoaiLe1_GiaAmHoacTenRong() {
        Dish invalid1 = new Dish();
        invalid1.setId(1);
        invalid1.setName("");
        invalid1.setPrice(100000f);
        Category c = new Category();
        c.setId(1);
        invalid1.setCategory(c);
        Assert.assertFalse(dishDAO.updateDish(invalid1));

        Dish invalid2 = new Dish();
        invalid2.setId(1);
        invalid2.setName("Món hợp lệ");
        invalid2.setPrice(-5000f);
        invalid2.setCategory(c);
        Assert.assertFalse(dishDAO.updateDish(invalid2));
    }
}
