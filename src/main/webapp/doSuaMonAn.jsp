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
    } catch (Exception e) {
        request.setAttribute("errMsg", "Dữ liệu số (ID, loại món hoặc đơn giá) không hợp lệ!");
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + request.getParameter("id")).forward(request, response);
        return;
    }

    String name = request.getParameter("name");
    String unit = request.getParameter("unit");
    String status = request.getParameter("status");
    String description = request.getParameter("description");

    if (name == null || name.trim().isEmpty() || price <= 0 || unit == null || unit.trim().isEmpty()) {
        request.setAttribute("errMsg", "Tên món, đơn vị tính không được để trống và đơn giá phải > 0!");
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
        return;
    }

    DishDAO dishDAO = new DishDAO();
    if (dishDAO.checkDuplicateName(id, name)) {
        request.setAttribute("errMsg", "Tên món ăn đã tồn tại trong hệ thống, vui lòng chọn tên khác!");
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
        return;
    }

    Dish dish = dishDAO.getDishById(id);
    if (dish == null) {
        response.sendRedirect("gdTimKiemMonAn.jsp");
        return;
    }

    Category cat = new Category();
    cat.setId(categoryId);
    dish.setName(name.trim());
    dish.setPrice(price);
    dish.setUnit(unit.trim());
    dish.setStatus(status);
    dish.setDescription(description != null ? description.trim() : "");
    dish.setCategory(cat);

    boolean ok = dishDAO.updateDish(dish);
    if (ok) {
        Dish updated = dishDAO.getDishById(id);
        session.setAttribute("updatedDish", updated);
        response.sendRedirect("gdThongBao.jsp");
    } else {
        request.setAttribute("errMsg", "Cập nhật vào cơ sở dữ liệu thất bại, vui lòng thử lại!");
        request.getRequestDispatcher("gdSuaMonAn.jsp?id=" + id).forward(request, response);
    }
%>
