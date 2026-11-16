-- ============================================================================
-- CSDL Hệ thống Quản lý Nhà hàng (Restaurant Management System - RMS)
-- Chuẩn hóa theo Hình 4.2 (Giáo trình TTTN 2 CNPM - PTIT)
-- Tương thích MySQL 8.0+ và H2 (MODE=MySQL)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS rms_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rms_db;

CREATE TABLE IF NOT EXISTS tblUser (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fullName VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(255),
    role VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS tblStaff (
    userId INT PRIMARY KEY,
    staffCode VARCHAR(20) NOT NULL UNIQUE,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12,2) DEFAULT 0,
    CONSTRAINT fk_staff_user FOREIGN KEY (userId) REFERENCES tblUser(id)
);

CREATE TABLE IF NOT EXISTS tblCustomer (
    userId INT PRIMARY KEY,
    customerCode VARCHAR(20) NOT NULL UNIQUE,
    membershipLevel VARCHAR(30) DEFAULT 'Standard',
    rewardPoints INT DEFAULT 0,
    CONSTRAINT fk_customer_user FOREIGN KEY (userId) REFERENCES tblUser(id)
);

CREATE TABLE IF NOT EXISTS tblCategory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS tblDish (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoryId INT NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Đang phục vụ',
    image VARCHAR(255),
    CONSTRAINT fk_dish_category FOREIGN KEY (categoryId) REFERENCES tblCategory(id)
);

CREATE TABLE IF NOT EXISTS tblCombo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    discountRate FLOAT DEFAULT 0,
    totalPrice DECIMAL(12,2) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS tblComboDish (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comboId INT NOT NULL,
    dishId INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_combodish_combo FOREIGN KEY (comboId) REFERENCES tblCombo(id),
    CONSTRAINT fk_combodish_dish FOREIGN KEY (dishId) REFERENCES tblDish(id)
);

CREATE TABLE IF NOT EXISTS tblTable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tableNumber VARCHAR(20) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    status VARCHAR(30) NOT NULL DEFAULT 'Trống',
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS tblReservation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    tableId INT NOT NULL,
    bookingTime DATETIME NOT NULL,
    numberOfGuests INT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Đã xác nhận',
    note TEXT,
    CONSTRAINT fk_res_customer FOREIGN KEY (customerId) REFERENCES tblCustomer(userId),
    CONSTRAINT fk_res_table FOREIGN KEY (tableId) REFERENCES tblTable(id)
);

CREATE TABLE IF NOT EXISTS tblOrderOnline (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orderCode VARCHAR(30) NOT NULL UNIQUE,
    reservationId INT NOT NULL,
    orderTime DATETIME NOT NULL,
    totalAmount DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Chờ xác nhận',
    note TEXT,
    CONSTRAINT fk_order_res FOREIGN KEY (reservationId) REFERENCES tblReservation(id)
);

CREATE TABLE IF NOT EXISTS tblOrderedDish (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    dishId INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    note VARCHAR(255),
    CONSTRAINT fk_od_order FOREIGN KEY (orderId) REFERENCES tblOrderOnline(id),
    CONSTRAINT fk_od_dish FOREIGN KEY (dishId) REFERENCES tblDish(id)
);

CREATE TABLE IF NOT EXISTS tblBill (
    id INT AUTO_INCREMENT PRIMARY KEY,
    billCode VARCHAR(30) NOT NULL UNIQUE,
    orderId INT NOT NULL,
    staffId INT NOT NULL,
    paymentTime DATETIME NOT NULL,
    totalAmount DECIMAL(12,2) NOT NULL,
    discount DECIMAL(12,2) DEFAULT 0,
    finalAmount DECIMAL(12,2) NOT NULL,
    paymentMethod VARCHAR(30) NOT NULL,
    CONSTRAINT fk_bill_order FOREIGN KEY (orderId) REFERENCES tblOrderOnline(id),
    CONSTRAINT fk_bill_staff FOREIGN KEY (staffId) REFERENCES tblStaff(userId)
);

CREATE TABLE IF NOT EXISTS tblSupplier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    taxCode VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS tblIngredient (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unitPrice DECIMAL(12,2) NOT NULL,
    stockQuantity DECIMAL(10,2) DEFAULT 0,
    minStockThreshold DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tblImportReceipt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    receiptCode VARCHAR(30) NOT NULL UNIQUE,
    supplierId INT NOT NULL,
    staffId INT NOT NULL,
    importDate DATETIME NOT NULL,
    totalAmount DECIMAL(14,2) NOT NULL,
    note TEXT,
    CONSTRAINT fk_imp_sup FOREIGN KEY (supplierId) REFERENCES tblSupplier(id),
    CONSTRAINT fk_imp_staff FOREIGN KEY (staffId) REFERENCES tblStaff(userId)
);

