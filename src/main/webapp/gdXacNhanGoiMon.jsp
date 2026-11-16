<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Reservation selectedRes = (Reservation) session.getAttribute("selectedRes");
    Staff nvbh = (Staff) session.getAttribute("nvbh");
    @SuppressWarnings("unchecked")
    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");

    if (selectedRes == null || dsMonDaGoi == null || dsMonDaGoi.isEmpty()) {
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
    <title>Xác nhận đơn đặt món Online - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="<%= (nvbh != null) ? "gdChinhNVBH.jsp" : "gdChinhKH.jsp" %>"><span>RMS</span> <%= (nvbh != null) ? "Restaurant Sale" : "Restaurant Online" %></a>
    <div class="user-info">
        <a href="gdChonMonOnline.jsp" class="btn btn-secondary btn-sm">Quay lại chọn thêm món</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Xác nhận đơn đặt món Online</h1>
                <p class="subtitle">Kiểm tra lại thông tin bàn đặt, chi tiết các món gọi và nhấn Xác nhận để lưu đơn</p>
            </div>
        </div>

        <% if (errMsg != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
        <% } %>

        <div class="summary-box">
            <strong>Thông tin bàn đặt:</strong>
            Mã đặt <code>#RES-<%= selectedRes.getId() %></code> |
            <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong> (Tầng <%= selectedRes.getTable().getFloor() %>, <%= selectedRes.getTable().getCapacity() %> chỗ)<br>
            <strong>Khách hàng:</strong> <%= FormatUtil.escapeHtml(selectedRes.getCustomer().getFullName()) %> — <%= FormatUtil.escapeHtml(selectedRes.getCustomer().getPhone()) %> |
            <strong>Thời gian đặt bàn:</strong> <%= FormatUtil.formatDateTime(selectedRes.getBookingTime()) %>
        </div>

        <table class="data-table">
            <thead>
            <tr>
                <th class="text-center">STT</th>
                <th>Tên món</th>
                <th>Ghi chú món</th>
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
                <td><strong><%= FormatUtil.escapeHtml(item.getDish().getName()) %></strong></td>
                <td><%= FormatUtil.escapeHtml(item.getNote()) %></td>
                <td class="text-right"><%= FormatUtil.formatCurrency(item.getPrice()) %></td>
                <td class="text-center"><strong><%= item.getQuantity() %></strong></td>
                <td class="text-right"><strong><%= FormatUtil.formatCurrency(item.getSubTotal()) %></strong></td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <div class="total-line">
            <span>Tổng giá trị đơn hàng:</span>
            <span><%= FormatUtil.formatCurrency(totalAmount) %></span>
        </div>

        <form action="doLuuGoiMon.jsp" method="post" style="margin-top: 18px;">
            <div class="form-group">
                <label for="note">Ghi chú chung cho bếp / phục vụ</label>
                <textarea class="form-control" id="note" name="note" rows="2" placeholder="VD: Làm nước lẩu ít cay, mang trà ra trước..."></textarea>
            </div>
            <div class="actions-row">
                <button type="submit" class="btn btn-success">Xác nhận đặt món &amp; Lưu đơn</button>
                <a href="gdChonMonOnline.jsp" class="btn btn-secondary">Quay lại chỉnh sửa món</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
