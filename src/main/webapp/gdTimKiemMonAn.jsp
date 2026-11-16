<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }
    String keyword = request.getParameter("tenMon");
    if (keyword == null) {
        keyword = "";
    }
    DishDAO dishDAO = new DishDAO();
    ArrayList<Dish> listMonAn = dishDAO.searchDishByName(keyword);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tìm kiếm món ăn để sửa - RMS</title>
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
                <h1>Tìm kiếm món ăn cần sửa</h1>
                <p class="subtitle">Nhập tên món ăn cần tìm và chọn món ăn từ danh sách kết quả để chỉnh sửa</p>
            </div>
            <a href="gdQuanLyMonAn.jsp" class="btn btn-secondary btn-sm">Quay lại</a>
        </div>

        <form class="search-bar" action="gdTimKiemMonAn.jsp" method="get">
            <input class="form-control" type="text" name="tenMon" value="<%= FormatUtil.escapeHtml(keyword) %>" placeholder="Nhập tên món ăn cần tìm (ví dụ: Lẩu, Bò, Cơm)...">
            <button type="submit" class="btn btn-primary">Tìm kiếm</button>
        </form>

        <% if (listMonAn.isEmpty()) { %>
            <div class="alert alert-info">Không tìm thấy món ăn nào phù hợp với từ khóa "<%= FormatUtil.escapeHtml(keyword) %>".</div>
        <% } else { %>
            <table class="data-table">
                <thead>
                <tr>
                    <th class="text-center">STT</th>
                    <th>Mã món</th>
                    <th>Tên món ăn</th>
                    <th>Thể loại</th>
                    <th class="text-right">Đơn giá</th>
                    <th>ĐVT</th>
                    <th class="text-center">Trạng thái</th>
                    <th class="text-center">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < listMonAn.size(); i++) {
                    Dish d = listMonAn.get(i);
                    boolean active = "Đang phục vụ".equalsIgnoreCase(d.getStatus());
                %>
                <tr>
                    <td class="text-center"><%= (i + 1) %></td>
                    <td><strong><%= FormatUtil.escapeHtml(d.getCode()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(d.getName()) %></td>
                    <td><%= FormatUtil.escapeHtml(d.getCategory() != null ? d.getCategory().getName() : "") %></td>
                    <td class="text-right"><%= FormatUtil.formatCurrency(d.getPrice()) %></td>
                    <td><%= FormatUtil.escapeHtml(d.getUnit()) %></td>
                    <td class="text-center">
                        <span class="badge <%= active ? "badge-success" : "badge-warn" %>"><%= FormatUtil.escapeHtml(d.getStatus()) %></span>
                    </td>
                    <td class="text-center">
                        <a href="gdSuaMonAn.jsp?id=<%= d.getId() %>" class="btn btn-primary btn-sm">Sửa</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</div>
</body>
</html>
