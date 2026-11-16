<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String actionType = request.getParameter("actionType");
        if ("add".equals(actionType)) {
            response.sendRedirect("gdThemMonAn.jsp");
            return;
        } else if ("manage".equals(actionType)) {
            response.sendRedirect("gdTimKiemMonAn.jsp?mode=manage");
            return;
        } else {
            response.sendRedirect("gdTimKiemMonAn.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý thông tin món ăn - RMS</title>
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
        <div class="page-header">
            <div>
                <h1>Menu Quản lý thông tin món ăn</h1>
                <p class="subtitle">Chọn tác vụ thao tác với danh mục món ăn trong thực đơn nhà hàng</p>
            </div>
            <a href="gdChinhNVQL.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <form action="gdQuanLyMonAn.jsp" method="post">
            <div class="grid-cards">
                <label class="menu-tile active-module" style="cursor: pointer;">
                    <div>
                        <input type="radio" name="actionType" value="edit" checked> <strong>Sửa thông tin món ăn</strong>
                        <p style="margin-top: 8px;">Tìm kiếm món ăn theo tên và cập nhật đơn giá, thể loại, trạng thái phục vụ hoặc mô tả.</p>
                    </div>
                    <span class="badge badge-success">Cập nhật thực đơn</span>
                </label>

                <label class="menu-tile" style="cursor: pointer;">
                    <div>
                        <input type="radio" name="actionType" value="add"> <strong>Thêm món ăn mới</strong>
                        <p style="margin-top: 8px;">Bổ sung món ăn mới vào thực đơn kèm mã món, thể loại, giá bán và mô tả chi tiết.</p>
                    </div>
                    <span class="badge badge-warn">Thêm món mới</span>
                </label>

                <label class="menu-tile" style="cursor: pointer;">
                    <div>
                        <input type="radio" name="actionType" value="manage"> <strong>Ngừng bán / Xóa món ăn</strong>
                        <p style="margin-top: 8px;">Tìm kiếm món ăn để tạm ngừng phục vụ hoặc xóa khỏi thực đơn nếu chưa có đơn gọi.</p>
                    </div>
                    <span class="badge badge-danger">Quản lý trạng thái</span>
                </label>
            </div>

            <div class="actions-row" style="margin-top: 22px;">
                <button type="submit" class="btn btn-primary">Tiếp tục</button>
                <a href="gdChinhNVQL.jsp" class="btn btn-secondary">Về Trang chủ</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
