<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.dao.*,com.rms.model.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    int id = 0;
    int categoryId = 0;
    float price = 0f;
    try {
        id = Integer.parseInt(request.getParameter("id"));
        categoryId = Integer.parseInt(request.getParameter("categoryId"));
        price = Float.parseFloat(request.getParameter("price"));
    } catch (Exception ignored) {}

    String code = request.getParameter("code") != null ? request.getParameter("code").trim() : "";
    String name = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
    String unit = request.getParameter("unit") != null ? request.getParameter("unit").trim() : "Đĩa";
    String status = request.getParameter("status") != null ? request.getParameter("status").trim() : "Đang phục vụ";
    String description = request.getParameter("description") != null ? request.getParameter("description").trim() : "";

    Category cat = new Category();
    cat.setId(categoryId);
    for (Category c : new CategoryDAO().getAllCategories()) {
        if (c.getId() == categoryId) { cat = c; break; }
    }

    Dish monan = new Dish();
    monan.setId(id);
    monan.setCode(code);
    monan.setName(name);
    monan.setCategory(cat);
    monan.setPrice(price);
    monan.setUnit(unit.isEmpty() ? "Đĩa" : unit);
    monan.setStatus(status);
    monan.setDescription(description);

    DishDAO dishDAO = new DishDAO();
    if (name.isEmpty()) {
        request.setAttribute("errMsg", "Tên món ăn không được để trống!");
        request.setAttribute("editedDish", monan);
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
        return;
    }
    if (price <= 0) {
        request.setAttribute("errMsg", "Đơn giá món ăn phải lớn hơn 0!");
        request.setAttribute("editedDish", monan);
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
        return;
    }
    if (dishDAO.checkDuplicateName(id, name)) {
        request.setAttribute("errMsg", "Tên món ăn \"" + name + "\" đã trùng với một món khác trong thực đơn!");
        request.setAttribute("editedDish", monan);
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
        return;
    }

    boolean ok = dishDAO.updateDish(monan);
    if (ok) {
        Dish reloaded = dishDAO.getDishById(id);
        session.setAttribute("updatedDish", reloaded != null ? reloaded : monan);
        session.setAttribute("flashActionTitle", "Cập nhật thông tin món ăn thành công!");
        response.sendRedirect("gdThongBao.jsp");
    } else {
        request.setAttribute("errMsg", "Cập nhật không thành công. Vui lòng thử lại!");
        request.setAttribute("editedDish", monan);
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
    }
%>
