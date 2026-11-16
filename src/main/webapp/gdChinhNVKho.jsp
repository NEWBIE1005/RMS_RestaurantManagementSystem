<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.text.SimpleDateFormat,com.rms.dao.WarehouseDAO,com.rms.model.*,com.rms.util.FormatUtil"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvkho = (Staff) session.getAttribute("nvkho");
    if (nvkho == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    WarehouseDAO whDAO = new WarehouseDAO();
    String msg = (String) session.getAttribute("whMsg");
    String err = (String) session.getAttribute("whErr");
    session.removeAttribute("whMsg");
    session.removeAttribute("whErr");

    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) tab = "import";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String act = request.getParameter("act");
        if ("addSupplier".equals(act)) {
            Supplier sup = new Supplier();
            sup.setName(request.getParameter("name"));
            sup.setPhone(request.getParameter("phone"));
            sup.setAddress(request.getParameter("address"));
            sup.setEmail(request.getParameter("email"));
            sup.setTaxCode(request.getParameter("taxCode"));
            if (whDAO.addSupplier(sup)) {
                session.setAttribute("whMsg", "Đã thêm nhà cung cấp \"" + sup.getName() + "\".");
            } else {
                session.setAttribute("whErr", "Vui lòng nhập đầy đủ Tên và Số điện thoại nhà cung cấp.");
            }
            response.sendRedirect("gdChinhNVKho.jsp?tab=suppliers");
            return;
        } else if ("createImport".equals(act)) {
            int supId = 0;
            int ingId = 0;
            float qty = 0f;
            float price = 0f;
            try { supId = Integer.parseInt(request.getParameter("supplierId")); } catch (Exception ignored) {}
            try { ingId = Integer.parseInt(request.getParameter("ingredientId")); } catch (Exception ignored) {}
            try { qty = Float.parseFloat(request.getParameter("quantity")); } catch (Exception ignored) {}
            try { price = Float.parseFloat(request.getParameter("importPrice")); } catch (Exception ignored) {}

            ImportReceipt receipt = new ImportReceipt();
            receipt.setReceiptCode("PN-" + new SimpleDateFormat("yyMMddHHmmss").format(new Date()));
            Supplier s = new Supplier(); s.setId(supId);
            receipt.setSupplier(s);
            receipt.setStaff(nvkho);
            receipt.setImportDate(new Date());
            receipt.setNote(request.getParameter("note"));

            ImportDetail detail = new ImportDetail();
            Ingredient ing = new Ingredient(); ing.setId(ingId);
            detail.setIngredient(ing);
            detail.setQuantity(qty);
            detail.setImportPrice(price);
            receipt.getDsChiTiet().add(detail);

            if (whDAO.createImportReceipt(receipt)) {
                session.setAttribute("whMsg", "Đã lập phiếu nhập " + receipt.getReceiptCode()
                        + " (" + FormatUtil.formatCurrency(receipt.getTotalAmount()) + ") và cộng tồn kho.");
            } else {
                session.setAttribute("whErr", "Không thể lập phiếu nhập. Kiểm tra số lượng và đơn giá > 0.");
            }
            response.sendRedirect("gdChinhNVKho.jsp?tab=import");
            return;
        }
    }

    ArrayList<Ingredient> ingredients = whDAO.getAllIngredients();
    ArrayList<Supplier> suppliers = whDAO.getAllSuppliers();
    ArrayList<ImportReceipt> receipts = whDAO.getRecentReceipts();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ Nhân viên Kho - RMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="gdChinhNVKho.jsp"><span>RMS</span> Restaurant Warehouse</a>
    <div class="user-info">
        <span>Xin chào, <strong><%= FormatUtil.escapeHtml(nvkho.getFullName()) %></strong> (<%= FormatUtil.escapeHtml(nvkho.getPosition()) %>)</span>
        <a href="dangxuat.jsp" class="btn btn-secondary btn-sm">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="page-header">
            <div>
                <h1>Quản lý Kho nguyên liệu &amp; Nhà cung cấp</h1>
                <p class="subtitle">Nhập nguyên liệu từ nhà cung cấp, theo dõi tồn kho và quản lý đối tác cung ứng</p>
            </div>
        </div>

        <% if (msg != null) { %><div class="alert alert-success"><%= FormatUtil.escapeHtml(msg) %></div><% } %>
        <% if (err != null) { %><div class="alert alert-danger"><%= FormatUtil.escapeHtml(err) %></div><% } %>

        <div class="actions-row" style="margin-top:0; margin-bottom:18px;">
            <a href="gdChinhNVKho.jsp?tab=import" class="btn <%= "import".equals(tab) ? "btn-primary" : "btn-secondary" %>">Nhập kho &amp; Tồn kho</a>
            <a href="gdChinhNVKho.jsp?tab=suppliers" class="btn <%= "suppliers".equals(tab) ? "btn-primary" : "btn-secondary" %>">Quản lý Nhà cung cấp</a>
        </div>

        <% if ("import".equals(tab)) { %>
            <div class="split-layout">
                <div>
                    <h3>Tạo phiếu nhập nguyên liệu</h3>
                    <form action="gdChinhNVKho.jsp" method="post">
                        <input type="hidden" name="act" value="createImport">
                        <div class="form-group"><label>Nhà cung cấp</label>
                            <select class="form-control" name="supplierId">
                                <% for (Supplier s : suppliers) { %>
                                    <option value="<%= s.getId() %>"><%= FormatUtil.escapeHtml(s.getName()) %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group"><label>Nguyên liệu</label>
                            <select class="form-control" name="ingredientId">
                                <% for (Ingredient i : ingredients) { %>
                                    <option value="<%= i.getId() %>"><%= FormatUtil.escapeHtml(i.getName()) %> (<%= FormatUtil.escapeHtml(i.getUnit()) %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-grid">
                            <div class="form-group"><label>Số lượng nhập</label><input class="form-control" type="number" step="0.5" min="0.5" name="quantity" value="5" required></div>
                            <div class="form-group"><label>Đơn giá nhập (VNĐ)</label><input class="form-control" type="number" step="1000" min="1000" name="importPrice" value="180000" required></div>
                        </div>
                        <div class="form-group"><label>Ghi chú</label><input class="form-control" type="text" name="note" placeholder="Lô hàng tươi trong ngày..."></div>
                        <button type="submit" class="btn btn-primary" style="width:100%;">Lưu phiếu nhập &amp; Cập nhật kho</button>
                    </form>
                </div>
                <div>
                    <h3>Tồn kho nguyên liệu hiện tại</h3>
                    <table class="data-table">
                        <thead><tr><th>Mã</th><th>Tên nguyên liệu</th><th class="text-right">Tồn kho</th><th class="text-right">Giá nhập</th><th class="text-center">Tình trạng</th></tr></thead>
                        <tbody>
                        <% for (Ingredient i : ingredients) { boolean low = i.getStockQuantity() <= i.getMinStockThreshold(); %>
                        <tr>
                            <td><code><%= FormatUtil.escapeHtml(i.getCode()) %></code></td>
                            <td><strong><%= FormatUtil.escapeHtml(i.getName()) %></strong> (<%= FormatUtil.escapeHtml(i.getUnit()) %>)</td>
                            <td class="text-right"><strong><%= i.getStockQuantity() %></strong></td>
                            <td class="text-right"><%= FormatUtil.formatCurrency(i.getUnitPrice()) %></td>
                            <td class="text-center"><span class="badge <%= low ? "badge-danger" : "badge-success" %>"><%= low ? "Thấp" : "Đủ" %></span></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% if (!receipts.isEmpty()) { %>
            <h3 style="margin-top: 22px;">Phiếu nhập kho gần đây</h3>
            <table class="data-table">
                <thead><tr><th>Mã phiếu</th><th>Nhà cung cấp</th><th>NV lập</th><th>Thời gian</th><th class="text-right">Tổng tiền</th></tr></thead>
                <tbody>
                <% for (ImportReceipt ir : receipts) { %>
                <tr>
                    <td><code><%= FormatUtil.escapeHtml(ir.getReceiptCode()) %></code></td>
                    <td><%= FormatUtil.escapeHtml(ir.getSupplier().getName()) %></td>
                    <td><%= FormatUtil.escapeHtml(ir.getStaff().getFullName()) %></td>
                    <td><%= FormatUtil.formatDateTime(ir.getImportDate()) %></td>
                    <td class="text-right"><strong><%= FormatUtil.formatCurrency(ir.getTotalAmount()) %></strong></td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        <% } else { %>
            <div class="split-layout">
                <div>
                    <h3>Thêm Nhà cung cấp mới</h3>
                    <form action="gdChinhNVKho.jsp?tab=suppliers" method="post">
                        <input type="hidden" name="act" value="addSupplier">
                        <div class="form-group"><label>Tên Nhà cung cấp (*)</label><input class="form-control" type="text" name="name" required></div>
                        <div class="form-group"><label>Số điện thoại (*)</label><input class="form-control" type="text" name="phone" required></div>
                        <div class="form-group"><label>Địa chỉ</label><input class="form-control" type="text" name="address"></div>
                        <div class="form-group"><label>Email</label><input class="form-control" type="email" name="email"></div>
                        <div class="form-group"><label>Mã số thuế</label><input class="form-control" type="text" name="taxCode"></div>
                        <button type="submit" class="btn btn-primary" style="width:100%;">Lưu Nhà cung cấp</button>
                    </form>
                </div>
                <div>
                    <h3>Danh sách Nhà cung cấp (<%= suppliers.size() %>)</h3>
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Tên đối tác</th><th>SĐT</th><th>Địa chỉ</th><th>MST</th></tr></thead>
                        <tbody>
                        <% for (Supplier s : suppliers) { %>
                        <tr>
                            <td>#<%= s.getId() %></td>
                            <td><strong><%= FormatUtil.escapeHtml(s.getName()) %></strong></td>
                            <td><%= FormatUtil.escapeHtml(s.getPhone()) %></td>
                            <td><%= FormatUtil.escapeHtml(s.getAddress()) %></td>
                            <td><code><%= FormatUtil.escapeHtml(s.getTaxCode()) %></code></td>
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
