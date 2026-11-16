package com.rms.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Lớp cơ sở quản lý kết nối JDBC dùng chung cho toàn bộ các lớp DAO.
 * Hỗ trợ kết nối MySQL Server 8.0 và chế độ nhúng H2 (MODE=MySQL) để chạy độc lập.
 */
public class DAO {
    public static Connection con;

    public DAO() {
        initConnection();
    }

    public static synchronized void initConnection() {
        try {
            if (con != null && !con.isClosed()) {
                return;
            }
            String mode = System.getProperty("rms.db.mode",
                    System.getenv().getOrDefault("RMS_DB_MODE", "h2"));

            if ("mysql".equalsIgnoreCase(mode)) {
                String dbUrl = System.getProperty("rms.db.url",
                        "jdbc:mysql://localhost:3306/rms_db?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8");
                String dbUser = System.getProperty("rms.db.user", "root");
                String dbPass = System.getProperty("rms.db.pass", "123456");
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            } else {
                String dbUrl = System.getProperty("rms.db.url",
                        "jdbc:h2:mem:rms_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
                Class.forName("org.h2.Driver");
                con = DriverManager.getConnection(dbUrl, "sa", "");
                initEmbeddedSchemaAndSeed(con);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void initEmbeddedSchemaAndSeed(Connection conn) throws Exception {
        try (Statement st = conn.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS tblUser ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "username VARCHAR(50) NOT NULL UNIQUE,"
                    + "password VARCHAR(255) NOT NULL,"
                    + "fullName VARCHAR(100) NOT NULL,"
                    + "phone VARCHAR(20) NOT NULL,"
                    + "email VARCHAR(100),"
                    + "address VARCHAR(255),"
                    + "role VARCHAR(30) NOT NULL)");

            st.execute("CREATE TABLE IF NOT EXISTS tblStaff ("
                    + "userId INT PRIMARY KEY,"
                    + "staffCode VARCHAR(20) NOT NULL UNIQUE,"
                    + "position VARCHAR(50) NOT NULL,"
                    + "salary DECIMAL(12,2) DEFAULT 0,"
                    + "FOREIGN KEY (userId) REFERENCES tblUser(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblCustomer ("
                    + "userId INT PRIMARY KEY,"
                    + "customerCode VARCHAR(20) NOT NULL UNIQUE,"
                    + "membershipLevel VARCHAR(30) DEFAULT 'Standard',"
                    + "rewardPoints INT DEFAULT 0,"
                    + "FOREIGN KEY (userId) REFERENCES tblUser(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblCategory ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "code VARCHAR(20) NOT NULL UNIQUE,"
                    + "name VARCHAR(100) NOT NULL,"
                    + "description TEXT)");

            st.execute("CREATE TABLE IF NOT EXISTS tblDish ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "categoryId INT NOT NULL,"
                    + "code VARCHAR(20) NOT NULL UNIQUE,"
                    + "name VARCHAR(150) NOT NULL,"
                    + "price DECIMAL(12,2) NOT NULL,"
                    + "unit VARCHAR(30) NOT NULL,"
                    + "description TEXT,"
                    + "status VARCHAR(30) NOT NULL DEFAULT 'Đang phục vụ',"
                    + "image VARCHAR(255),"
                    + "FOREIGN KEY (categoryId) REFERENCES tblCategory(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblCombo ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "name VARCHAR(150) NOT NULL,"
                    + "discountRate FLOAT DEFAULT 0,"
                    + "totalPrice DECIMAL(12,2) NOT NULL,"
                    + "description TEXT)");

            st.execute("CREATE TABLE IF NOT EXISTS tblComboDish ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "comboId INT NOT NULL,"
                    + "dishId INT NOT NULL,"
                    + "quantity INT NOT NULL DEFAULT 1,"
                    + "FOREIGN KEY (comboId) REFERENCES tblCombo(id),"
                    + "FOREIGN KEY (dishId) REFERENCES tblDish(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblTable ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "tableNumber VARCHAR(20) NOT NULL UNIQUE,"
                    + "capacity INT NOT NULL,"
                    + "floor INT NOT NULL DEFAULT 1,"
                    + "status VARCHAR(30) NOT NULL DEFAULT 'Trống',"
                    + "description VARCHAR(255))");

            st.execute("CREATE TABLE IF NOT EXISTS tblReservation ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "customerId INT NOT NULL,"
                    + "tableId INT NOT NULL,"
                    + "bookingTime DATETIME NOT NULL,"
                    + "numberOfGuests INT NOT NULL,"
                    + "status VARCHAR(30) NOT NULL DEFAULT 'Đã xác nhận',"
                    + "note TEXT,"
                    + "FOREIGN KEY (customerId) REFERENCES tblCustomer(userId),"
                    + "FOREIGN KEY (tableId) REFERENCES tblTable(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblOrderOnline ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "orderCode VARCHAR(30) NOT NULL UNIQUE,"
                    + "reservationId INT NOT NULL,"
                    + "orderTime DATETIME NOT NULL,"
                    + "totalAmount DECIMAL(12,2) NOT NULL,"
                    + "status VARCHAR(30) NOT NULL DEFAULT 'Chờ xác nhận',"
                    + "note TEXT,"
                    + "FOREIGN KEY (reservationId) REFERENCES tblReservation(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblOrderedDish ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "orderId INT NOT NULL,"
                    + "dishId INT NOT NULL,"
                    + "quantity INT NOT NULL,"
                    + "price DECIMAL(12,2) NOT NULL,"
                    + "note VARCHAR(255),"
                    + "FOREIGN KEY (orderId) REFERENCES tblOrderOnline(id),"
                    + "FOREIGN KEY (dishId) REFERENCES tblDish(id))");

            st.execute("CREATE TABLE IF NOT EXISTS tblBill ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "billCode VARCHAR(30) NOT NULL UNIQUE,"
                    + "orderId INT NOT NULL,"
                    + "staffId INT NOT NULL,"
                    + "paymentTime DATETIME NOT NULL,"
                    + "totalAmount DECIMAL(12,2) NOT NULL,"
                    + "discount DECIMAL(12,2) DEFAULT 0,"
                    + "finalAmount DECIMAL(12,2) NOT NULL,"
                    + "paymentMethod VARCHAR(30) NOT NULL,"
                    + "FOREIGN KEY (orderId) REFERENCES tblOrderOnline(id),"
                    + "FOREIGN KEY (staffId) REFERENCES tblStaff(userId))");

            st.execute("CREATE TABLE IF NOT EXISTS tblSupplier ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "name VARCHAR(150) NOT NULL,"
                    + "address VARCHAR(255),"
                    + "phone VARCHAR(20),"
                    + "email VARCHAR(100),"
                    + "taxCode VARCHAR(30))");

            st.execute("CREATE TABLE IF NOT EXISTS tblIngredient ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "code VARCHAR(30) NOT NULL UNIQUE,"
                    + "name VARCHAR(150) NOT NULL,"
                    + "unit VARCHAR(20) NOT NULL,"
                    + "unitPrice DECIMAL(12,2) NOT NULL,"
                    + "stockQuantity DECIMAL(10,2) DEFAULT 0,"
                    + "minStockThreshold DECIMAL(10,2) DEFAULT 0)");

            st.execute("CREATE TABLE IF NOT EXISTS tblImportReceipt ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "receiptCode VARCHAR(30) NOT NULL UNIQUE,"
                    + "supplierId INT NOT NULL,"
                    + "staffId INT NOT NULL,"
                    + "importDate DATETIME NOT NULL,"
                    + "totalAmount DECIMAL(14,2) NOT NULL,"
                    + "note TEXT,"
                    + "FOREIGN KEY (supplierId) REFERENCES tblSupplier(id),"
                    + "FOREIGN KEY (staffId) REFERENCES tblStaff(userId))");

            st.execute("CREATE TABLE IF NOT EXISTS tblImportDetail ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "receiptId INT NOT NULL,"
                    + "ingredientId INT NOT NULL,"
                    + "quantity DECIMAL(10,2) NOT NULL,"
                    + "importPrice DECIMAL(12,2) NOT NULL,"
                    + "subTotal DECIMAL(14,2) NOT NULL,"
                    + "FOREIGN KEY (receiptId) REFERENCES tblImportReceipt(id),"
                    + "FOREIGN KEY (ingredientId) REFERENCES tblIngredient(id))");

            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM tblUser")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    seedSampleData(st);
                }
            }
        }
    }

    private static void seedSampleData(Statement st) throws Exception {
        st.execute("INSERT INTO tblUser (username, password, fullName, phone, email, address, role) VALUES "
                + "('ql01', '123456', 'Nguyễn Văn Quản Lý', '0901000111', 'quanly@rms.vn', 'Hà Nội', 'MANAGEMENT'),"
                + "('bh01', '123456', 'Trần Thị Bán Hàng', '0902000222', 'banhang@rms.vn', 'Hà Nội', 'SALE'),"
                + "('kho01', '123456', 'Lê Văn Kho', '0903000333', 'kho@rms.vn', 'Hà Nội', 'WAREHOUSE'),"
                + "('kh01', '123456', 'Hà Anh Khôi', '0987654321', 'khoiha@ptit.edu.vn', 'Hà Đông, Hà Nội', 'CUSTOMER'),"
                + "('kh02', '123456', 'Nguyễn Minh Anh', '0912345678', 'minhanh@gmail.com', 'Cầu Giấy, Hà Nội', 'CUSTOMER')");

        st.execute("INSERT INTO tblStaff (userId, staffCode, position, salary) VALUES "
                + "(1, 'NVQL01', 'Quản lý nhà hàng', 18000000),"
                + "(2, 'NVBH01', 'Nhân viên phục vụ & thu ngân', 9500000),"
                + "(3, 'NVK01', 'Thủ kho nguyên liệu', 10000000)");

        st.execute("INSERT INTO tblCustomer (userId, customerCode, membershipLevel, rewardPoints) VALUES "
                + "(4, 'KH001', 'Gold', 350),"
                + "(5, 'KH002', 'Silver', 120)");

        st.execute("INSERT INTO tblCategory (code, name, description) VALUES "
                + "('CAT-LAU', 'Món Lẩu', 'Các món lẩu nóng phục vụ theo nồi'),"
                + "('CAT-NUONG', 'Món Nướng', 'Các món thịt và hải sản nướng than hoa'),"
                + "('CAT-KHAI', 'Khai vị & Salad', 'Món khai vị nhẹ trước bữa chính'),"
                + "('CAT-COM', 'Cơm & Mì', 'Các món cơm rang, mì xào no bụng'),"
                + "('CAT-UONG', 'Đồ uống', 'Nước ngọt, trà hoa quả và bia tươi')");

        st.execute("INSERT INTO tblDish (categoryId, code, name, price, unit, description, status, image) VALUES "
                + "(1, 'D01', 'Lẩu Thái Hải Sản Chua Cay', 380000, 'Nồi lớn', 'Tôm sú, mực ống, ngao trắng cùng nước dùng Tom Yum chuẩn vị Thái', 'Đang phục vụ', 'lau-thai.jpg'),"
                + "(1, 'D02', 'Lẩu Riêu Cua Bắp Bò', 350000, 'Nồi lớn', 'Gạch cua đồng nguyên chất, bắp bò hoa và sườn sụn giòn', 'Đang phục vụ', 'lau-rieu.jpg'),"
                + "(2, 'D03', 'Bò Fuji Nướng Đá Sốt Tiêu Đen', 250000, 'Đĩa', 'Thịt bò Fuji mềm ngọt nướng trên đá núi lửa kèm sốt tiêu đen', 'Đang phục vụ', 'bo-fuji.jpg'),"
                + "(2, 'D04', 'Ba Chỉ Heo Nướng Mật Ong', 165000, 'Đĩa', 'Ba chỉ heo ướp mật ong rừng và tỏi băm thơm lừng', 'Đang phục vụ', 'ba-chi.jpg'),"
                + "(3, 'D05', 'Salad Cá Ngừ Sốt Mè Rang', 95000, 'Đĩa', 'Xà lách tươi, cà chua bi, cá ngừ ngâm dầu và sốt mè rang Nhật', 'Đang phục vụ', 'salad.jpg'),"
                + "(3, 'D06', 'Khoai Tây Chiên Phô Mai', 65000, 'Đĩa', 'Khoai tây chiên giòn lắc bột phô mai Cheddar', 'Đang phục vụ', 'khoai-tay.jpg'),"
                + "(4, 'D07', 'Cơm Rang Hải Sản Trứng Cá', 120000, 'Phần', 'Cơm chiên hạt tơi cùng tôm, mực và trứng cá hồi', 'Đang phục vụ', 'com-rang.jpg'),"
                + "(5, 'D08', 'Trà Đào Cam Sả', 45000, 'Ly', 'Trà đen ủ lạnh pha đào miếng, cam vàng và sả tươi', 'Đang phục vụ', 'tra-dao.jpg'),"
                + "(5, 'D09', 'Coca-Cola Lon 330ml', 25000, 'Lon', 'Nước giải khát có gas ướp lạnh', 'Đang phục vụ', 'coca.jpg'),"
                + "(2, 'D10', 'Tôm Hùm Nướng Bơ Tỏi', 620000, 'Con', 'Tôm hùm bông tươi sống nướng bơ tỏi Pháp', 'Tạm hết', 'tom-hum.jpg')");

        st.execute("INSERT INTO tblTable (tableNumber, capacity, floor, status, description) VALUES "
                + "('Bàn 01', 4, 1, 'Trống', 'Khu vực cửa sổ tầng 1'),"
                + "('Bàn 05', 6, 1, 'Đã đặt', 'Bàn gia đình gần sảnh chính'),"
                + "('Bàn 08', 6, 2, 'Đã đặt', 'Bàn VIP view ban công tầng 2'),"
                + "('Bàn 12', 8, 2, 'Đã đặt', 'Phòng riêng ấm cúng tầng 2')");

        st.execute("INSERT INTO tblReservation (customerId, tableId, bookingTime, numberOfGuests, status, note) VALUES "
                + "(4, 3, '2026-11-16 19:30:00', 5, 'Đã xác nhận', 'Khách yêu cầu ghế trẻ em'),"
                + "(4, 2, '2026-11-17 12:00:00', 4, 'Đã xác nhận', 'Đặt ăn trưa cùng đồng nghiệp'),"
                + "(5, 4, '2026-11-16 20:00:00', 7, 'Đã xác nhận', 'Sinh nhật gia đình')");
    }
}
