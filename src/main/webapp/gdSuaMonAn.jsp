<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    int dishId = 0;
    try {
        dishId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception ignored) {}

    DishDAO dishDAO = new DishDAO();
    Dish monan = dishDAO.getDishById(dishId);
    if (monan == null) {
        response.sendRedirect("gdTimKiemMonAn.jsp");
        return;
    }

    CategoryDAO categoryDAO = new CategoryDAO();
    ArrayList<Category> listCategory = categoryDAO.getAllCategories();
    String err = (String) request.getAttribute("errMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sửa thông tin món ăn - RMS</title>
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
                <h1>Sửa thông tin chi tiết món ăn</h1>
                <p class="subtitle">Cập nhật các thông tin món ăn và nhấn Lưu để lưu vào cơ sở dữ liệu</p>
            </div>
            <a href="gdTimKiemMonAn.jsp" class="btn btn-secondary btn-sm">Quay lại</a>
        </div>

        <% if (err != null && !err.isEmpty()) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(err) %></div>
        <% } %>

        <form action="doSuaMonAn.jsp" method="post">
            <input type="hidden" name="id" value="<%= monan.getId() %>">
            <div class="form-grid">
                <div class="form-group">
                    <label>Mã món ăn</label>
                    <input class="form-control" type="text" value="<%= FormatUtil.escapeHtml(monan.getCode()) %>" readonly>
                </div>
                <div class="form-group">
                    <label for="name">Tên món ăn *</label>
                    <input class="form-control" type="text" id="name" name="name" value="<%= FormatUtil.escapeHtml(monan.getName()) %>" required>
                </div>
                <div class="form-group">
                    <label for="categoryId">Thể loại món *</label>
                    <select class="form-control" id="categoryId" name="categoryId" required>
                        <% for (Category cat : listCategory) {
                            boolean selected = monan.getCategory() != null && monan.getCategory().getId() == cat.getId();
                        %>
                            <option value="<%= cat.getId() %>" <%= selected ? "selected" : "" %>><%= FormatUtil.escapeHtml(cat.getName()) %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="price">Đơn giá (VNĐ) *</label>
                    <input class="form-control" type="number" step="1000" min="1000" id="price" name="price" value="<%= (long) monan.getPrice() %>" required>
                </div>
                <div class="form-group">
                    <label for="unit">Đơn vị tính *</label>
                    <input class="form-control" type="text" id="unit" name="unit" value="<%= FormatUtil.escapeHtml(monan.getUnit()) %>" required>
                </div>
                <div class="form-group">
                    <label for="status">Trạng thái phục vụ *</label>
                    <select class="form-control" id="status" name="status">
                        <option value="Đang phục vụ" <%= "Đang phục vụ".equals(monan.getStatus()) ? "selected" : "" %>>Đang phục vụ</option>
                        <option value="Tạm hết" <%= "Tạm hết".equals(monan.getStatus()) ? "selected" : "" %>>Tạm hết</option>
                        <option value="Ngừng bán" <%= "Ngừng bán".equals(monan.getStatus()) ? "selected" : "" %>>Ngừng bán</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Mô tả chi tiết món ăn</label>
                <textarea class="form-control" id="description" name="description" rows="3"><%= FormatUtil.escapeHtml(monan.getDescription()) %></textarea>
            </div>

            <div class="actions-row">
                <button type="submit" class="btn btn-primary">Lưu thông tin</button>
                <a href="gdTimKiemMonAn.jsp" class="btn btn-secondary">Hủy bỏ</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
