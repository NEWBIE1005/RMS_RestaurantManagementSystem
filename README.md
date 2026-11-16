# Hệ thống Quản lý Nhà hàng (Restaurant Management System - RMS)

Đề tài số 19 — Học phần Phân tích & Thiết kế Hệ thống Thông tin (TTTN 2 CNPM - PTIT).
Sinh viên thực hiện: **Hà Anh Khôi** — Mã sinh viên: **B23DCCE056** — Lớp: **CLC N2 (10h, thứ 3)**.

## 1. Kiến trúc & Công nghệ
- **Ngôn ngữ & Nền tảng:** Java Web (JSP + Servlet + JDBC + DAO Pattern + JavaBeans Model), JUnit 4.
- **Cơ sở dữ liệu:** MySQL 8.0 (`sql/rms_db_mysql.sql`) và chế độ nhúng H2 (`MODE=MySQL`) phục vụ chạy demo & kiểm thử độc lập.
- **2 Module trọng tâm được cài đặt đầy đủ:**
  1. **Module 1 — Nhân viên Quản lý sửa thông tin món ăn** (`gdChinhNVQL.jsp` → `gdQuanLyMonAn.jsp` → `gdTimKiemMonAn.jsp` → `gdSuaMonAn.jsp` → `doSuaMonAn.jsp` → `gdThongBao.jsp`).
  2. **Module 2 — Khách hàng đặt món online theo bàn đã đặt** (`gdChinhKH.jsp` → `gdTimBanDat.jsp` → `gdChonMonOnline.jsp` → `gdXacNhanGoiMon.jsp` → `doLuuGoiMon.jsp` → `gdThongBaoGoiMon.jsp`).

## 2. Cấu trúc thư mục
- `src/main/java/com/rms/model/` — 16 lớp thực thể (Entities).
- `src/main/java/com/rms/dao/` — Các lớp truy xuất CSDL JDBC (`DAO`, `UserDAO`, `CategoryDAO`, `DishDAO`, `ReservationDAO`, `OrderOnlineDAO`, `OrderedDishDAO`).
- `src/main/java/com/rms/launcher/` — `LocalTomcatServer.java` chạy Embedded Tomcat 9 tại cổng `8080`.
- `src/main/webapp/` — Các trang giao diện JSP và `css/style.css`.
- `src/test/java/unittest/` — Bộ kiểm thử đơn vị JUnit 4 cho các lớp DAO.
- `sql/rms_db_mysql.sql` — Script khởi tạo CSDL MySQL 8.0 và dữ liệu mẫu.
- `docs/plantuml/` & `docs/diagrams/` — Toàn bộ mã nguồn PlantUML và ảnh sơ đồ của 3 pha Đặc tả, Phân tích, Thiết kế.

## 3. Tài khoản demo
- **Nhân viên quản lý:** `ql01` / `123456`
- **Khách hàng:** `kh01` / `123456` (SĐT tìm bàn: `0987654321` hoặc tên `Hà Anh Khôi`)
