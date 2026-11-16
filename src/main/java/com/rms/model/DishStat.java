package com.rms.model;

/**
 * Thực thể thống kê doanh thu và số lượng gọi món ăn.
 */
public class DishStat extends Dish {
    private static final long serialVersionUID = 1L;

    private int totalOrderedQty;
    private float totalRevenue;

    public DishStat() {}

    public int getTotalOrderedQty() { return totalOrderedQty; }
    public void setTotalOrderedQty(int totalOrderedQty) { this.totalOrderedQty = totalOrderedQty; }

    public float getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(float totalRevenue) { this.totalRevenue = totalRevenue; }
}
