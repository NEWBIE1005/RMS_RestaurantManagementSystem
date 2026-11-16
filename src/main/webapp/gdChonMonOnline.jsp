<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");

    String resIdParam = request.getParameter("resId");
    Reservation selectedRes = (Reservation) session.getAttribute("selectedReservation");
    if (resIdParam != null && !resIdParam.trim().isEmpty()) {
        try {
            int resId = Integer.parseInt(resIdParam);
            Reservation loaded = new ReservationDAO().getReservationById(resId);
            if (loaded != null) {
                if (selectedRes == null || selectedRes.getId() != loaded.getId()) {
                    session.setAttribute("dsMonDaGoi", new ArrayList<OrderedDish>());
                }
                selectedRes = loaded;
                session.setAttribute("selectedReservation", selectedRes);
            }
        } catch (Exception ignored) {}
    }

    if (selectedRes == null) {
        response.sendRedirect("gdTimBanDat.jsp");
        return;
    }

    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");
    if (dsMonDaGoi == null) {
        dsMonDaGoi = new ArrayList<>();
        session.setAttribute("dsMonDaGoi", dsMonDaGoi);
    }

    String msg = null;
    String errMsg = null;
    String act = request.getParameter("act");
    if ("add".equals(act)) {
        try {
            int dishId = Integer.parseInt(request.getParameter("dishId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            if (quantity <= 0) {
                errMsg = "Số lượng món phải lớn hơn 0!";
            } else {
                Dish d = new DishDAO().getDishById(dishId);
                if (d == null || !"Đang phục vụ".equalsIgnoreCase(d.getStatus())) {
                    errMsg = "Món ăn hiện không khả dụng để đặt!";
                } else {
                    boolean found = false;
                    for (OrderedDish item : dsMonDaGoi) {
                        if (item.getDish().getId() == dishId) {
                            item.setQuantity(item.getQuantity() + quantity);
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        OrderedDish item = new OrderedDish();
                        item.setDish(d);
                        item.setQuantity(quantity);
                        item.setPrice(d.getPrice());
                        item.setNote("");
                        dsMonDaGoi.add(item);
                    }
                    msg = "Đã thêm " + quantity + " " + d.getUnit() + " " + d.getName() + " vào danh sách món!";
                }
            }
        } catch (Exception e) {
            errMsg = "Dữ liệu thêm món không hợp lệ!";
        }
    } else if ("remove".equals(act)) {
        try {
            int dishId = Integer.parseInt(request.getParameter("dishId"));
            dsMonDaGoi.removeIf(item -> item.getDish().getId() == dishId);
            msg = "Đã xóa món khỏi danh sách gọi!";
        } catch (Exception ignored) {}
    }

    String dishName = request.getParameter("dishName");
    if (dishName == null) dishName = "";
    int categoryId = 0;
    try {
        if (request.getParameter("categoryId") != null) {
            categoryId = Integer.parseInt(request.getParameter("categoryId"));
        }
    } catch (Exception ignored) {}

    ArrayList<Category> listCategory = new CategoryDAO().getAllCategories();
    ArrayList<Dish> listMonTimThay = new DishDAO().searchDish(dishName, categoryId);

    float totalAmount = 0f;
    for (OrderedDish od : dsMonDaGoi) {
        totalAmount += od.getSubTotal();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn món ăn online - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhKH.jsp"><span>RMS</span> Restaurant Online</a>
    <div class="user-info">
        <span>Bàn đã chọn: <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong></span>
        <a href="gdTimBanDat.jsp" class="btn btn-secondary btn-sm">Đổi bàn khác</a>
    </div>
</div>

<div class="container">
    <div class="card" style="padding: 16px 24px; background: #fffbeb; border-color: #f59e0b;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
            <div>
                <strong>Thông tin bàn đã chọn:</strong>
                Mã đặt <code>#RES-<%= selectedRes.getId() %></code> |
                <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong> (Tầng <%= selectedRes.getTable().getFloor() %>, <%= selectedRes.getTable().getCapacity() %> chỗ) |
                Khách hàng: <strong><%= FormatUtil.escapeHtml(selectedRes.getCustomer().getFullName()) %></strong> (<%= FormatUtil.escapeHtml(selectedRes.getCustomer().getPhone()) %>) |
                Giờ đặt: <%= FormatUtil.formatDateTime(selectedRes.getBookingTime()) %>
            </div>
        </div>
    </div>

    <% if (msg != null) { %>
        <div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div>
    <% } %>
    <% if (errMsg != null) { %>
        <div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div>
    <% } %>

    <div class="split-layout">
        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Tìm kiếm & Chọn món ăn</h2>
                    <p class="subtitle">Tìm món theo tên hoặc loại món, chọn món và nhập số lượng</p>
                </div>
            </div>

            <form class="search-bar" action="gdChonMonOnline.jsp" method="get">
                <input class="form-control" type="text" name="dishName" value="<%= FormatUtil.escapeHtml(dishName) %>" placeholder="Nhập tên món (VD: Lẩu, Bò, Trà)...">
                <select class="form-control" name="categoryId" style="max-width: 190px;">
                    <option value="0">-- Tất cả loại món --</option>
                    <% for (Category cat : listCategory) { %>
                        <option value="<%= cat.getId() %>" <%= (categoryId == cat.getId()) ? "selected" : "" %>><%= FormatUtil.escapeHtml(cat.getName()) %></option>
                    <% } %>
                </select>
                <button type="submit" class="btn btn-primary">Tìm món</button>
            </form>

            <% if (listMonTimThay.isEmpty()) { %>
                <div class="alert alert-info">Không tìm thấy món ăn nào phù hợp. Vui lòng thử từ khóa hoặc loại món khác.</div>
            <% } else { %>
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Món ăn</th>
                        <th>Loại</th>
                        <th class="text-right">Đơn giá</th>
                        <th class="text-center">Số lượng & Thêm</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Dish d : listMonTimThay) {
                        boolean available = "Đang phục vụ".equalsIgnoreCase(d.getStatus());
                    %>
                    <tr>
                        <td>
                            <strong><%= FormatUtil.escapeHtml(d.getName()) %></strong><br>
                            <small style="color: #6b7280;"><%= FormatUtil.escapeHtml(d.getUnit()) %> • <%= FormatUtil.escapeHtml(d.getStatus()) %></small>
                        </td>
                        <td><%= FormatUtil.escapeHtml(d.getCategory() != null ? d.getCategory().getName() : "") %></td>
                        <td class="text-right"><strong><%= FormatUtil.formatCurrency(d.getPrice()) %></strong></td>
                        <td class="text-center">
                            <% if (available) { %>
                                <form action="gdChonMonOnline.jsp" method="post" style="display: inline-flex; gap: 6px; align-items: center;">
                                    <input type="hidden" name="act" value="add">
                                    <input type="hidden" name="dishId" value="<%= d.getId() %>">
                                    <input type="hidden" name="dishName" value="<%= FormatUtil.escapeHtml(dishName) %>">
                                    <input type="hidden" name="categoryId" value="<%= categoryId %>">
                                    <input class="form-control" type="number" name="quantity" value="1" min="1" max="99" style="width: 68px; padding: 5px 8px;">
                                    <button type="submit" class="btn btn-primary btn-sm">+ Thêm</button>
                                </form>
                            <% } else { %>
                                <span class="badge badge-danger">Tạm hết</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Danh sách món đã gọi</h2>
                    <p class="subtitle">Kiểm tra các món đã chọn trước khi xác nhận</p>
                </div>
            </div>

            <% if (dsMonDaGoi.isEmpty()) { %>
                <div class="alert alert-info">Chưa có món ăn nào trong danh sách. Hãy tìm và thêm món ở bảng bên trái.</div>
            <% } else { %>
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Tên món</th>
                        <th class="text-center">SL</th>
                        <th class="text-right">Thành tiền</th>
                        <th class="text-center">Xóa</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (OrderedDish item : dsMonDaGoi) { %>
                    <tr>
                        <td>
                            <strong><%= FormatUtil.escapeHtml(item.getDish().getName()) %></strong><br>
                            <small style="color: #6b7280;"><%= FormatUtil.formatCurrency(item.getPrice()) %> / <%= FormatUtil.escapeHtml(item.getDish().getUnit()) %></small>
                        </td>
                        <td class="text-center"><strong><%= item.getQuantity() %></strong></td>
                        <td class="text-right"><%= FormatUtil.formatCurrency(item.getSubTotal()) %></td>
                        <td class="text-center">
                            <a href="gdChonMonOnline.jsp?act=remove&dishId=<%= item.getDish().getId() %>&dishName=<%= java.net.URLEncoder.encode(dishName, "UTF-8") %>&categoryId=<%= categoryId %>" class="btn btn-danger btn-sm">X</a>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>

                <div class="total-line">
                    <span>Tổng tạm tính:</span>
                    <span><%= FormatUtil.formatCurrency(totalAmount) %></span>
                </div>

                <div class="actions-row">
                    <a href="gdXacNhanGoiMon.jsp" class="btn btn-success" style="width: 100%;">Xác nhận danh sách món &rarr;</a>
                </div>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
