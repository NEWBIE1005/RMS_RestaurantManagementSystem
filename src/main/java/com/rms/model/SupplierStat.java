package com.rms.model;

/**
 * Thực thể thống kê số lần nhập hàng và giá trị cung cấp của nhà cung cấp.
 */
public class SupplierStat extends Supplier {
    private static final long serialVersionUID = 1L;

    private int totalReceipts;
    private float totalSupplyValue;

    public SupplierStat() {}

    public int getTotalReceipts() { return totalReceipts; }
    public void setTotalReceipts(int totalReceipts) { this.totalReceipts = totalReceipts; }

    public float getTotalSupplyValue() { return totalSupplyValue; }
    public void setTotalSupplyValue(float totalSupplyValue) { this.totalSupplyValue = totalSupplyValue; }
}
