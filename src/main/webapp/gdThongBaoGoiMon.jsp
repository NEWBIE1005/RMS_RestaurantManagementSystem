<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    OrderOnline savedOrder = (OrderOnline) session.getAttribute("savedOrder");
    if (savedOrder == null) {
        response.sendRedirect("gdChinhKH.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt món online thành công - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Trang chủ KH</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="alert alert-success">
            <strong>Đặt món online thành công!</strong> Đơn gọi món của bạn đã được lưu vào cơ sở dữ liệu và gửi tới nhà hàng để xác nhận.
        </div>

        <div class="summary-box">
            <h3 style="margin-top: 0;">Phiếu xác nhận đặt món trực tuyến</h3>
            <p>
                <strong>Mã đơn hàng:</strong> <code><%= FormatUtil.escapeHtml(savedOrder.getOrderCode()) %></code> |
                <strong>Trạng thái:</strong> <span class="badge badge-warn"><%= FormatUtil.escapeHtml(savedOrder.getStatus()) %></span><br>
                <strong>Bàn đặt:</strong> <%= FormatUtil.escapeHtml(savedOrder.getReservation().getTable().getTableNumber()) %>
                (Khách: <%= FormatUtil.escapeHtml(savedOrder.getReservation().getCustomer().getFullName()) %> - <%= FormatUtil.escapeHtml(savedOrder.getReservation().getCustomer().getPhone()) %>)<br>
                <strong>Thời gian đặt món:</strong> <%= FormatUtil.formatDateTime(savedOrder.getOrderTime()) %><br>
                <% if (savedOrder.getNote() != null && !savedOrder.getNote().isEmpty()) { %>
                    <strong>Ghi chú:</strong> <%= FormatUtil.escapeHtml(savedOrder.getNote()) %>
                <% } %>
            </p>

            <table class="data-table">
                <thead>
                <tr>
                    <th class="text-center">STT</th>
                    <th>Tên món</th>
                    <th class="text-right">Đơn giá</th>
                    <th class="text-center">Số lượng</th>
                    <th class="text-right">Thành tiền</th>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < savedOrder.getDsMonGoi().size(); i++) {
                    OrderedDish item = savedOrder.getDsMonGoi().get(i);
                %>
                <tr>
                    <td class="text-center"><%= (i + 1) %></td>
                    <td><%= FormatUtil.escapeHtml(item.getDish().getName()) %></td>
                    <td class="text-right"><%= FormatUtil.formatCurrency(item.getPrice()) %></td>
                    <td class="text-center"><%= item.getQuantity() %></td>
                    <td class="text-right"><%= FormatUtil.formatCurrency(item.getSubTotal()) %></td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <div class="total-line">
                <span>Tổng tiền đơn hàng:</span>
                <span><%= FormatUtil.formatCurrency(savedOrder.getTotalAmount()) %></span>
            </div>
        </div>

        <div class="actions-row">
            <a href="gdChinhKH.jsp" class="btn btn-primary">OK - Về Trang chủ Khách hàng</a>
            <a href="gdTimBanDat.jsp" class="btn btn-secondary">Đặt món cho bàn khác</a>
        </div>
    </div>
</div>
</body>
</html>
