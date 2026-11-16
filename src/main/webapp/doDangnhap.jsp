<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.rms.dao.UserDAO,com.rms.model.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    UserDAO userDAO = new UserDAO();
    User user = userDAO.checkLogin(username, password);
    if (user == null) {
        response.sendRedirect("gddangnhap.jsp?err=invalid");
        return;
    }

    session.removeAttribute("nvql");
    session.removeAttribute("nvbh");
    session.removeAttribute("nvkho");
    session.removeAttribute("khachHang");

    if ("MANAGEMENT".equalsIgnoreCase(user.getRole())) {
        session.setAttribute("nvql", user);
        response.sendRedirect("gdChinhNVQL.jsp");
    } else if ("SALE".equalsIgnoreCase(user.getRole())) {
        session.setAttribute("nvbh", user);
        response.sendRedirect("gdChinhNVBH.jsp");
    } else if ("WAREHOUSE".equalsIgnoreCase(user.getRole())) {
        session.setAttribute("nvkho", user);
        response.sendRedirect("gdChinhNVKho.jsp");
    } else if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
        session.setAttribute("khachHang", user);
        response.sendRedirect("gdChinhKH.jsp");
    } else {
        session.setAttribute("user", user);
        response.sendRedirect("gdChinhKH.jsp");
    }
%>
