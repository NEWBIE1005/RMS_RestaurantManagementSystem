<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - Hệ thống Quản lý Nhà hàng (RMS)</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gddangnhap.jsp"><span>RMS</span> Restaurant Management</a>
    <div class="user-info">Đề tài 19 - PTIT CNPM</div>
</div>

<div class="container">
    <div class="login-wrapper">
        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Đăng nhập hệ thống RMS</h2>
                    <p class="subtitle">Hệ thống Quản lý Nhà hàng</p>
                </div>
            </div>

            <%
                String err = request.getParameter("err");
                if ("fail".equalsIgnoreCase(err)) {
            %>
                <div class="alert alert-danger">Sai tên đăng nhập hoặc mật khẩu. Vui lòng thử lại!</div>
            <% } else if ("timeout".equalsIgnoreCase(err)) { %>
                <div class="alert alert-info">Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại!</div>
            <% } %>

            <form action="doDangnhap.jsp" method="post">
                <div class="form-group">
                    <label for="username">Tên đăng nhập *</label>
                    <input class="form-control" type="text" id="username" name="username" placeholder="Nhập tài khoản..." required autofocus>
                </div>
                <div class="form-group">
                    <label for="password">Mật khẩu *</label>
                    <input class="form-control" type="password" id="password" name="password" placeholder="Nhập mật khẩu..." required>
                </div>
                <div class="actions-row" style="justify-content: space-between;">
                    <button type="submit" class="btn btn-primary" style="width: 100%;">Đăng nhập</button>
                </div>
            </form>

            <hr style="border: 0; border-top: 1px solid #e5e7eb; margin: 18px 0;">
            <div style="font-size: 13px; color: #4b5563;">
                <strong>Tài khoản demo:</strong><br>
                • Nhân viên quản lý: <code>ql01</code> / <code>123456</code><br>
                • Khách hàng: <code>kh01</code> / <code>123456</code>
            </div>
            <div class="actions-row">
                <a href="gdChinhKH.jsp" class="btn btn-secondary" style="width: 100%;">Truy cập nhanh Trang Khách hàng (Đặt món online)</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