CREATE TABLE IF NOT EXISTS tblImportDetail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    receiptId INT NOT NULL,
    ingredientId INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    importPrice DECIMAL(12,2) NOT NULL,
    subTotal DECIMAL(14,2) NOT NULL,
    CONSTRAINT fk_impd_rec FOREIGN KEY (receiptId) REFERENCES tblImportReceipt(id),
    CONSTRAINT fk_impd_ing FOREIGN KEY (ingredientId) REFERENCES tblIngredient(id)
);

-- ============================================================================
-- DỮ LIỆU MẪU PHỤC VỤ DEMO VÀ KIỂM THỬ
-- ============================================================================

INSERT INTO tblUser (id, username, password, fullName, phone, email, address, role) VALUES
(1, 'ql01', '123456', 'Nguyễn Văn Quản Lý', '0901000111', 'quanly@rms.vn', 'Hà Nội', 'MANAGEMENT'),
(2, 'bh01', '123456', 'Trần Thị Bán Hàng', '0902000222', 'banhang@rms.vn', 'Hà Nội', 'SALE'),
(3, 'kho01', '123456', 'Lê Văn Kho', '0903000333', 'kho@rms.vn', 'Hà Nội', 'WAREHOUSE'),
(4, 'kh01', '123456', 'Hà Anh Khôi', '0987654321', 'khoiha@ptit.edu.vn', 'Hà Đông, Hà Nội', 'CUSTOMER'),
(5, 'kh02', '123456', 'Nguyễn Minh Anh', '0912345678', 'minhanh@gmail.com', 'Cầu Giấy, Hà Nội', 'CUSTOMER');

INSERT INTO tblStaff (userId, staffCode, position, salary) VALUES
(1, 'NVQL01', 'Quản lý nhà hàng', 18000000),
(2, 'NVBH01', 'Nhân viên phục vụ & thu ngân', 9500000),
(3, 'NVK01', 'Thủ kho nguyên liệu', 10000000);

INSERT INTO tblCustomer (userId, customerCode, membershipLevel, rewardPoints) VALUES
(4, 'KH001', 'Gold', 350),
(5, 'KH002', 'Silver', 120);

INSERT INTO tblCategory (id, code, name, description) VALUES
(1, 'CAT-LAU', 'Món Lẩu', 'Các món lẩu nóng phục vụ theo nồi'),
(2, 'CAT-NUONG', 'Món Nướng', 'Các món thịt và hải sản nướng than hoa'),
(3, 'CAT-KHAI', 'Khai vị & Salad', 'Món khai vị nhẹ trước bữa chính'),
(4, 'CAT-COM', 'Cơm & Mì', 'Các món cơm rang, mì xào no bụng'),
(5, 'CAT-UONG', 'Đồ uống', 'Nước ngọt, trà hoa quả và bia tươi');

INSERT INTO tblDish (id, categoryId, code, name, price, unit, description, status, image) VALUES
(1, 1, 'D01', 'Lẩu Thái Hải Sản Chua Cay', 380000, 'Nồi lớn', 'Tôm sú, mực ống, ngao trắng cùng nước dùng Tom Yum chuẩn vị Thái', 'Đang phục vụ', 'lau-thai.jpg'),
(2, 1, 'D02', 'Lẩu Riêu Cua Bắp Bò', 350000, 'Nồi lớn', 'Gạch cua đồng nguyên chất, bắp bò hoa và sườn sụn giòn', 'Đang phục vụ', 'lau-rieu.jpg'),
(3, 2, 'D03', 'Bò Fuji Nướng Đá Sốt Tiêu Đen', 250000, 'Đĩa', 'Thịt bò Fuji mềm ngọt nướng trên đá núi lửa kèm sốt tiêu đen', 'Đang phục vụ', 'bo-fuji.jpg'),
(4, 2, 'D04', 'Ba Chỉ Heo Nướng Mật Ong', 165000, 'Đĩa', 'Ba chỉ heo ướp mật ong rừng và tỏi băm thơm lừng', 'Đang phục vụ', 'ba-chi.jpg'),
(5, 3, 'D05', 'Salad Cá Ngừ Sốt Mè Rang', 95000, 'Đĩa', 'Xà lách tươi, cà chua bi, cá ngừ ngâm dầu và sốt mè rang Nhật', 'Đang phục vụ', 'salad.jpg'),
(6, 3, 'D06', 'Khoai Tây Chiên Phô Mai', 65000, 'Đĩa', 'Khoai tây chiên giòn lắc bột phô mai Cheddar', 'Đang phục vụ', 'khoai-tay.jpg'),
(7, 4, 'D07', 'Cơm Rang Hải Sản Trứng Cá', 120000, 'Phần', 'Cơm chiên hạt tơi cùng tôm, mực và trứng cá hồi', 'Đang phục vụ', 'com-rang.jpg'),
(8, 5, 'D08', 'Trà Đào Cam Sả', 45000, 'Ly', 'Trà đen ủ lạnh pha đào miếng, cam vàng và sả tươi', 'Đang phục vụ', 'tra-dao.jpg'),
(9, 5, 'D09', 'Coca-Cola Lon 330ml', 25000, 'Lon', 'Nước giải khát có gas ướp lạnh', 'Đang phục vụ', 'coca.jpg'),
(10, 2, 'D10', 'Tôm Hùm Nướng Bơ Tỏi', 620000, 'Con', 'Tôm hùm bông tươi sống nướng bơ tỏi Pháp', 'Tạm hết', 'tom-hum.jpg');

