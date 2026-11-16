<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
    String action = request.getParameter("chucNang");
    if ("edit".equals(action)) {
        response.sendRedirect("gdTimKiemMonAn.jsp");
        return;
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
                <h1>Quản lý thông tin món ăn</h1>
                <p class="subtitle">Module 1 - Bước 2: Chọn chức năng thao tác với thực đơn món ăn</p>
            </div>
            <a href="gdChinhNVQL.jsp" class="btn btn-secondary btn-sm">Quay lại</a>
        </div>

        <form action="gdQuanLyMonAn.jsp" method="get">
            <label class="radio-card">
                <input type="radio" name="chucNang" value="add" disabled>
                <div>
                    <strong>Thêm món ăn mới</strong>
                    <div class="subtitle">Bổ sung món mới vào danh mục thực đơn (Ngoài phạm vi demo)</div>
                </div>
            </label>

            <label class="radio-card" style="border-color: #d97706; background: #fffbeb;">
                <input type="radio" name="chucNang" value="edit" checked>
                <div>
                    <strong>Sửa thông tin món ăn</strong>
                    <div class="subtitle">Tìm kiếm món ăn theo tên và cập nhật tên, giá, đơn vị, thể loại, trạng thái</div>
                </div>
            </label>

            <label class="radio-card">
                <input type="radio" name="chucNang" value="delete" disabled>
                <div>
                    <strong>Xóa món ăn</strong>
                    <div class="subtitle">Ngừng kinh doanh hoặc xóa món ăn khỏi thực đơn (Ngoài phạm vi demo)</div>
                </div>
            </label>

            <div class="actions-row">
                <button type="submit" class="btn btn-primary">Tiếp tục</button>
                <a href="gdChinhNVQL.jsp" class="btn btn-secondary">Quay lại Trang chủ</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
