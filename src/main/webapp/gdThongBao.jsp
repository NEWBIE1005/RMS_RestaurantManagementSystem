<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
    Dish updatedDish = (Dish) session.getAttribute("updatedDish");
    String flashTitle = (String) session.getAttribute("flashActionTitle");
    if (flashTitle == null || flashTitle.isEmpty()) {
        flashTitle = "Cập nhật thông tin món ăn thành công!";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông báo cập nhật - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhNVQL.jsp"><span>RMS</span> Restaurant Management</a>
    <div class="user-info">
        <span><%= FormatUtil.escapeHtml(nvql.getFullName()) %></span>
        <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="alert alert-success">
            <strong><%= FormatUtil.escapeHtml(flashTitle) %></strong> Dữ liệu mới đã được lưu vào cơ sở dữ liệu.
        </div>

        <% if (updatedDish != null) { %>
        <div class="summary-box">
            <h3 style="margin-top: 0;">Thông tin món ăn sau cập nhật</h3>
            <table class="data-table">
                <tr><th style="width: 220px;">Mã món</th><td><%= FormatUtil.escapeHtml(updatedDish.getCode()) %></td></tr>
                <tr><th>Tên món ăn</th><td><strong><%= FormatUtil.escapeHtml(updatedDish.getName()) %></strong></td></tr>
                <tr><th>Thể loại</th><td><%= FormatUtil.escapeHtml(updatedDish.getCategory() != null ? updatedDish.getCategory().getName() : "") %></td></tr>
                <tr><th>Đơn giá mới</th><td><strong><%= FormatUtil.formatCurrency(updatedDish.getPrice()) %></strong> / <%= FormatUtil.escapeHtml(updatedDish.getUnit()) %></td></tr>
                <tr><th>Trạng thái</th><td><span class="badge badge-success"><%= FormatUtil.escapeHtml(updatedDish.getStatus()) %></span></td></tr>
                <tr><th>Mô tả</th><td><%= FormatUtil.escapeHtml(updatedDish.getDescription()) %></td></tr>
            </table>
        </div>
        <% } %>

        <div class="actions-row">
            <a href="gdChinhNVQL.jsp" class="btn btn-primary">OK - Về Trang chủ Quản lý</a>
            <a href="gdTimKiemMonAn.jsp" class="btn btn-secondary">Tiếp tục sửa món khác</a>
        </div>
    </div>
</div>
</body>
</html>