INSERT INTO tblTable (id, tableNumber, capacity, floor, status, description) VALUES
(1, 'Bàn 01', 4, 1, 'Trống', 'Khu vực cửa sổ tầng 1'),
(2, 'Bàn 05', 6, 1, 'Đã đặt', 'Bàn gia đình gần sảnh chính'),
(3, 'Bàn 08', 6, 2, 'Đã đặt', 'Bàn VIP view ban công tầng 2'),
(4, 'Bàn 12', 8, 2, 'Đã đặt', 'Phòng riêng ấm cúng tầng 2');

INSERT INTO tblReservation (id, customerId, tableId, bookingTime, numberOfGuests, status, note) VALUES
(1, 4, 3, '2026-11-16 19:30:00', 5, 'Đã xác nhận', 'Khách yêu cầu ghế trẻ em'),
(2, 4, 2, '2026-11-17 12:00:00', 4, 'Đã xác nhận', 'Đặt ăn trưa cùng đồng nghiệp'),
(3, 5, 4, '2026-11-16 20:00:00', 7, 'Đã xác nhận', 'Sinh nhật gia đình');

INSERT INTO tblSupplier (id, name, address, phone, email, taxCode) VALUES
(1, 'Công ty Hải Sản Biển Đông', 'Q. Hai Bà Trưng, Hà Nội', '0243888999', 'haisan@biendong.vn', '0108112233'),
(2, 'Nông Sản Sạch Cao Nguyên', 'H. Hoài Đức, Hà Nội', '0243777666', 'sales@nongsan.vn', '0109223344'),
(3, 'Thực Phẩm Nhập Khẩu Á Châu', 'Q. Cầu Giấy, Hà Nội', '0243555444', 'contact@achaufood.vn', '0107334455');

INSERT INTO tblIngredient (id, code, name, unit, unitPrice, stockQuantity, minStockThreshold) VALUES
(1, 'NL01', 'Tôm sú tươi size 25', 'kg', 290000, 18.5, 5.0),
(2, 'NL02', 'Thịt bò Fuji cắt lát', 'kg', 420000, 12.0, 4.0),
(3, 'NL03', 'Rau muống & Cải thảo lẩu', 'kg', 28000, 3.5, 5.0),
(4, 'NL04', 'Gạch cua đồng tươi', 'kg', 165000, 8.0, 3.0),
(5, 'NL05', 'Đào ngâm & Trà đen đặc biệt', 'hộp', 65000, 14.0, 4.0);

INSERT INTO tblImportReceipt (id, receiptCode, supplierId, staffId, importDate, totalAmount, note) VALUES
(1, 'PN-261116-01', 1, 3, '2026-11-16 07:30:00', 5365000, 'Nhập hải sản tươi đầu ngày');

INSERT INTO tblImportDetail (id, receiptId, ingredientId, quantity, importPrice, subTotal) VALUES
(1, 1, 1, 18.5, 290000, 5365000);

INSERT INTO tblCombo (id, name, discountRate, totalPrice, description) VALUES
(1, 'Combo Tiệc Lẩu Nướng 4 Người', 15, 709750, 'Gồm 1 Nồi Lẩu Thái Hải Sản, 1 Bò Fuji Nướng Đá, 4 Trà Đào Cam Sả');

INSERT INTO tblComboDish (id, comboId, dishId, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 3, 1),
(3, 1, 8, 4);
