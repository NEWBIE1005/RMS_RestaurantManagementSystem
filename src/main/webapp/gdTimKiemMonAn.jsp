<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.DishDAO,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    String keyword = request.getParameter("tenMon");
    if (keyword == null) keyword = "";
    String mode = request.getParameter("mode") != null ? request.getParameter("mode") : "edit";

    DishDAO dishDAO = new DishDAO();
    String actionMsg = null;
    if ("POST".equalsIgnoreCase(request.getMethod()) && "delete".equals(request.getParameter("act"))) {
        int delId = 0;
        try { delId = Integer.parseInt(request.getParameter("dishId")); } catch (Exception ignored) {}
        String res = dishDAO.deleteOrDeactivateDish(delId);
        if ("DELETED".equals(res)) {
            actionMsg = "Đã xóa hoàn toàn món ăn khỏi thực đơn (món chưa phát sinh đơn gọi).";
        } else if ("DEACTIVATED".equals(res)) {
            actionMsg = "Món ăn đã có trong dữ liệu đơn/combo nên hệ thống tự động chuyển sang trạng thái 'Ngừng phục vụ'.";
        }
    }

    ArrayList<Dish> listMon = dishDAO.searchDishByName(keyword);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tìm kiếm &amp; Quản lý món ăn - RMS</title>
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
                <h1><%= "manage".equals(mode) ? "Ngừng phục vụ / Xóa món ăn" : "Tìm kiếm món ăn cần sửa" %></h1>
                <p class="subtitle">Nhập tên món để tra cứu, chọn sửa thông tin chi tiết hoặc ngừng phục vụ</p>
            </div>
            <div style="display: flex; gap: 8px;">
                <a href="gdThemMonAn.jsp" class="btn btn-success">+ Thêm món mới</a>
                <a href="gdQuanLyMonAn.jsp" class="btn btn-secondary">Quay lại</a>
            </div>
        </div>

        <% if (actionMsg != null) { %>
            <div class="alert alert-success"><%= FormatUtil.escapeHtml(actionMsg) %></div>
        <% } %>

        <form class="search-bar" action="gdTimKiemMonAn.jsp" method="get">
            <input type="hidden" name="mode" value="<%= FormatUtil.escapeHtml(mode) %>">
            <input class="form-control" type="text" name="tenMon" value="<%= FormatUtil.escapeHtml(keyword) %>" placeholder="Nhập tên món ăn cần tìm (VD: Lẩu, Bò, Trà)...">
            <button type="submit" class="btn btn-primary">Tìm kiếm</button>
            <a href="gdTimKiemMonAn.jsp?mode=<%= FormatUtil.escapeHtml(mode) %>" class="btn btn-secondary">Hiện tất cả</a>
        </form>

        <% if (listMon.isEmpty()) { %>
            <div class="alert alert-info">Không tìm thấy món ăn nào khớp từ khóa "<%= FormatUtil.escapeHtml(keyword) %>".</div>
        <% } else { %>
            <table class="data-table">
                <thead>
                <tr>
                    <th class="text-center">TT</th>
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
                <% for (int i = 0; i < listMon.size(); i++) {
                    Dish d = listMon.get(i);
                    String badgeCls = "Đang phục vụ".equalsIgnoreCase(d.getStatus()) ? "badge-success" : "badge-warn";
                    if ("Ngừng phục vụ".equalsIgnoreCase(d.getStatus())) badgeCls = "badge-danger";
                %>
                <tr>
                    <td class="text-center"><%= (i + 1) %></td>
                    <td><code><%= FormatUtil.escapeHtml(d.getCode()) %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(d.getName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(d.getCategory() != null ? d.getCategory().getName() : "") %></td>
                    <td class="text-right"><strong><%= FormatUtil.formatCurrency(d.getPrice()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(d.getUnit()) %></td>
                    <td class="text-center"><span class="badge <%= badgeCls %>"><%= FormatUtil.escapeHtml(d.getStatus()) %></span></td>
                    <td class="text-center" style="white-space: nowrap;">
                        <a href="gdSuaMonAn.jsp?id=<%= d.getId() %>" class="btn btn-primary btn-sm">Sửa</a>
                        <form action="gdTimKiemMonAn.jsp?tenMon=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&mode=<%= FormatUtil.escapeHtml(mode) %>" method="post" style="display: inline;" onsubmit="return confirm('Xác nhận xóa hoặc ngừng phục vụ món ăn này?');">
                            <input type="hidden" name="act" value="delete">
                            <input type="hidden" name="dishId" value="<%= d.getId() %>">
                            <button type="submit" class="btn btn-danger btn-sm">Ngừng / Xóa</button>
                        </form>
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
