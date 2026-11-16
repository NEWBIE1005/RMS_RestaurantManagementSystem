<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    String dishName = request.getParameter("dishName");
    if (dishName == null) dishName = "";
    int categoryId = 0;
    try { categoryId = Integer.parseInt(request.getParameter("categoryId")); } catch (Exception ignored) {}

    ArrayList<Category> cats = new CategoryDAO().getAllCategories();
    ArrayList<Dish> dishes = new DishDAO().searchDish(dishName, categoryId);
    ArrayList<Combo> combos = new ComboDAO().getAllCombos();
    ArrayList<Table> tables = new TableDAO().getAllTables();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tra cứu Thực đơn &amp; Bàn - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <a href="gdDatBan.jsp" class="btn btn-success btn-sm">Đặt bàn ngay</a>
        <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Trang chủ KH</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Thực đơn món ăn &amp; Combo ưu đãi</h1>
                <p class="subtitle">Tra cứu món ăn theo tên, thể loại và tham khảo bàn ăn tại nhà hàng</p>
            </div>
        </div>

        <form class="search-bar" action="gdTraCuuThucDon.jsp" method="get">
            <input class="form-control" type="text" name="dishName" value="<%= FormatUtil.escapeHtml(dishName) %>" placeholder="Tìm tên món...">
            <select class="form-control" name="categoryId" style="max-width: 220px;">
                <option value="0">-- Tất cả thể loại --</option>
                <% for (Category c : cats) { %>
                    <option value="<%= c.getId() %>" <%= (categoryId == c.getId()) ? "selected" : "" %>><%= FormatUtil.escapeHtml(c.getName()) %></option>
                <% } %>
            </select>
            <button type="submit" class="btn btn-primary">Lọc thực đơn</button>
        </form>

        <table class="data-table">
            <thead>
            <tr>
                <th>Mã</th>
                <th>Tên món ăn</th>
                <th>Thể loại</th>
                <th>Đơn vị</th>
                <th class="text-right">Đơn giá</th>
                <th class="text-center">Tình trạng</th>
            </tr>
            </thead>
            <tbody>
            <% for (Dish d : dishes) { %>
            <tr>
                <td><code><%= FormatUtil.escapeHtml(d.getCode()) %></code></td>
                <td><strong><%= FormatUtil.escapeHtml(d.getName()) %></strong><br><small style="color:#6b7280;"><%= FormatUtil.escapeHtml(d.getDescription()) %></small></td>
                <td><%= FormatUtil.escapeHtml(d.getCategory() != null ? d.getCategory().getName() : "") %></td>
                <td><%= FormatUtil.escapeHtml(d.getUnit()) %></td>
                <td class="text-right"><strong><%= FormatUtil.formatCurrency(d.getPrice()) %></strong></td>
                <td class="text-center">
                    <span class="badge <%= "Đang phục vụ".equalsIgnoreCase(d.getStatus()) ? "badge-success" : "badge-danger" %>"><%= FormatUtil.escapeHtml(d.getStatus()) %></span>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <% if (!combos.isEmpty()) { %>
    <div class="card">
        <h2 style="margin-top:0; color:#7c2d12;">Thực đơn Combo gợi ý</h2>
        <div class="grid-cards">
            <% for (Combo cb : combos) { %>
            <div class="summary-box">
                <div style="display:flex; justify-content:space-between;">
                    <strong><%= FormatUtil.escapeHtml(cb.getName()) %></strong>
                    <span class="badge badge-success">-<%= Math.round(cb.getDiscountRate()) %>%</span>
                </div>
                <p style="font-size:13px; color:#4b5563; margin:6px 0;"><%= FormatUtil.escapeHtml(cb.getDescription()) %></p>
                <div style="font-weight:700; color:#9a3412;">Giá Combo: <%= FormatUtil.formatCurrency(cb.getTotalPrice()) %></div>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <div class="card">
        <h2 style="margin-top:0; color:#7c2d12;">Danh sách Bàn ăn tại nhà hàng</h2>
        <table class="data-table">
            <thead><tr><th>Số bàn</th><th>Tầng</th><th>Sức chứa</th><th>Mô tả khu vực</th><th>Trạng thái</th></tr></thead>
            <tbody>
            <% for (Table t : tables) { %>
                <tr>
                    <td><strong><%= FormatUtil.escapeHtml(t.getTableNumber()) %></strong></td>
                    <td>Tầng <%= t.getFloor() %></td>
                    <td><%= t.getCapacity() %> khách</td>
                    <td><%= FormatUtil.escapeHtml(t.getDescription()) %></td>
                    <td><span class="badge badge-success"><%= FormatUtil.escapeHtml(t.getStatus()) %></span></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
