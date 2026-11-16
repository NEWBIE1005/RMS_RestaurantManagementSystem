<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.OrderOnlineDAO,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Customer kh = (Customer) session.getAttribute("khachHang");
    OrderOnlineDAO orderDAO = new OrderOnlineDAO();

    String msg = (String) session.getAttribute("histMsg");
    session.removeAttribute("histMsg");

    if ("POST".equalsIgnoreCase(request.getMethod()) && "cancelOrder".equals(request.getParameter("act"))) {
        int oId = 0;
        try { oId = Integer.parseInt(request.getParameter("orderId")); } catch (Exception ignored) {}
        if (orderDAO.updateOrderStatus(oId, "Đã hủy")) {
            session.setAttribute("histMsg", "Đã hủy đơn gọi món trực tuyến.");
        }
        String kwBack = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
        response.sendRedirect("gdLichSuDon.jsp?keyword=" + java.net.URLEncoder.encode(kwBack, "UTF-8"));
        return;
    }

    String keyword = request.getParameter("keyword");
    if (keyword == null && kh != null) {
        keyword = kh.getPhone();
    }
    if (keyword == null) keyword = "";

    ArrayList<OrderOnline> orders = new ArrayList<>();
    if (keyword.trim().length() >= 2) {
        orders = orderDAO.getOrdersByKeyword(keyword);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tra cứu &amp; Lịch sử đơn đặt món - RMS</title>
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
                <h1>Tra cứu &amp; Theo dõi đơn gọi món</h1>
                <p class="subtitle">Nhập mã đơn hàng (ORD-...) hoặc số điện thoại để kiểm tra trạng thái xử lý</p>
            </div>
            <a href="gdChinhKH.jsp" class="btn btn-secondary">Quay lại</a>
        </div>

        <% if (msg != null) { %><div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div><% } %>

        <form class="search-bar" action="gdLichSuDon.jsp" method="get">
            <input class="form-control" type="text" name="keyword" value="<%= FormatUtil.escapeHtml(keyword) %>" required placeholder="Nhập mã đơn (ORD-...) hoặc SĐT khách hàng...">
            <button type="submit" class="btn btn-primary">Tra cứu đơn</button>
        </form>

        <% if (keyword.trim().isEmpty()) { %>
            <div class="alert alert-info">Vui lòng nhập Mã đơn hoặc Số điện thoại để xem đơn hàng của bạn.</div>
        <% } else if (keyword.trim().length() < 2) { %>
            <div class="alert alert-danger">Từ khóa tra cứu phải có ít nhất 2 ký tự.</div>
        <% } else if (orders.isEmpty()) { %>
            <div class="alert alert-info">Chưa tìm thấy đơn đặt món nào khớp "<%= FormatUtil.escapeHtml(keyword) %>".</div>
        <% } else { %>
            <% for (OrderOnline ord : orders) { %>
            <div class="summary-box" style="margin-bottom: 16px;">
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                    <div>
                        <strong>Mã đơn:</strong> <code><%= FormatUtil.escapeHtml(ord.getOrderCode()) %></code> |
                        <strong>Bàn:</strong> <%= FormatUtil.escapeHtml(ord.getReservation().getTable().getTableNumber()) %> |
                        <strong>Khách:</strong> <%= FormatUtil.escapeHtml(ord.getReservation().getCustomer().getFullName()) %> |
                        <strong>Lúc:</strong> <%= FormatUtil.formatDateTime(ord.getOrderTime()) %>
                    </div>
                    <span class="badge <%= "Đã thanh toán".equals(ord.getStatus()) ? "badge-success" : ("Đã hủy".equals(ord.getStatus()) ? "badge-danger" : "badge-warn") %>">
                        <%= FormatUtil.escapeHtml(ord.getStatus()) %>
                    </span>
                </div>
                <table class="data-table" style="margin-top: 10px;">
                    <thead><tr><th>Món ăn</th><th class="text-center">SL</th><th class="text-right">Đơn giá</th><th class="text-right">Thành tiền</th></tr></thead>
                    <tbody>
                    <% if (ord.getDsMonGoi() != null) for (OrderedDish item : ord.getDsMonGoi()) { %>
                        <tr>
                            <td><%= FormatUtil.escapeHtml(item.getDish().getName()) %>
                                <% if (item.getNote() != null && !item.getNote().isEmpty()) { %>
                                    <br><small style="color:#6b7280;">Ghi chú: <%= FormatUtil.escapeHtml(item.getNote()) %></small>
                                <% } %>
                            </td>
                            <td class="text-center"><%= item.getQuantity() %></td>
                            <td class="text-right"><%= FormatUtil.formatCurrency(item.getPrice()) %></td>
                            <td class="text-right"><%= FormatUtil.formatCurrency(item.getSubTotal()) %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-top: 10px;">
                    <strong style="color:#9a3412;">Tổng cộng: <%= FormatUtil.formatCurrency(ord.getTotalAmount()) %></strong>
                    <% if ("Chờ xác nhận".equals(ord.getStatus())) { %>
                    <form action="gdLichSuDon.jsp" method="post" onsubmit="return confirm('Xác nhận hủy đơn gọi món này?');">
                        <input type="hidden" name="act" value="cancelOrder">
                        <input type="hidden" name="orderId" value="<%= ord.getId() %>">
                        <input type="hidden" name="keyword" value="<%= FormatUtil.escapeHtml(keyword) %>">
                        <button type="submit" class="btn btn-danger btn-sm">Hủy đơn chờ</button>
                    </form>
                    <% } %>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>
</div>
</body>
</html>
