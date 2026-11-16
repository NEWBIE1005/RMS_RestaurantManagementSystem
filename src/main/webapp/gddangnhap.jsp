<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.util.FormatUtil"%>
<%
    String err = request.getParameter("err");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập hệ thống - RMS Restaurant</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gddangnhap.jsp"><span>RMS</span> Restaurant Management</a>
    <div class="user-info">
        <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Cổng Khách hàng</a>
    </div>
</div>

<div class="login-wrapper">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Đăng nhập Hệ thống RMS</h1>
                <p class="subtitle">Hệ thống Quản lý Nhà hàng &amp; Đặt món trực tuyến</p>
            </div>
        </div>

        <% if ("invalid".equals(err)) { %>
            <div class="alert alert-danger">Tên đăng nhập hoặc mật khẩu không chính xác. Vui lòng thử lại.</div>
        <% } else if ("timeout".equals(err)) { %>
            <div class="alert alert-info">Phiên làm việc đã hết hạn hoặc bạn chưa đăng nhập. Vui lòng đăng nhập lại.</div>
        <% } else if ("forbidden".equals(err)) { %>
            <div class="alert alert-danger">Tài khoản không có quyền truy cập chức năng vừa yêu cầu.</div>
        <% } else if ("logout".equals(msg)) { %>
            <div class="alert alert-success">Bạn đã đăng xuất an toàn khỏi hệ thống.</div>
        <% } %>

        <form action="doDangnhap.jsp" method="post">
            <div class="form-group">
                <label for="username">Tên đăng nhập</label>
                <input class="form-control" type="text" id="username" name="username" required autofocus placeholder="Nhập tên tài khoản...">
            </div>
            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <input class="form-control" type="password" id="password" name="password" required placeholder="Nhập mật khẩu...">
            </div>
            <div class="actions-row" style="margin-top: 18px;">
                <button type="submit" class="btn btn-primary" style="width: 100%;">Đăng nhập</button>
            </div>
        </form>

        <div class="summary-box" style="margin-top: 22px;">
            <div style="font-size: 13.5px; color: #4b5563; margin-bottom: 10px;">
                Khách hàng đặt bàn hoặc đặt món cho bàn đã đặt không cần đăng nhập tài khoản quản trị:
            </div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                <a href="gdChinhKH.jsp" class="btn btn-secondary">Trang Khách hàng</a>
                <a href="gdDatBan.jsp" class="btn btn-success">Đặt bàn trực tuyến</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
