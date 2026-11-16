<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) tab = "dish";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo Thống kê nhà hàng - RMS</title>
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
                <h1>Báo cáo Thống kê tổng hợp</h1>
                <p class="subtitle">Phân tích doanh thu món ăn, tồn kho nguyên liệu, khách hàng và nhà cung cấp</p>
            </div>
            <a href="gdChinhNVQL.jsp" class="btn btn-secondary">Về Trang chủ</a>
        </div>

        <div class="actions-row" style="margin-top: 0; margin-bottom: 18px;">
            <a href="gdThongKe.jsp?tab=dish" class="btn <%= "dish".equals(tab) ? "btn-primary" : "btn-secondary" %>">Thống kê Món ăn</a>
            <a href="gdThongKe.jsp?tab=ingredient" class="btn <%= "ingredient".equals(tab) ? "btn-primary" : "btn-secondary" %>">Thống kê Nguyên liệu</a>
            <a href="gdThongKe.jsp?tab=customer" class="btn <%= "customer".equals(tab) ? "btn-primary" : "btn-secondary" %>">Thống kê Khách hàng</a>
            <a href="gdThongKe.jsp?tab=supplier" class="btn <%= "supplier".equals(tab) ? "btn-primary" : "btn-secondary" %>">Thống kê Nhà cung cấp</a>
        </div>

        <% if ("dish".equals(tab)) {
            ArrayList<DishStat> list = new DishStatDAO().getDishStatistics();
            float grandTotal = 0f;
            int grandQty = 0;
            for (DishStat d : list) { grandTotal += d.getTotalRevenue(); grandQty += d.getTotalOrderedQty(); }
        %>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Mã</th>
                    <th>Tên món ăn</th>
                    <th>Thể loại</th>
                    <th class="text-right">Giá bán</th>
                    <th class="text-center">SL đã đặt</th>
                    <th class="text-right">Doanh thu ghi nhận</th>
                </tr>
                </thead>
                <tbody>
                <% for (DishStat d : list) { %>
                <tr>
                    <td><code><%= FormatUtil.escapeHtml(d.getCode()) %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(d.getName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(d.getCategory() != null ? d.getCategory().getName() : "") %></td>
                    <td class="text-right"><%= FormatUtil.formatCurrency(d.getPrice()) %></td>
                    <td class="text-center"><strong><%= d.getTotalOrderedQty() %></strong></td>
                    <td class="text-right"><strong><%= FormatUtil.formatCurrency(d.getTotalRevenue()) %></strong></td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <div class="total-line">
                <span>Tổng lượt gọi: <%= grandQty %> phần</span>
                <span>Tổng doanh thu theo món: <%= FormatUtil.formatCurrency(grandTotal) %></span>
            </div>
        <% } else if ("ingredient".equals(tab)) {
            ArrayList<IngredientStat> list = new IngredientStatDAO().getIngredientStatistics();
        %>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Mã NL</th>
                    <th>Tên nguyên liệu</th>
                    <th>ĐVT</th>
                    <th class="text-right">Tồn kho hiện tại</th>
                    <th class="text-right">Ngưỡng tối thiểu</th>
                    <th class="text-right">Tổng SL đã nhập</th>
                    <th class="text-center">Cảnh báo kho</th>
                </tr>
                </thead>
                <tbody>
                <% for (IngredientStat i : list) { boolean low = i.getStockQuantity() <= i.getMinStockThreshold(); %>
                <tr>
                    <td><code><%= FormatUtil.escapeHtml(i.getCode()) %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(i.getName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(i.getUnit()) %></td>
                    <td class="text-right"><strong><%= i.getStockQuantity() %></strong></td>
                    <td class="text-right"><%= i.getMinStockThreshold() %></td>
                    <td class="text-right"><%= i.getTotalImportedQty() %></td>
                    <td class="text-center">
                        <span class="badge <%= low ? "badge-danger" : "badge-success" %>"><%= low ? "Cần nhập thêm" : "Đủ tồn kho" %></span>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } else if ("customer".equals(tab)) {
            ArrayList<CustomerStat> list = new CustomerStatDAO().getCustomerStatistics();
        %>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Mã KH</th>
                    <th>Họ và tên</th>
                    <th>Số điện thoại</th>
                    <th>Hạng thẻ</th>
                    <th class="text-center">Điểm tích lũy</th>
                    <th class="text-center">Số lượt đặt bàn</th>
                    <th class="text-right">Tổng giá trị đơn hàng</th>
                </tr>
                </thead>
                <tbody>
                <% for (CustomerStat c : list) { %>
                <tr>
                    <td><code><%= FormatUtil.escapeHtml(c.getCustomerCode()) %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(c.getFullName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(c.getPhone()) %></td>
                    <td><span class="badge badge-warn"><%= FormatUtil.escapeHtml(c.getMembershipLevel()) %></span></td>
                    <td class="text-center"><%= c.getRewardPoints() %></td>
                    <td class="text-center"><strong><%= c.getTotalReservations() %></strong></td>
                    <td class="text-right"><strong><%= FormatUtil.formatCurrency(c.getTotalSpent()) %></strong></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } else {
            ArrayList<SupplierStat> list = new SupplierStatDAO().getSupplierStatistics();
        %>
            <table class="data-table">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Nhà cung cấp</th>
                    <th>Số điện thoại</th>
                    <th>Mã số thuế</th>
                    <th class="text-center">Số phiếu nhập</th>
                    <th class="text-right">Tổng giá trị cung cấp</th>
                </tr>
                </thead>
                <tbody>
                <% for (SupplierStat s : list) { %>
                <tr>
                    <td>#<%= s.getId() %></td>
                    <td><strong><%= FormatUtil.escapeHtml(s.getName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(s.getPhone()) %></td>
                    <td><code><%= FormatUtil.escapeHtml(s.getTaxCode()) %></code></td>
                    <td class="text-center"><strong><%= s.getTotalReceipts() %></strong></td>
                    <td class="text-right"><strong><%= FormatUtil.formatCurrency(s.getTotalSupplyValue()) %></strong></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</div>
</body>
</html>
