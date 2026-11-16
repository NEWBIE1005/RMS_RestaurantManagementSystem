<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.ReservationDAO,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Customer kh = (Customer) session.getAttribute("khachHang");
    String keyword = request.getParameter("keyword");
    boolean searched = (keyword != null);
    if (keyword == null && kh != null) {
        keyword = kh.getPhone();
        searched = true;
    }
    if (keyword == null) keyword = "";

    String err = null;
    ArrayList<Reservation> dsBan = new ArrayList<>();
    if (searched) {
        String cleanKw = keyword.trim();
        if (cleanKw.length() < 2) {
            err = "Vui lòng nhập ít nhất 2 ký tự Tên khách hàng hoặc Số điện thoại đặt bàn.";
        } else {
            dsBan = new ReservationDAO().searchBookedTables(cleanKw);
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tìm bàn đã đặt - RMS Restaurant Online</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <a href="gdDatBan.jsp" class="btn btn-success btn-sm">Đặt bàn mới</a>
        <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Trang chủ KH</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Tìm bàn đã đặt để gọi món Online</h1>
                <p class="subtitle">Nhập Tên khách hàng hoặc Số điện thoại đã đặt bàn để chọn bàn trước khi gọi món</p>
            </div>
            <a href="gdChinhKH.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <form class="search-bar" action="gdTimBanDat.jsp" method="get">
            <input class="form-control" type="text" name="keyword" value="<%= FormatUtil.escapeHtml(keyword) %>" required placeholder="Nhập Tên khách hàng hoặc Số điện thoại đặt bàn...">
            <button type="submit" class="btn btn-primary">Tìm bàn đặt</button>
        </form>

        <% if (err != null) { %>
            <div class="alert alert-danger"><%= FormatUtil.escapeHtml(err) %></div>
        <% } else if (!searched) { %>
            <div class="alert alert-info">Vui lòng nhập Tên hoặc Số điện thoại để tra cứu bàn đã đặt của bạn. Nếu chưa đặt bàn, bạn có thể <a href="gdDatBan.jsp"><strong>đặt bàn trực tuyến tại đây</strong></a>.</div>
        <% } else if (dsBan.isEmpty()) { %>
            <div class="alert alert-danger">Không tìm thấy đơn đặt bàn đang hoạt động nào khớp với "<strong><%= FormatUtil.escapeHtml(keyword) %></strong>".</div>
        <% } else { %>
            <table class="data-table">
                <thead>
                <tr>
                    <th class="text-center">TT</th>
                    <th>Mã đặt bàn</th>
                    <th>Khách hàng</th>
                    <th>Số điện thoại</th>
                    <th>Bàn ăn</th>
                    <th class="text-center">Số khách</th>
                    <th>Thời gian đặt</th>
                    <th class="text-center">Trạng thái</th>
                    <th class="text-center">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < dsBan.size(); i++) { Reservation r = dsBan.get(i); %>
                <tr>
                    <td class="text-center"><%= (i + 1) %></td>
                    <td><code>#RES-<%= r.getId() %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(r.getCustomer().getFullName()) %></strong></td>
                    <td><%= FormatUtil.escapeHtml(r.getCustomer().getPhone()) %></td>
                    <td><strong><%= FormatUtil.escapeHtml(r.getTable().getTableNumber()) %></strong> (Tầng <%= r.getTable().getFloor() %>)</td>
                    <td class="text-center"><%= r.getNumberOfGuests() %> người</td>
                    <td><%= FormatUtil.formatDateTime(r.getBookingTime()) %></td>
                    <td class="text-center"><span class="badge badge-success"><%= FormatUtil.escapeHtml(r.getStatus()) %></span></td>
                    <td class="text-center">
                        <a href="gdChonMonOnline.jsp?resId=<%= r.getId() %>" class="btn btn-primary btn-sm">Chọn bàn này</a>
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
