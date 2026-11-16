<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Customer kh = (Customer) session.getAttribute("khachHang");
    User fallbackUser = (User) session.getAttribute("user");
    String displayName = (kh != null) ? kh.getFullName()
            : (fallbackUser != null ? fallbackUser.getFullName() : "Khách hàng trực tuyến");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ Khách hàng - RMS Restaurant Online</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <span>Xin chào, <strong><%= FormatUtil.escapeHtml(displayName) %></strong>
        <% if (kh != null) { %> • Hạng <%= FormatUtil.escapeHtml(kh.getMembershipLevel()) %> (<%= kh.getRewardPoints() %> điểm)<% } %></span>
        <% if (kh != null || fallbackUser != null) { %>
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
                <p class="subtitle">Đặt bàn trực tuyến, tìm bàn đã đặt để gọi món trước và tra cứu thực đơn</p>
            </div>
        </div>

        <div class="grid-cards">
            <div class="menu-tile active-module">
                <div>
                    <h3>Đặt món ăn Online</h3>
                    <p>Tìm bàn đã đặt theo Tên hoặc Số điện thoại, chọn nhiều món ăn kèm số lượng và gửi bếp chuẩn bị.</p>
                </div>
                <a href="gdTimBanDat.jsp" class="btn btn-primary">Đặt món ngay</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Đặt bàn trực tuyến</h3>
                    <p>Chọn khung giờ, số lượng khách và kiểm tra bàn còn trống phù hợp tại các tầng nhà hàng.</p>
                </div>
                <a href="gdDatBan.jsp" class="btn btn-success">Đặt bàn ngay</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Tra cứu Thực đơn &amp; Bàn</h3>
                    <p>Xem bảng giá món ăn theo thể loại, các gói Combo ưu đãi và sơ đồ bàn nhà hàng.</p>
                </div>
                <a href="gdTraCuuThucDon.jsp" class="btn btn-primary">Xem thực đơn</a>
            </div>

            <div class="menu-tile">
                <div>
                    <h3>Tra cứu &amp; Theo dõi đơn</h3>
                    <p>Kiểm tra trạng thái đơn gọi món trực tuyến theo mã đơn hoặc số điện thoại.</p>
                </div>
                <a href="gdLichSuDon.jsp" class="btn btn-secondary">Xem lịch sử đơn</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
