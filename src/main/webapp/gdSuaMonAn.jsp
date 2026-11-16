<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    int dishId = 0;
    try {
        dishId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception ignored) {}

    // Ưu tiên giữ dữ liệu người dùng vừa nhập nếu forward về từ doSuaMonAn.jsp do lỗi validation
    Dish monan = (Dish) request.getAttribute("editedDish");
    if (monan == null) {
        DishDAO dishDAO = new DishDAO();
        monan = dishDAO.getDishById(dishId);
    }
    if (monan == null) {
        response.sendRedirect("gdTimKiemMonAn.jsp");
        return;
    }

    CategoryDAO catDAO = new CategoryDAO();
    ArrayList<Category> listCat = catDAO.getAllCategories();
    String errMsg = (String) request.getAttribute("errMsg");
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
                <h1>Chỉnh sửa thông tin chi tiết món ăn</h1>
                <p class="subtitle">Cập nhật thông tin món ăn và nhấn Lưu để đồng bộ xuống cơ sở dữ liệu</p>
            </div>
            <a href="gdTimKiemMonAn.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <% if (errMsg != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
        <% } %>

        <form action="doSuaMonAn.jsp" method="post">
            <input type="hidden" name="id" value="<%= monan.getId() %>">

            <div class="form-grid">
                <div class="form-group">
                    <label for="code">Mã món</label>
                    <input class="form-control" type="text" id="code" name="code" value="<%= FormatUtil.escapeHtml(monan.getCode()) %>" readonly>
                </div>

                <div class="form-group">
                    <label for="name">Tên món ăn (*)</label>
                    <input class="form-control" type="text" id="name" name="name" value="<%= FormatUtil.escapeHtml(monan.getName()) %>" required>
                </div>

                <div class="form-group">
                    <label for="categoryId">Thể loại (*)</label>
                    <select class="form-control" id="categoryId" name="categoryId" required>
                        <% int curCatId = (monan.getCategory() != null) ? monan.getCategory().getId() : 0;
                           for (Category cat : listCat) { %>
                            <option value="<%= cat.getId() %>" <%= (cat.getId() == curCatId) ? "selected" : "" %>>
                                <%= FormatUtil.escapeHtml(cat.getName()) %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="price">Đơn giá (VNĐ) (*)</label>
                    <input class="form-control" type="number" id="price" name="price" step="1000" min="1000" value="<%= Math.round(monan.getPrice()) %>" required>
                </div>

                <div class="form-group">
                    <label for="unit">Đơn vị tính</label>
                    <input class="form-control" type="text" id="unit" name="unit" value="<%= FormatUtil.escapeHtml(monan.getUnit()) %>" required>
                </div>

                <div class="form-group">
                    <label for="status">Trạng thái phục vụ</label>
                    <select class="form-control" id="status" name="status">
                        <option value="Đang phục vụ" <%= "Đang phục vụ".equals(monan.getStatus()) ? "selected" : "" %>>Đang phục vụ</option>
                        <option value="Tạm hết" <%= "Tạm hết".equals(monan.getStatus()) ? "selected" : "" %>>Tạm hết</option>
                        <option value="Ngừng phục vụ" <%= "Ngừng phục vụ".equals(monan.getStatus()) ? "selected" : "" %>>Ngừng phục vụ</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Mô tả món ăn</label>
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
