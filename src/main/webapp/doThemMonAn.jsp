<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.dao.*,com.rms.model.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    Staff nvql = (Staff) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect("gddangnhap.jsp?err=timeout");
        return;
    }

    String code = request.getParameter("code") != null ? request.getParameter("code").trim().toUpperCase() : "";
    String name = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
    String unit = request.getParameter("unit") != null ? request.getParameter("unit").trim() : "Đĩa";
    String status = request.getParameter("status") != null ? request.getParameter("status").trim() : "Đang phục vụ";
    String description = request.getParameter("description") != null ? request.getParameter("description").trim() : "";
    int categoryId = 1;
    float price = 0f;
    try { categoryId = Integer.parseInt(request.getParameter("categoryId")); } catch (Exception ignored) {}
    try { price = Float.parseFloat(request.getParameter("price")); } catch (Exception ignored) {}

    Category cat = new Category();
    cat.setId(categoryId);
    for (Category c : new CategoryDAO().getAllCategories()) {
        if (c.getId() == categoryId) { cat = c; break; }
    }

    Dish dish = new Dish();
    dish.setCode(code);
    dish.setName(name);
    dish.setCategory(cat);
    dish.setPrice(price);
    dish.setUnit(unit.isEmpty() ? "Đĩa" : unit);
    dish.setStatus(status);
    dish.setDescription(description);

    DishDAO dishDAO = new DishDAO();
    String errMsg = null;
    if (code.isEmpty() || name.isEmpty()) {
        errMsg = "Mã món và tên món ăn không được để trống.";
    } else if (price <= 0) {
        errMsg = "Đơn giá phải lớn hơn 0 VNĐ.";
    } else if (dishDAO.checkDuplicateCode(code)) {
        errMsg = "Mã món \"" + code + "\" đã tồn tại trong thực đơn.";
    } else if (dishDAO.checkDuplicateName(0, name)) {
        errMsg = "Tên món \"" + name + "\" đã tồn tại trong thực đơn.";
    }

    if (errMsg != null) {
        request.setAttribute("errMsg", errMsg);
        request.setAttribute("draftDish", dish);
        request.getRequestDispatcher("gdThemMonAn.jsp").forward(request, response);
        return;
    }

    if (dishDAO.insertDish(dish)) {
        session.setAttribute("updatedDish", dish);
        session.setAttribute("flashActionTitle", "Thêm món ăn mới thành công!");
        response.sendRedirect("gdThongBao.jsp");
    } else {
        request.setAttribute("errMsg", "Không thể lưu món ăn mới vào CSDL. Vui lòng kiểm tra lại dữ liệu.");
        request.setAttribute("draftDish", dish);
        request.getRequestDispatcher("gdThemMonAn.jsp").forward(request, response);
    }
%>
