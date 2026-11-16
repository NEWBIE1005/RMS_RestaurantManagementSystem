package com.rms.model;

/**
 * Thực thể thống kê lượt đặt bàn và chi tiêu của khách hàng.
 */
public class CustomerStat extends Customer {
    private static final long serialVersionUID = 1L;

    private int totalReservations;
    private float totalSpent;

    public CustomerStat() {}

    public int getTotalReservations() { return totalReservations; }
    public void setTotalReservations(int totalReservations) { this.totalReservations = totalReservations; }

    public float getTotalSpent() { return totalSpent; }
    public void setTotalSpent(float totalSpent) { this.totalSpent = totalSpent; }
}
