package com.rms.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

/**
 * Thực thể Đơn đặt món ăn trực tuyến gắn với bàn đã đặt.
 */
public class OrderOnline implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String orderCode;
    private Reservation reservation;
    private Date orderTime;
    private float totalAmount;
    private String status;
    private String note;
    private ArrayList<OrderedDish> dsMonGoi;

    public OrderOnline() {
        this.dsMonGoi = new ArrayList<>();
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }

    public Date getOrderTime() { return orderTime; }
    public void setOrderTime(Date orderTime) { this.orderTime = orderTime; }

    public float getTotalAmount() { return totalAmount; }
    public void setTotalAmount(float totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public ArrayList<OrderedDish> getDsMonGoi() { return dsMonGoi; }
    public void setDsMonGoi(ArrayList<OrderedDish> dsMonGoi) { this.dsMonGoi = dsMonGoi; }
}
