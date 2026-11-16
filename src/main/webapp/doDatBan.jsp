<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.text.SimpleDateFormat,java.util.Date,com.rms.dao.ReservationDAO,com.rms.model.Reservation,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    String fullName = request.getParameter("fullName");
    String phone = request.getParameter("phone");
    String email = request.getParameter("email");
    String bookingTimeStr = request.getParameter("bookingTimeStr");
    String note = request.getParameter("note");
    int tableId = 0;
    int guests = 0;
    try { tableId = Integer.parseInt(request.getParameter("tableId")); } catch (Exception ignored) {}
    try { guests = Integer.parseInt(request.getParameter("guests")); } catch (Exception ignored) {}

    Date bookingTime = null;
    try { bookingTime = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(bookingTimeStr); } catch (Exception ignored) {}

    ReservationDAO resDAO = new ReservationDAO();
    Reservation created = resDAO.createReservation(fullName, phone, email, tableId, bookingTime, guests, note);
    if (created == null) {
        request.setAttribute("errMsg", "Không thể tạo đơn đặt bàn (bàn có thể đã có khách đặt gần khung giờ này hoặc dữ liệu không hợp lệ).");
        request.setAttribute("fullName", fullName);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
        request.getRequestDispatcher("gdDatBan.jsp").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt bàn thành công - RMS</title>
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
            <strong>Đặt bàn thành công!</strong> Mã đặt bàn của bạn là <code>#RES-<%= created.getId() %></code>.
        </div>
        <div class="summary-box">
            <table class="data-table">
                <tr><th style="width: 220px;">Mã đặt bàn</th><td><code>#RES-<%= created.getId() %></code></td></tr>
                <tr><th>Khách hàng</th><td><strong><%= FormatUtil.escapeHtml(created.getCustomer().getFullName()) %></strong> — <%= FormatUtil.escapeHtml(created.getCustomer().getPhone()) %></td></tr>
                <tr><th>Bàn đã giữ</th><td><strong><%= FormatUtil.escapeHtml(created.getTable().getTableNumber()) %></strong> (Tầng <%= created.getTable().getFloor() %>, <%= created.getTable().getCapacity() %> chỗ)</td></tr>
                <tr><th>Thời gian dùng bữa</th><td><%= FormatUtil.formatDateTime(created.getBookingTime()) %> (<%= created.getNumberOfGuests() %> khách)</td></tr>
                <tr><th>Trạng thái</th><td><span class="badge badge-success"><%= FormatUtil.escapeHtml(created.getStatus()) %></span></td></tr>
            </table>
        </div>
        <div class="actions-row">
            <a href="gdChonMonOnline.jsp?resId=<%= created.getId() %>" class="btn btn-primary">Đặt món ăn Online ngay cho bàn này &rarr;</a>
            <a href="gdChinhKH.jsp" class="btn btn-secondary">Về Trang chủ Khách hàng</a>
        </div>
    </div>
</div>
</body>
</html>
