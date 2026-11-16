<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.*,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    ComboDAO comboDAO = new ComboDAO();
    DishDAO dishDAO = new DishDAO();
    String msg = (String) session.getAttribute("comboMsg");
    String err = (String) session.getAttribute("comboErr");
    session.removeAttribute("comboMsg");
    session.removeAttribute("comboErr");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String act = request.getParameter("act");
        if ("create".equals(act)) {
            String comboName = request.getParameter("comboName");
            String desc = request.getParameter("description");
            float discountRate = 0f;
            try { discountRate = Float.parseFloat(request.getParameter("discountRate")); } catch (Exception ignored) {}

            String[] dishIds = request.getParameterValues("dishIds");
            ArrayList<ComboDish> items = new ArrayList<>();
            if (dishIds != null) {
                for (String sId : dishIds) {
                    int dId = 0;
                    try { dId = Integer.parseInt(sId); } catch (Exception ignored) {}
                    int qty = 1;
                    try { qty = Integer.parseInt(request.getParameter("qty_" + dId)); } catch (Exception ignored) {}
                    if (dId > 0 && qty > 0) {
                        ComboDish cd = new ComboDish();
                        Dish d = new Dish();
                        d.setId(dId);
                        cd.setDish(d);
                        cd.setQuantity(qty);
                        items.add(cd);
                    }
                }
            }
            Combo c = new Combo();
            c.setName(comboName);
            c.setDiscountRate(discountRate);
            c.setDescription(desc);
            c.setDsComboDish(items);

            if (comboDAO.createCombo(c)) {
                session.setAttribute("comboMsg", "Đã tạo thành công Combo \"" + c.getName() + "\" với giá ưu đãi " + FormatUtil.formatCurrency(c.getTotalPrice()) + ".");
            } else {
                session.setAttribute("comboErr", "Vui lòng nhập tên Combo, tỷ lệ giảm giá (0-80%) và chọn ít nhất 1 món ăn.");
            }
            response.sendRedirect("gdQuanLyCombo.jsp");
            return;
        } else if ("delete".equals(act)) {
            int delId = 0;
            try { delId = Integer.parseInt(request.getParameter("comboId")); } catch (Exception ignored) {}
            if (comboDAO.deleteCombo(delId)) {
                session.setAttribute("comboMsg", "Đã xóa thực đơn Combo.");
            } else {
                session.setAttribute("comboErr", "Không thể xóa Combo.");
            }
            response.sendRedirect("gdQuanLyCombo.jsp");
            return;
        }
    }

    ArrayList<Dish> allDishes = dishDAO.searchDish("", 0);
    ArrayList<Combo> combos = comboDAO.getAllCombos();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Thực đơn Combo - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhNVQL.jsp"><span>RMS</span> Restaurant Management</a>
    <div class="user-info">
        <span><%= FormatUtil.escapeHtml(nvql.getFullName()) %></span>
        <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <% if (msg != null) { %><div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div><% } %>
    <% if (err != null) { %><div class="alert alert-danger"><%= FormatUtil.escapeHtml(err) %></div><% } %>

    <div class="split-layout">
        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Tạo Thực đơn Combo mới</h2>
                    <p class="subtitle">Chọn các món thành phần và tỷ lệ giảm giá (%) so với gọi lẻ</p>
                </div>
                <a href="gdChinhNVQL.jsp" class="btn btn-secondary btn-sm">Trang chủ</a>
            </div>

            <form action="gdQuanLyCombo.jsp" method="post">
                <input type="hidden" name="act" value="create">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="comboName">Tên Combo (*)</label>
                        <input class="form-control" type="text" id="comboName" name="comboName" required placeholder="VD: Combo Gia Đình 4 Người">
                    </div>
                    <div class="form-group">
                        <label for="discountRate">Giảm giá (%)</label>
                        <input class="form-control" type="number" id="discountRate" name="discountRate" min="0" max="80" value="15" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="description">Mô tả Combo</label>
                    <input class="form-control" type="text" id="description" name="description" placeholder="Gợi ý cho nhóm khách hàng...">
                </div>

                <label style="font-weight: 600; font-size: 13.5px;">Chọn món trong Combo:</label>
                <div style="max-height: 300px; overflow-y: auto; border: 1px solid #e5e7eb; border-radius: 8px; margin-top: 6px;">
                    <table class="data-table" style="margin-top: 0;">
                        <thead>
                        <tr>
                            <th class="text-center">Chọn</th>
                            <th>Tên món</th>
                            <th class="text-right">Đơn giá</th>
                            <th class="text-center">SL</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Dish d : allDishes) { if ("Ngừng phục vụ".equalsIgnoreCase(d.getStatus())) continue; %>
                        <tr>
                            <td class="text-center"><input type="checkbox" name="dishIds" value="<%= d.getId() %>"></td>
                            <td><%= FormatUtil.escapeHtml(d.getName()) %></td>
                            <td class="text-right"><%= FormatUtil.formatCurrency(d.getPrice()) %></td>
                            <td class="text-center">
                                <input class="form-control" type="number" name="qty_<%= d.getId() %>" value="1" min="1" max="10" style="width: 60px; padding: 4px 6px;">
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <div class="actions-row">
                    <button type="submit" class="btn btn-primary" style="width: 100%;">Lưu Thực đơn Combo</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="page-header">
                <div>
                    <h2>Danh sách Combo hiện có (<%= combos.size() %>)</h2>
                    <p class="subtitle">Các gói Combo đang áp dụng tại nhà hàng</p>
                </div>
            </div>
            <% if (combos.isEmpty()) { %>
                <div class="alert alert-info">Chưa có gói Combo nào.</div>
            <% } else { %>
                <% for (Combo c : combos) { %>
                <div class="summary-box" style="margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <strong style="font-size: 15px;"><%= FormatUtil.escapeHtml(c.getName()) %></strong>
                            <span class="badge badge-success">Giảm <%= Math.round(c.getDiscountRate()) %>%</span>
                        </div>
                        <strong style="color: #9a3412;"><%= FormatUtil.formatCurrency(c.getTotalPrice()) %></strong>
                    </div>
                    <p style="margin: 6px 0; font-size: 13px; color: #4b5563;"><%= FormatUtil.escapeHtml(c.getDescription()) %></p>
                    <ul style="margin: 6px 0 8px 18px; padding: 0; font-size: 13px;">
                        <% if (c.getDsComboDish() != null) for (ComboDish cd : c.getDsComboDish()) { %>
                            <li><%= FormatUtil.escapeHtml(cd.getDish().getName()) %> x <%= cd.getQuantity() %></li>
                        <% } %>
                    </ul>
                    <form action="gdQuanLyCombo.jsp" method="post" onsubmit="return confirm('Xóa Combo này?');">
                        <input type="hidden" name="act" value="delete">
                        <input type="hidden" name="comboId" value="<%= c.getId() %>">
                        <button type="submit" class="btn btn-danger btn-sm">Xóa Combo</button>
                    </form>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
