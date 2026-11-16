<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Reservation selectedRes = (Reservation) session.getAttribute("selectedReservation");
    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");
    if (selectedRes == null) {
        response.sendRedirect("gdTimBanDat.jsp");
        return;
    }
    if (dsMonDaGoi == null || dsMonDaGoi.isEmpty()) {
        response.sendRedirect("gdChonMonOnline.jsp");
        return;
    }

    float totalAmount = 0f;
    for (OrderedDish item : dsMonDaGoi) {
        totalAmount += item.getSubTotal();
    }
    String errMsg = (String) request.getAttribute("errMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác nhận đơn đặt món online - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <span>Khách hàng: <strong><%= FormatUtil.escapeHtml(selectedRes.getCustomer().getFullName()) %></strong></span>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Xác nhận đơn đặt món online</h1>
                <p class="subtitle">Kiểm tra lại thông tin bàn đặt, danh sách món đã chọn và xác nhận lưu đơn hàng</p>
            </div>
            <a href="gdChonMonOnline.jsp" class="btn btn-secondary btn-sm">Chọn thêm món</a>
        </div>

        <% if (errMsg != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
        <% } %>

        <div class="summary-box" style="margin-bottom: 18px;">
            <strong>Thông tin bàn đặt:</strong>
            Mã đặt bàn <code>#RES-<%= selectedRes.getId() %></code> •
            <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong> (Tầng <%= selectedRes.getTable().getFloor() %>) •
            Khách: <strong><%= FormatUtil.escapeHtml(selectedRes.getCustomer().getFullName()) %></strong> (<%= FormatUtil.escapeHtml(selectedRes.getCustomer().getPhone()) %>) •
            Thời gian: <%= FormatUtil.formatDateTime(selectedRes.getBookingTime()) %>
        </div>

        <table class="data-table">
            <thead>
            <tr>
                <th class="text-center">STT</th>
                <th>Mã món</th>
                <th>Tên món ăn</th>
                <th class="text-right">Đơn giá</th>
                <th class="text-center">Số lượng</th>
                <th class="text-right">Thành tiền</th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < dsMonDaGoi.size(); i++) {
                OrderedDish item = dsMonDaGoi.get(i);
            %>
            <tr>
                <td class="text-center"><%= (i + 1) %></td>
                <td><%= FormatUtil.escapeHtml(item.getDish().getCode()) %></td>
                <td><strong><%= FormatUtil.escapeHtml(item.getDish().getName()) %></strong></td>
                <td class="text-right"><%= FormatUtil.formatCurrency(item.getPrice()) %></td>
                <td class="text-center"><%= item.getQuantity() %> <%= FormatUtil.escapeHtml(item.getDish().getUnit()) %></td>
                <td class="text-right"><strong><%= FormatUtil.formatCurrency(item.getSubTotal()) %></strong></td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <div class="total-line">
            <span>TỔNG TIỀN THANH TOÁN DỰ KIẾN:</span>
            <span><%= FormatUtil.formatCurrency(totalAmount) %></span>
        </div>

        <form action="doLuuGoiMon.jsp" method="post" style="margin-top: 18px;">
            <div class="form-group">
                <label for="note">Ghi chú cho nhà bếp (tùy chọn)</label>
                <textarea class="form-control" id="note" name="note" rows="2" placeholder="Ví dụ: Làm nước lẩu ít cay, không hành..."></textarea>
            </div>
            <div class="actions-row">
                <button type="submit" class="btn btn-success">Xác nhận đặt món & Lưu đơn</button>
                <a href="gdChonMonOnline.jsp" class="btn btn-secondary">Quay lại chỉnh sửa món</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
