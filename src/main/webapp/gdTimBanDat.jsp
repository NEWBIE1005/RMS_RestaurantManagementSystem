<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    User kh = (User) session.getAttribute("khachHang");
    String keyword = request.getParameter("keyword");
    if (keyword == null && kh != null && kh.getPhone() != null) {
        keyword = kh.getPhone();
    }
    ArrayList<Reservation> listBanDat = new ArrayList<>();
    boolean searched = (keyword != null && !keyword.trim().isEmpty());
    if (searched) {
        ReservationDAO resDAO = new ReservationDAO();
        listBanDat = resDAO.searchBookedTables(keyword);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tìm bàn đã đặt - Đặt món online</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Trang chủ KH</a>
        <a href="gddangnhap.jsp" class="btn btn-secondary btn-sm">Đăng nhập</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Tìm bàn đã đặt trước</h1>
                <p class="subtitle">Module 2 - Bước 2: Nhập Tên khách hàng hoặc Số điện thoại để tìm bàn đã đặt</p>
            </div>
            <a href="gdChinhKH.jsp" class="btn btn-secondary btn-sm">Quay lại</a>
        </div>

        <form class="search-bar" action="gdTimBanDat.jsp" method="get">
            <input class="form-control" type="text" name="keyword" value="<%= FormatUtil.escapeHtml(keyword) %>" placeholder="Nhập Tên khách hàng (VD: Hà Anh Khôi) hoặc Số điện thoại (VD: 0987654321)..." required>
            <button type="submit" class="btn btn-primary">Tìm bàn đặt</button>
        </form>

        <% if (!searched) { %>
            <div class="alert alert-info">Vui lòng nhập Tên khách hàng hoặc Số điện thoại đặt bàn (gợi ý: <code>0987654321</code> hoặc <code>Hà Anh Khôi</code>).</div>
        <% } else if (listBanDat.isEmpty()) { %>
            <div class="alert alert-danger">Không tìm thấy bàn đặt nào khớp với thông tin "<%= FormatUtil.escapeHtml(keyword) %>". Vui lòng kiểm tra lại hoặc đặt bàn trước!</div>
        <% } else { %>
            <table class="data-table">
                <thead>
                <tr>
                    <th class="text-center">STT</th>
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
                <% for (int i = 0; i < listBanDat.size(); i++) {
                    Reservation r = listBanDat.get(i);
                %>
                <tr>
                    <td class="text-center"><%= (i + 1) %></td>
                    <td><strong>#RES-<%= r.getId() %></strong></td>
                    <td><%= FormatUtil.escapeHtml(r.getCustomer().getFullName()) %></td>
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
