<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList,java.util.Date,com.rms.dao.*,com.rms.model.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    Reservation selectedRes = (Reservation) session.getAttribute("selectedReservation");
    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");

    if (selectedRes == null || dsMonDaGoi == null || dsMonDaGoi.isEmpty()) {
        response.sendRedirect("gdTimBanDat.jsp");
        return;
    }

    String note = request.getParameter("note");
    OrderOnline order = new OrderOnline();
    order.setOrderCode("ORD-ONL-" + (System.currentTimeMillis() % 100000));
    order.setReservation(selectedRes);
    order.setOrderTime(new Date());
    order.setStatus("Chờ xác nhận");
    order.setNote(note != null ? note.trim() : "");
    order.setDsMonGoi(dsMonDaGoi);

    OrderOnlineDAO orderDAO = new OrderOnlineDAO();
    boolean saved = orderDAO.saveOrderOnline(order);
    if (saved) {
        session.setAttribute("savedOrder", order);
        session.removeAttribute("dsMonDaGoi");
        response.sendRedirect("gdThongBaoGoiMon.jsp");
    } else {
        request.setAttribute("errMsg", "Không thể lưu đơn đặt món xuống cơ sở dữ liệu. Vui lòng thử lại!");
        request.getRequestDispatcher("gdXacNhanGoiMon.jsp").forward(request, response);
    }
%>
