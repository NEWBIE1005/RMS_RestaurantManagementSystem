<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");

    Reservation selectedRes = (Reservation) session.getAttribute("selectedRes");
    Staff nvbh = (Staff) session.getAttribute("nvbh");
    String resIdParam = request.getParameter("resId");
    if (resIdParam != null && !resIdParam.isEmpty()) {
        try {
            int resId = Integer.parseInt(resIdParam);
            Reservation found = new ReservationDAO().getReservationById(resId);
            if (found != null) {
                selectedRes = found;
                session.setAttribute("selectedRes", selectedRes);
                session.removeAttribute("dsMonDaGoi");
            }
        } catch (Exception ignored) {}
    }

    if (selectedRes == null) {
        response.sendRedirect("gdTimBanDat.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");
    if (dsMonDaGoi == null) {
        dsMonDaGoi = new ArrayList<>();
        session.setAttribute("dsMonDaGoi", dsMonDaGoi);
    }

    String dishName = request.getParameter("dishName");
    if (dishName == null) dishName = "";
    int categoryId = 0;
    try { categoryId = Integer.parseInt(request.getParameter("categoryId")); } catch (Exception ignored) {}

    String act = request.getParameter("act");
    DishDAO dishDAO = new DishDAO();

    if ("POST".equalsIgnoreCase(request.getMethod()) || "remove".equals(act)) {
        if ("add".equals(act)) {
            int dishId = 0;
            int qty = 1;
            try { dishId = Integer.parseInt(request.getParameter("dishId")); } catch (Exception ignored) {}
            try { qty = Integer.parseInt(request.getParameter("quantity")); } catch (Exception ignored) {}
            String itemNote = request.getParameter("itemNote") != null ? request.getParameter("itemNote").trim() : "";

            if (qty <= 0 || qty > 100) {
                session.setAttribute("cartErr", "Số lượng đặt mỗi lượt phải từ 1 đến 100.");
            } else {
                Dish d = dishDAO.getDishById(dishId);
                if (d == null || !"Đang phục vụ".equalsIgnoreCase(d.getStatus())) {
                    session.setAttribute("cartErr", "Món ăn hiện tạm hết hoặc không phục vụ.");
                } else {
                    boolean existed = false;
                    for (OrderedDish item : dsMonDaGoi) {
                        if (item.getDish().getId() == dishId) {
                            item.setQuantity(Math.min(100, item.getQuantity() + qty));
                            item.setPrice(d.getPrice());
                            if (!itemNote.isEmpty()) item.setNote(itemNote);
                            existed = true;
                            break;
                        }
                    }
                    if (!existed) {
                        OrderedDish od = new OrderedDish();
                        od.setDish(d);
                        od.setQuantity(qty);
                        od.setPrice(d.getPrice());
                        od.setNote(itemNote);
                        dsMonDaGoi.add(od);
                    }
                    session.setAttribute("cartMsg", "Đã thêm \"" + d.getName() + "\" (x" + qty + ") vào danh sách món gọi.");
                }
            }
            response.sendRedirect("gdChonMonOnline.jsp?dishName=" + java.net.URLEncoder.encode(dishName, "UTF-8") + "&categoryId=" + categoryId);
            return;
        } else if ("update".equals(act)) {
            int dishId = 0;
            int qty = 1;
            try { dishId = Integer.parseInt(request.getParameter("dishId")); } catch (Exception ignored) {}
            try { qty = Integer.parseInt(request.getParameter("quantity")); } catch (Exception ignored) {}
            String itemNote = request.getParameter("itemNote") != null ? request.getParameter("itemNote").trim() : "";

            if (qty <= 0 || qty > 100) {
                session.setAttribute("cartErr", "Số lượng cập nhật phải từ 1 đến 100.");
            } else {
                for (OrderedDish item : dsMonDaGoi) {
                    if (item.getDish().getId() == dishId) {
                        item.setQuantity(qty);
                        item.setNote(itemNote);
                        session.setAttribute("cartMsg", "Đã cập nhật số lượng món \"" + item.getDish().getName() + "\".");
                        break;
                    }
                }
            }
            response.sendRedirect("gdChonMonOnline.jsp?dishName=" + java.net.URLEncoder.encode(dishName, "UTF-8") + "&categoryId=" + categoryId);
            return;
        } else if ("remove".equals(act)) {
            int remId = 0;
            try { remId = Integer.parseInt(request.getParameter("dishId")); } catch (Exception ignored) {}
            final int targetRemoveId = remId;
            dsMonDaGoi.removeIf(item -> item.getDish().getId() == targetRemoveId);
            session.setAttribute("cartMsg", "Đã xóa món ăn khỏi danh sách đã chọn.");
            response.sendRedirect("gdChonMonOnline.jsp?dishName=" + java.net.URLEncoder.encode(dishName, "UTF-8") + "&categoryId=" + categoryId);
            return;
        }
    }

    String msg = (String) session.getAttribute("cartMsg");
    String errMsg = (String) session.getAttribute("cartErr");
    session.removeAttribute("cartMsg");
    session.removeAttribute("cartErr");

    ArrayList<Category> listCategory = new CategoryDAO().getAllCategories();
    ArrayList<Dish> listMonTimThay = dishDAO.searchDish(dishName, categoryId);

    float totalAmount = 0f;
    for (OrderedDish item : dsMonDaGoi) {
        totalAmount += item.getSubTotal();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn món ăn Online - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="<%= (nvbh != null) ? "gdChinhNVBH.jsp" : "gdChinhKH.jsp" %>"><span>RMS</span> <%= (nvbh != null) ? "Restaurant Sale" : "Restaurant Online" %></a>
    <div class="user-info">
        <% if (nvbh != null) { %><span>NVBH: <strong><%= FormatUtil.escapeHtml(nvbh.getFullName()) %></strong></span> | <% } %>
        <span>Bàn đã chọn: <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong></span>
        <a href="gdTimBanDat.jsp" class="btn btn-secondary btn-sm">Đổi bàn khác</a>
    </div>
</div>

<div class="container">
    <div class="card" style="padding: 16px 24px; background: #fffbeb; border-color: #f59e0b;">
        <div>
            <strong>Thông tin bàn đã chọn:</strong>
            Mã đặt <code>#RES-<%= selectedRes.getId() %></code> |
            <strong><%= FormatUtil.escapeHtml(selectedRes.getTable().getTableNumber()) %></strong> (Tầng <%= selectedRes.getTable().getFloor() %>, <%= selectedRes.getTable().getCapacity() %> chỗ) |
            Khách hàng: <strong><%= FormatUtil.escapeHtml(selectedRes.getCustomer().getFullName()) %></strong> (<%= FormatUtil.escapeHtml(selectedRes.getCustomer().getPhone()) %>) |
            Giờ đặt: <%= FormatUtil.formatDateTime(selectedRes.getBookingTime()) %>
        </div>
    </div>

    <% if (msg != null) { %><div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div><% } %>
    <% if (errMsg != null) { %><div class="alert alert-danger"><%= FormatUtil.escapeHtml(errMsg) %></div><% } %>

    <div class="split-layout">
        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Tìm kiếm &amp; Chọn món ăn</h2>
                    <p class="subtitle">Tìm món theo tên hoặc loại món, chọn số lượng và nhấn Thêm</p>
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
                        <th class="text-center">Số lượng &amp; Thêm</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Dish d : listMonTimThay) { boolean available = "Đang phục vụ".equalsIgnoreCase(d.getStatus()); %>
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
                                <span class="badge badge-danger"><%= FormatUtil.escapeHtml(d.getStatus()) %></span>
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
                    <p class="subtitle">Có thể sửa số lượng, ghi chú từng món trước khi xác nhận</p>
                </div>
            </div>

            <% if (dsMonDaGoi.isEmpty()) { %>
                <div class="alert alert-info">Chưa có món ăn nào trong danh sách. Hãy tìm và thêm món ở bảng bên trái.</div>
            <% } else { %>
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Món ăn &amp; Ghi chú</th>
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
                        <td class="text-center">
                            <form action="gdChonMonOnline.jsp" method="post" style="display:inline-flex; flex-direction:column; gap:4px; align-items:center;">
                                <input type="hidden" name="act" value="update">
                                <input type="hidden" name="dishId" value="<%= item.getDish().getId() %>">
                                <input type="hidden" name="dishName" value="<%= FormatUtil.escapeHtml(dishName) %>">
                                <input type="hidden" name="categoryId" value="<%= categoryId %>">
                                <div style="display:flex; gap:4px;">
                                    <input class="form-control" type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" max="99" style="width:56px; padding:3px 6px;">
                                    <button type="submit" class="btn btn-secondary btn-sm" style="padding:3px 8px;">Lưu</button>
                                </div>
                                <input class="form-control" type="text" name="itemNote" value="<%= FormatUtil.escapeHtml(item.getNote()) %>" placeholder="Ghi chú món..." style="width:120px; padding:2px 6px; font-size:12px;">
                            </form>
                        </td>
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
