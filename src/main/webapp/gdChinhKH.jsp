<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    User kh = (User) session.getAttribute("khachHang");
    String displayName = (kh != null) ? kh.getFullName() : "Khách hàng trực tuyến";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ Khách hàng - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <span>Xin chào, <strong><%= FormatUtil.escapeHtml(displayName) %></strong></span>
        <% if (kh != null) { %>
            <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
        <% } else { %>
            <a href="gddangnhap.jsp" class="btn btn-secondary btn-sm">Đăng nhập</a>
        <% } %>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Trang chủ Khách hàng</h1>
                <p class="subtitle">Khám phá thực đơn, đặt bàn trước và đặt món trực tuyến tiện lợi</p>
            </div>
        </div>

        <div class="grid-cards">
            <div class="menu-tile">
                <div>
                    <h3>Tìm kiếm món ăn & Bàn trống</h3>
                    <p>Xem thực đơn món ăn đặc sắc và kiểm tra tình trạng bàn phục vụ tại các tầng.</p>
                </div>
                <button type="button" class="btn btn-secondary" disabled>Chức năng mở rộng</button>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Đặt bàn trực tuyến</h3>
                    <p>Chọn ngày giờ, số lượng khách và đặt giữ bàn trước khi tới nhà hàng.</p>
                </div>
                <button type="button" class="btn btn-secondary" disabled>Chức năng mở rộng</button>
            </div>

            <div class="menu-tile active-module">
                <div>
                    <h3>Đặt món ăn Online</h3>
                    <p>Tra cứu bàn đã đặt theo Tên hoặc Số điện thoại và chọn trước món ăn cho bữa tiệc.</p>
                </div>
                <a href="gdTimBanDat.jsp" class="btn btn-primary">Chọn Đặt món online</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
