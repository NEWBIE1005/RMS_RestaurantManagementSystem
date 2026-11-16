<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,com.rms.dao.OrderOnlineDAO,com.rms.model.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    Reservation selectedRes = (Reservation) session.getAttribute("selectedRes");
    @SuppressWarnings("unchecked")
    ArrayList<OrderedDish> dsMonDaGoi = (ArrayList<OrderedDish>) session.getAttribute("dsMonDaGoi");

    if (selectedRes == null || dsMonDaGoi == null || dsMonDaGoi.isEmpty()) {
        response.sendRedirect("gdChonMonOnline.jsp");
        return;
    }

    String note = request.getParameter("note");
    OrderOnline order = new OrderOnline();
    order.setOrderCode(OrderOnlineDAO.generateUniqueOrderCode());
    order.setReservation(selectedRes);
    order.setOrderTime(new Date());
    order.setStatus("Chờ xác nhận");
    order.setNote(note != null ? note.trim() : "");
    order.setDsMonGoi(dsMonDaGoi);

    OrderOnlineDAO orderDAO = new OrderOnlineDAO();
    boolean ok = orderDAO.saveOrderOnline(order);
    if (ok) {
        session.setAttribute("savedOrder", order);
        session.removeAttribute("dsMonDaGoi");
        response.sendRedirect("gdThongBaoGoiMon.jsp");
    } else {
        request.setAttribute("errMsg", "Không thể lưu đơn đặt món (kiểm tra trạng thái món ăn hoặc kết nối CSDL). Vui lòng thử lại!");
        request.getRequestDispatcher("gdXacNhanGoiMon.jsp").forward(request, response);
    }
%>
