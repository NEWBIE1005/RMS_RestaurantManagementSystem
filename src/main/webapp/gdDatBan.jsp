<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.text.SimpleDateFormat,com.rms.dao.TableDAO,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    Customer kh = (Customer) session.getAttribute("khachHang");
    String defName = (request.getAttribute("fullName") != null) ? (String) request.getAttribute("fullName") : (kh != null ? kh.getFullName() : "");
    String defPhone = (request.getAttribute("phone") != null) ? (String) request.getAttribute("phone") : (kh != null ? kh.getPhone() : "");
    String defEmail = (request.getAttribute("email") != null) ? (String) request.getAttribute("email") : (kh != null ? kh.getEmail() : "");

    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.HOUR_OF_DAY, 2);
    cal.set(Calendar.MINUTE, 0);
    String defTimeStr = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(cal.getTime());
    String bookingTimeStr = request.getParameter("bookingTimeStr");
    if (bookingTimeStr == null || bookingTimeStr.isEmpty()) bookingTimeStr = defTimeStr;

    int guests = 4;
    try { guests = Integer.parseInt(request.getParameter("guests")); } catch (Exception ignored) {}
    if (guests < 1) guests = 1;

    Date parsedTime = cal.getTime();
    try { parsedTime = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(bookingTimeStr); } catch (Exception ignored) {}

    ArrayList<Table> availTables = new TableDAO().getAvailableTables(guests, parsedTime);
    String errMsg = (String) request.getAttribute("errMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt bàn trực tuyến - RMS</title>
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
        <div class="page-header">
            <div>
                <h1>Đặt bàn trực tuyến</h1>
                <p class="subtitle">Lọc bàn trống theo khung giờ và số khách, xác nhận đặt bàn ngay</p>
            </div>
            <a href="gdChinhKH.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <% if (errMsg != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
        <% } %>

        <form class="search-bar" action="gdDatBan.jsp" method="get" style="background: #f8fafc; padding: 14px; border-radius: 8px; border: 1px solid #e5e7eb;">
            <div style="flex: 1; min-width: 190px;">
                <label style="font-size: 12.5px; font-weight: 600;">Thời gian dùng bữa:</label>
                <input class="form-control" type="datetime-local" name="bookingTimeStr" value="<%= FormatUtil.escapeHtml(bookingTimeStr) %>" required>
            </div>
            <div style="width: 150px;">
                <label style="font-size: 12.5px; font-weight: 600;">Số lượng khách:</label>
                <input class="form-control" type="number" name="guests" value="<%= guests %>" min="1" max="20" required>
            </div>
            <div style="align-self: flex-end;">
                <button type="submit" class="btn btn-secondary">Kiểm tra bàn trống</button>
            </div>
        </form>

        <form action="doDatBan.jsp" method="post">
            <input type="hidden" name="bookingTimeStr" value="<%= FormatUtil.escapeHtml(bookingTimeStr) %>">
            <input type="hidden" name="guests" value="<%= guests %>">

            <div class="form-grid">
                <div class="form-group">
                    <label for="fullName">Họ và tên khách hàng (*)</label>
                    <input class="form-control" type="text" id="fullName" name="fullName" value="<%= FormatUtil.escapeHtml(defName) %>" required placeholder="VD: Nguyễn Văn An">
                </div>
                <div class="form-group">
                    <label for="phone">Số điện thoại liên hệ (*)</label>
                    <input class="form-control" type="text" id="phone" name="phone" value="<%= FormatUtil.escapeHtml(defPhone) %>" required placeholder="VD: 0987654321">
                </div>
                <div class="form-group">
                    <label for="email">Email (tùy chọn)</label>
                    <input class="form-control" type="email" id="email" name="email" value="<%= FormatUtil.escapeHtml(defEmail) %>" placeholder="email@example.com">
                </div>
                <div class="form-group">
                    <label for="tableId">Chọn bàn phù hợp còn trống (*)</label>
                    <select class="form-control" id="tableId" name="tableId" required>
                        <% if (availTables.isEmpty()) { %>
                            <option value="">Không có bàn trống phù hợp khung giờ này</option>
                        <% } else { for (Table t : availTables) { %>
                            <option value="<%= t.getId() %>">
                                <%= FormatUtil.escapeHtml(t.getTableNumber()) %> — Tầng <%= t.getFloor() %> (<%= t.getCapacity() %> chỗ) - <%= FormatUtil.escapeHtml(t.getDescription()) %>
                            </option>
                        <% } } %>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="note">Ghi chú đặt bàn</label>
                <input class="form-control" type="text" id="note" name="note" placeholder="Ghế trẻ em, bàn yên tĩnh, sinh nhật...">
            </div>

            <div class="actions-row">
                <button type="submit" class="btn btn-success" <%= availTables.isEmpty() ? "disabled" : "" %>>Xác nhận Đặt bàn</button>
                <a href="gdTimBanDat.jsp" class="btn btn-secondary">Đã có bàn? Đặt món ngay</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
