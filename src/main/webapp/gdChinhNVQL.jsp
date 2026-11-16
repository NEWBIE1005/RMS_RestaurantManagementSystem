<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ Nhân viên Quản lý - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhNVQL.jsp"><span>RMS</span> Restaurant Management</a>
    <div class="user-info">
        <span>Xin chào, <strong><%= FormatUtil.escapeHtml(nvql.getFullName()) %></strong> (<%= FormatUtil.escapeHtml(nvql.getPosition()) %>)</span>
        <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Trang chủ Nhân viên Quản lý</h1>
                <p class="subtitle">Điều hành thực đơn món ăn, combo ưu đãi và báo cáo kinh doanh nhà hàng</p>
            </div>
        </div>

        <div class="grid-cards">
            <div class="menu-tile active-module">
                <div>
                    <h3>Quản lý thông tin món ăn</h3>
                    <p>Thêm mới món ăn, tra cứu theo tên, cập nhật giá bán, mô tả và trạng thái phục vụ.</p>
                </div>
                <a href="gdQuanLyMonAn.jsp" class="btn btn-primary">Mở chức năng</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Tạo thực đơn Combo</h3>
                    <p>Thiết kế các gói Combo nhiều món kèm tỷ lệ ưu đãi, tự động tính giá bán thực tế.</p>
                </div>
                <a href="gdQuanLyCombo.jsp" class="btn btn-primary">Quản lý Combo</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Xem báo cáo thống kê</h3>
                    <p>Tổng hợp số liệu món ăn bán chạy, tồn kho nguyên liệu, khách hàng và nhà cung cấp.</p>
                </div>
                <a href="gdThongKe.jsp" class="btn btn-primary">Xem thống kê</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
