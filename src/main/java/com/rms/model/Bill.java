package com.rms.model;

import java.io.Serializable;
import java.util.Date;

/**
 * Thực thể Hóa đơn thanh toán tại bàn.
 */
public class Bill implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String billCode;
    private OrderOnline orderOnline;
    private Staff staff;
    private Date paymentTime;
    private float totalAmount;
    private float discount;
    private float finalAmount;
    private String paymentMethod;

    public Bill() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getBillCode() { return billCode; }
    public void setBillCode(String billCode) { this.billCode = billCode; }

    public OrderOnline getOrderOnline() { return orderOnline; }
    public void setOrderOnline(OrderOnline orderOnline) { this.orderOnline = orderOnline; }

    public Staff getStaff() { return staff; }
    public void setStaff(Staff staff) { this.staff = staff; }

    public Date getPaymentTime() { return paymentTime; }
    public void setPaymentTime(Date paymentTime) { this.paymentTime = paymentTime; }

    public float getTotalAmount() { return totalAmount; }
    public void setTotalAmount(float totalAmount) { this.totalAmount = totalAmount; }

    public float getDiscount() { return discount; }
    public void setDiscount(float discount) { this.discount = discount; }

    public float getFinalAmount() { return finalAmount; }
    public void setFinalAmount(float finalAmount) { this.finalAmount = finalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
}
