<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
    ArrayList<Category> listCat = new CategoryDAO().getAllCategories();
    Dish draft = (Dish) request.getAttribute("draftDish");
    if (draft == null) {
        draft = new Dish();
        draft.setUnit("Đĩa");
        draft.setStatus("Đang phục vụ");
    }
    String errMsg = (String) request.getAttribute("errMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm món ăn mới - RMS</title>
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
                <h1>Thêm món ăn mới vào thực đơn</h1>
                <p class="subtitle">Nhập đầy đủ thông tin món ăn mới và lưu vào cơ sở dữ liệu</p>
            </div>
            <a href="gdQuanLyMonAn.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <% if (errMsg != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
        <% } %>

        <form action="doThemMonAn.jsp" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label for="code">Mã món (*)</label>
                    <input class="form-control" type="text" id="code" name="code" value="<%= FormatUtil.escapeHtml(draft.getCode()) %>" required placeholder="VD: D11">
                </div>
                <div class="form-group">
                    <label for="name">Tên món ăn (*)</label>
                    <input class="form-control" type="text" id="name" name="name" value="<%= FormatUtil.escapeHtml(draft.getName()) %>" required placeholder="Nhập tên món ăn...">
                </div>
                <div class="form-group">
                    <label for="categoryId">Thể loại (*)</label>
                    <select class="form-control" id="categoryId" name="categoryId" required>
                        <% int curCatId = draft.getCategory() != null ? draft.getCategory().getId() : 0;
                           for (Category cat : listCat) { %>
                            <option value="<%= cat.getId() %>" <%= (cat.getId() == curCatId) ? "selected" : "" %>>
                                <%= FormatUtil.escapeHtml(cat.getName()) %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="price">Đơn giá (VNĐ) (*)</label>
                    <input class="form-control" type="number" id="price" name="price" step="1000" min="1000" value="<%= draft.getPrice() > 0 ? Math.round(draft.getPrice()) : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="unit">Đơn vị tính</label>
                    <input class="form-control" type="text" id="unit" name="unit" value="<%= FormatUtil.escapeHtml(draft.getUnit()) %>" required>
                </div>
                <div class="form-group">
                    <label for="status">Trạng thái</label>
                    <select class="form-control" id="status" name="status">
                        <option value="Đang phục vụ" <%= "Đang phục vụ".equals(draft.getStatus()) ? "selected" : "" %>>Đang phục vụ</option>
                        <option value="Tạm hết" <%= "Tạm hết".equals(draft.getStatus()) ? "selected" : "" %>>Tạm hết</option>
                        <option value="Ngừng phục vụ" <%= "Ngừng phục vụ".equals(draft.getStatus()) ? "selected" : "" %>>Ngừng phục vụ</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Mô tả chi tiết</label>
                <textarea class="form-control" id="description" name="description" rows="3" placeholder="Thành phần, hương vị, khẩu phần gợi ý..."><%= FormatUtil.escapeHtml(draft.getDescription()) %></textarea>
            </div>

            <div class="actions-row">
                <button type="submit" class="btn btn-primary">Lưu món ăn mới</button>
                <a href="gdTimKiemMonAn.jsp" class="btn btn-secondary">Xem danh sách thực đơn</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
