<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvbh = (Staff) session.getAttribute("nvbh");
    if (nvbh == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    ReservationDAO resDAO = new ReservationDAO();
    OrderOnlineDAO ordDAO = new OrderOnlineDAO();
    BillDAO billDAO = new BillDAO();
    UserDAO userDAO = new UserDAO();

    String msg = (String) session.getAttribute("saleMsg");
    String err = (String) session.getAttribute("saleErr");
    session.removeAttribute("saleMsg");
    session.removeAttribute("saleErr");

    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) tab = "orders";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String act = request.getParameter("act");
        if ("resStatus".equals(act)) {
            int resId = Integer.parseInt(request.getParameter("resId"));
            String st = request.getParameter("status");
            if (resDAO.updateReservationStatus(resId, st)) {
                session.setAttribute("saleMsg", "Đã cập nhật trạng thái đặt bàn #RES-" + resId + " -> " + st + ".");
            } else {
                session.setAttribute("saleErr", "Không thể cập nhật trạng thái đặt bàn.");
            }
            response.sendRedirect("gdChinhNVBH.jsp?tab=reservations");
            return;
        } else if ("ordStatus".equals(act)) {
            int ordId = Integer.parseInt(request.getParameter("orderId"));
            String st = request.getParameter("status");
            if (ordDAO.updateOrderStatus(ordId, st)) {
                session.setAttribute("saleMsg", "Đã cập nhật trạng thái đơn #" + ordId + " -> " + st + ".");
            } else {
                session.setAttribute("saleErr", "Không thể cập nhật trạng thái đơn.");
            }
            response.sendRedirect("gdChinhNVBH.jsp?tab=orders");
            return;
        } else if ("pay".equals(act)) {
            int ordId = Integer.parseInt(request.getParameter("orderId"));
            float discount = 0f;
            try { discount = Float.parseFloat(request.getParameter("discount")); } catch (Exception ignored) {}
            String method = request.getParameter("paymentMethod");
            Bill b = billDAO.createPaymentBill(ordId, nvbh.getId(), discount, method);
            if (b != null) {
                session.setAttribute("saleMsg", "Thanh toán thành công! Mã hóa đơn " + b.getBillCode()
                        + " — Thực thu: " + FormatUtil.formatCurrency(b.getFinalAmount()) + ".");
            } else {
                session.setAttribute("saleErr", "Thanh toán thất bại (đơn đã thanh toán/hủy hoặc dữ liệu sai).");
            }
            response.sendRedirect("gdChinhNVBH.jsp?tab=bills");
            return;
        } else if ("createMember".equals(act)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String level = request.getParameter("level");
            Customer c = userDAO.createMembershipCustomer(fullName, phone, email, address, level);
            if (c != null) {
                session.setAttribute("saleMsg", "Đã cấp thẻ thành viên " + c.getCustomerCode() + " cho khách " + c.getFullName() + ".");
            } else {
                session.setAttribute("saleErr", "Số điện thoại đã tồn tại hoặc thông tin chưa hợp lệ.");
            }
            response.sendRedirect("gdChinhNVBH.jsp?tab=members");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ Nhân viên Bán hàng - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhNVBH.jsp"><span>RMS</span> Restaurant Sale</a>
    <div class="user-info">
        <span>Xin chào, <strong><%= FormatUtil.escapeHtml(nvbh.getFullName()) %></strong> (<%= FormatUtil.escapeHtml(nvbh.getPosition()) %>)</span>
        <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Quầy Nhân viên Bán hàng &amp; Lễ tân</h1>
                <p class="subtitle">Xác nhận đặt bàn, duyệt đơn đặt món, thanh toán tại bàn và cấp thẻ thành viên</p>
            </div>
        </div>

        <% if (msg != null) { %><div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div><% } %>
        <% if (err != null) { %><div class="alert alert-danger"><%= FormatUtil.escapeHtml(err) %></div><% } %>

        <div class="actions-row" style="margin-top:0; margin-bottom:18px;">
            <a href="gdTimBanDat.jsp" class="btn btn-success">+ Đặt món Online cho bàn khách đặt</a>
            <a href="gdChinhNVBH.jsp?tab=orders" class="btn <%= "orders".equals(tab) ? "btn-primary" : "btn-secondary" %>">Đơn đặt món Online &amp; Thanh toán</a>
            <a href="gdChinhNVBH.jsp?tab=reservations" class="btn <%= "reservations".equals(tab) ? "btn-primary" : "btn-secondary" %>">Quản lý Đặt bàn</a>
            <a href="gdChinhNVBH.jsp?tab=bills" class="btn <%= "bills".equals(tab) ? "btn-primary" : "btn-secondary" %>">Hóa đơn đã thanh toán</a>
            <a href="gdChinhNVBH.jsp?tab=members" class="btn <%= "members".equals(tab) ? "btn-primary" : "btn-secondary" %>">Thẻ thành viên khách hàng</a>
        </div>

        <% if ("orders".equals(tab)) {
            ArrayList<OrderOnline> orders = ordDAO.getAllOrders("ALL");
        %>
            <% if (orders.isEmpty()) { %>
                <div class="alert alert-info">Chưa có đơn đặt món online nào.</div>
            <% } else { %>
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Bàn &amp; Khách hàng</th>
                        <th>Các món gọi</th>
                        <th class="text-right">Tổng tiền</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-center">Xử lý &amp; Thanh toán</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (OrderOnline o : orders) { %>
                    <tr>
                        <td><code><%= FormatUtil.escapeHtml(o.getOrderCode()) %></code><br><small><%= FormatUtil.formatDateTime(o.getOrderTime()) %></small></td>
                        <td><strong><%= FormatUtil.escapeHtml(o.getReservation().getTable().getTableNumber()) %></strong><br><%= FormatUtil.escapeHtml(o.getReservation().getCustomer().getFullName()) %> (<%= FormatUtil.escapeHtml(o.getReservation().getCustomer().getPhone()) %>)</td>
                        <td>
                            <% if (o.getDsMonGoi() != null) for (OrderedDish item : o.getDsMonGoi()) { %>
                                • <%= FormatUtil.escapeHtml(item.getDish().getName()) %> x<%= item.getQuantity() %><br>
                            <% } %>
                        </td>
                        <td class="text-right"><strong><%= FormatUtil.formatCurrency(o.getTotalAmount()) %></strong></td>
                        <td class="text-center"><span class="badge <%= "Đã thanh toán".equals(o.getStatus()) ? "badge-success" : ("Đã hủy".equals(o.getStatus()) ? "badge-danger" : "badge-warn") %>"><%= FormatUtil.escapeHtml(o.getStatus()) %></span></td>
                        <td class="text-center">
                            <% if ("Chờ xác nhận".equals(o.getStatus())) { %>
                                <form action="gdChinhNVBH.jsp" method="post" style="display:inline;">
                                    <input type="hidden" name="act" value="ordStatus">
                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                    <input type="hidden" name="status" value="Đã xác nhận">
                                    <button type="submit" class="btn btn-primary btn-sm">Xác nhận đơn</button>
                                </form>
                            <% } else if ("Đã xác nhận".equals(o.getStatus()) || "Đã phục vụ".equals(o.getStatus())) { %>
                                <form action="gdChinhNVBH.jsp" method="post" style="display:inline-flex; flex-direction:column; gap:4px;">
                                    <input type="hidden" name="act" value="pay">
                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                    <input class="form-control" type="number" name="discount" value="0" min="0" step="5000" placeholder="Giảm giá" style="width:110px; padding:4px; font-size:12px;">
                                    <select class="form-control" name="paymentMethod" style="width:110px; padding:4px; font-size:12px;">
                                        <option value="Tiền mặt">Tiền mặt</option>
                                        <option value="Chuyển khoản">Chuyển khoản</option>
                                        <option value="Thẻ">Thẻ</option>
                                    </select>
                                    <button type="submit" class="btn btn-success btn-sm">Thanh toán</button>
                                </form>
                            <% } else { %>
                                —
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        <% } else if ("reservations".equals(tab)) {
            ArrayList<Reservation> resList = resDAO.getAllReservations("ALL");
        %>
            <table class="data-table">
                <thead><tr><th>Mã</th><th>Khách hàng</th><th>Bàn</th><th>Giờ đặt</th><th>Số khách</th><th>Trạng thái</th><th class="text-center">Thao tác</th></tr></thead>
                <tbody>
                <% for (Reservation r : resList) { %>
                <tr>
                    <td><code>#RES-<%= r.getId() %></code></td>
                    <td><strong><%= FormatUtil.escapeHtml(r.getCustomer().getFullName()) %></strong><br><small><%= FormatUtil.escapeHtml(r.getCustomer().getPhone()) %></small></td>
                    <td><%= FormatUtil.escapeHtml(r.getTable().getTableNumber()) %></td>
                    <td><%= FormatUtil.formatDateTime(r.getBookingTime()) %></td>
                    <td class="text-center"><%= r.getNumberOfGuests() %></td>
                    <td><span class="badge badge-success"><%= FormatUtil.escapeHtml(r.getStatus()) %></span></td>
                    <td class="text-center">
                        <% if ("Chờ xác nhận".equals(r.getStatus())) { %>
                        <form action="gdChinhNVBH.jsp" method="post" style="display:inline;">
                            <input type="hidden" name="act" value="resStatus">
                            <input type="hidden" name="resId" value="<%= r.getId() %>">
                            <input type="hidden" name="status" value="Đã xác nhận">
                            <button type="submit" class="btn btn-primary btn-sm">Xác nhận</button>
                        </form>
                        <% } %>
                        <% if (!"Hoàn thành".equals(r.getStatus()) && !"Đã hủy".equals(r.getStatus())) { %>
                        <form action="gdChinhNVBH.jsp" method="post" style="display:inline;">
                            <input type="hidden" name="act" value="resStatus">
                            <input type="hidden" name="resId" value="<%= r.getId() %>">
                            <input type="hidden" name="status" value="Đã hủy">
                            <button type="submit" class="btn btn-danger btn-sm">Hủy</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } else if ("bills".equals(tab)) {
            ArrayList<Bill> bills = billDAO.getRecentBills();
        %>
            <% if (bills.isEmpty()) { %>
                <div class="alert alert-info">Chưa có hóa đơn thanh toán nào được lập.</div>
            <% } else { %>
                <table class="data-table">
                    <thead><tr><th>Mã HĐ</th><th>Mã đơn</th><th>Bàn &amp; Khách</th><th>Thu ngân</th><th>Thanh toán</th><th class="text-right">Thực thu</th></tr></thead>
                    <tbody>
                    <% for (Bill b : bills) { %>
                    <tr>
                        <td><code><%= FormatUtil.escapeHtml(b.getBillCode()) %></code><br><small><%= FormatUtil.formatDateTime(b.getPaymentTime()) %></small></td>
                        <td><%= FormatUtil.escapeHtml(b.getOrderOnline().getOrderCode()) %></td>
                        <td><%= FormatUtil.escapeHtml(b.getOrderOnline().getReservation().getTable().getTableNumber()) %> — <%= FormatUtil.escapeHtml(b.getOrderOnline().getReservation().getCustomer().getFullName()) %></td>
                        <td><%= FormatUtil.escapeHtml(b.getStaff().getFullName()) %></td>
                        <td><%= FormatUtil.escapeHtml(b.getPaymentMethod()) %></td>
                        <td class="text-right"><strong><%= FormatUtil.formatCurrency(b.getFinalAmount()) %></strong></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        <% } else {
            ArrayList<Customer> customers = userDAO.getAllCustomers();
        %>
            <div class="split-layout">
                <div>
                    <h3>Tạo thẻ thành viên mới</h3>
                    <form action="gdChinhNVBH.jsp?tab=members" method="post">
                        <input type="hidden" name="act" value="createMember">
                        <div class="form-group"><label>Họ và tên (*)</label><input class="form-control" type="text" name="fullName" required></div>
                        <div class="form-group"><label>Số điện thoại (*)</label><input class="form-control" type="text" name="phone" required></div>
                        <div class="form-group"><label>Email</label><input class="form-control" type="email" name="email"></div>
                        <div class="form-group"><label>Địa chỉ</label><input class="form-control" type="text" name="address"></div>
                        <div class="form-group"><label>Hạng thẻ ban đầu</label>
                            <select class="form-control" name="level">
                                <option value="Thành viên">Thành viên</option>
                                <option value="Bạc">Bạc</option>
                                <option value="Vàng">Vàng</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary" style="width:100%;">Cấp thẻ thành viên</button>
                    </form>
                </div>
                <div>
                    <h3>Danh sách khách hàng thành viên</h3>
                    <table class="data-table">
                        <thead><tr><th>Mã KH</th><th>Họ tên</th><th>SĐT</th><th>Hạng thẻ</th><th class="text-center">Điểm</th></tr></thead>
                        <tbody>
                        <% for (Customer c : customers) { %>
                        <tr>
                            <td><code><%= FormatUtil.escapeHtml(c.getCustomerCode()) %></code></td>
                            <td><strong><%= FormatUtil.escapeHtml(c.getFullName()) %></strong></td>
                            <td><%= FormatUtil.escapeHtml(c.getPhone()) %></td>
                            <td><span class="badge badge-warn"><%= FormatUtil.escapeHtml(c.getMembershipLevel()) %></span></td>
                            <td class="text-center"><%= c.getRewardPoints() %></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>
