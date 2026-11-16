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
                <p class="subtitle">Lựa chọn chức năng quản trị hệ thống nhà hàng</p>
            </div>
        </div>

        <div class="grid-cards">
            <div class="menu-tile active-module">
                <div>
                    <h3>Quản lý thông tin món ăn</h3>
                    <p>Thêm, tìm kiếm, chỉnh sửa và cập nhật trạng thái các món ăn trong thực đơn nhà hàng.</p>
                </div>
                <a href="gdQuanLyMonAn.jsp" class="btn btn-primary">Chọn Quản lý món ăn</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Tạo thực đơn Combo</h3>
                    <p>Kết hợp các món ăn đơn lẻ thành thực đơn Combo với mức giá ưu đãi.</p>
                </div>
                <button type="button" class="btn btn-secondary" disabled>Chức năng mở rộng</button>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Xem báo cáo thống kê</h3>
                    <p>Thống kê doanh thu món ăn, nguyên liệu tiêu thụ, khách hàng và nhà cung cấp.</p>
                </div>
                <button type="button" class="btn btn-secondary" disabled>Chức năng mở rộng</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>
