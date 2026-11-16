package unittest;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.Date;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.rms.dao.*;
import com.rms.model.*;

/**
 * Bộ kiểm thử đơn vị JUnit 4 cho các DAO mở rộng (Dish CRUD, Table, Reservation, Combo, Stat, Warehouse, Bill).
 * Toàn bộ test case chạy trong Transaction và rollback sau mỗi lần chạy để bảo toàn dữ liệu mẫu.
 */
public class TestExtendedDAOs extends DAO {

    @BeforeClass
    public static void setupDb() throws Exception {
        DAO.initConnection();
    }

    @Before
    public void beginTx() throws Exception {
        DAO.initConnection();
        con.setAutoCommit(false);
    }

    @After
    public void rollbackTx() throws Exception {
        if (con != null && !con.isClosed()) {
            con.rollback();
            con.setAutoCommit(true);
        }
    }

    @Test
    public void testInsertAndDeactivateOrDeleteDish() {
        DishDAO dishDAO = new DishDAO();
        Category cat = new Category();
        cat.setId(1);

        Dish d = new Dish();
        d.setCode("D99");
        d.setName("Cơm Niêu Bò Sốt Tiêu UnitTest");
        d.setCategory(cat);
        d.setPrice(145000f);
        d.setUnit("Phần");
        d.setStatus("Đang phục vụ");
        d.setDescription("Món thử nghiệm JUnit");

        assertTrue("Thêm món mới D99 phải thành công", dishDAO.insertDish(d));
        assertTrue(d.getId() > 0);
        assertTrue("Kiểm tra trùng mã D99", dishDAO.checkDuplicateCode("D99"));
        assertEquals("DELETED", dishDAO.deleteOrDeactivateDish(d.getId()));
        assertNull(dishDAO.getDishById(d.getId()));
    }

    @Test
    public void testCreateReservationAndConflictDetection() {
        ReservationDAO resDAO = new ReservationDAO();
        TableDAO tableDAO = new TableDAO();
        Date bookingTime = new Date(System.currentTimeMillis() + 5L * 3600 * 1000);

        Reservation created = resDAO.createReservation("Nguyễn Kiểm Thử", "0909123456", "kt@test.com",
                1, bookingTime, 4, "Bàn gần cửa sổ");
        assertNotNull("Đặt bàn trống Bàn 01 (4 chỗ) cho 4 khách phải thành công", created);
        assertTrue("Phát hiện trùng khung giờ +-2 tiếng", tableDAO.isTableConflict(1, bookingTime));

        Reservation duplicate = resDAO.createReservation("Khách Khác", "0909999888", "", 1, bookingTime, 2, "");
        assertNull("Không cho đặt trùng cùng bàn trong khung giờ +-2 tiếng", duplicate);
    }

    @Test
    public void testCreateComboCalculatesDiscountedTotal() {
        ComboDAO comboDAO = new ComboDAO();
        DishDAO dishDAO = new DishDAO();
        Dish d1 = dishDAO.getDishById(1);
        Dish d2 = dishDAO.getDishById(3);
        assertNotNull(d1);
        assertNotNull(d2);

        Combo c = new Combo();
        c.setName("Combo JUnit Tiết Kiệm");
        c.setDiscountRate(20f);
        c.setDescription("Giảm 20%");

        ComboDish cd1 = new ComboDish(); cd1.setDish(d1); cd1.setQuantity(1);
        ComboDish cd2 = new ComboDish(); cd2.setDish(d2); cd2.setQuantity(2);
        c.setDsComboDish(new ArrayList<>());
        c.getDsComboDish().add(cd1);
        c.getDsComboDish().add(cd2);

        assertTrue("Tạo Combo phải thành công", comboDAO.createCombo(c));
        float expected = Math.round((d1.getPrice() + 2 * d2.getPrice()) * 0.8f);
        assertEquals(expected, c.getTotalPrice(), 1.0f);
        assertTrue("Xóa Combo vừa tạo", comboDAO.deleteCombo(c.getId()));
    }

    @Test
    public void testWarehouseImportReceiptUpdatesStock() {
        WarehouseDAO whDAO = new WarehouseDAO();
        ArrayList<Ingredient> beforeList = whDAO.getAllIngredients();
        assertFalse(beforeList.isEmpty());
        Ingredient target = beforeList.get(0);
        float oldStock = target.getStockQuantity();

        ImportReceipt rec = new ImportReceipt();
        rec.setReceiptCode("PN-TEST-001");
        Supplier sup = new Supplier(); sup.setId(1);
        Staff st = new Staff(); st.setId(3);
        rec.setSupplier(sup);
        rec.setStaff(st);

        ImportDetail det = new ImportDetail();
        det.setIngredient(target);
        det.setQuantity(12.5f);
        det.setImportPrice(200000f);
        rec.getDsChiTiet().add(det);

        assertTrue("Lưu phiếu nhập kho phải thành công", whDAO.createImportReceipt(rec));
        assertEquals(2500000f, rec.getTotalAmount(), 1.0f);

        ArrayList<Ingredient> afterList = whDAO.getAllIngredients();
        assertEquals(oldStock + 12.5f, afterList.get(0).getStockQuantity(), 0.01f);
    }

    @Test
    public void testStatQueriesExecuteCleanly() {
        StatDAO statDAO = new StatDAO();
        assertFalse(statDAO.getDishStatistics().isEmpty());
        assertFalse(statDAO.getIngredientStatistics().isEmpty());
        assertFalse(statDAO.getCustomerStatistics().isEmpty());
        assertFalse(statDAO.getSupplierStatistics().isEmpty());
    }

    @Test
    public void testBillPaymentUpdatesOrderAndPoints() {
        OrderOnlineDAO ordDAO = new OrderOnlineDAO();
        BillDAO billDAO = new BillDAO();
        Reservation res = new Reservation(); res.setId(1);
        Dish d = new DishDAO().getDishById(1);

        OrderedDish item = new OrderedDish();
        item.setDish(d);
        item.setQuantity(2);
        item.setPrice(d.getPrice());

        OrderOnline ord = new OrderOnline();
        ord.setOrderCode("ORD-TEST-BILL-1");
        ord.setReservation(res);
        ord.setDsMonGoi(new ArrayList<>());
        ord.getDsMonGoi().add(item);

        assertTrue(ordDAO.saveOrderOnline(ord));
        Bill bill = billDAO.createPaymentBill(ord.getId(), 2, 10000f, "Chuyển khoản");
        assertNotNull("Lập hóa đơn thanh toán thành công", bill);
        assertEquals(d.getPrice() * 2f - 10000f, bill.getFinalAmount(), 1.0f);
    }
}
