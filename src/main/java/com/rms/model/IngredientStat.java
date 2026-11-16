package com.rms.model;

/**
 * Thực thể thống kê tồn kho và nhập nguyên liệu.
 */
public class IngredientStat extends Ingredient {
    private static final long serialVersionUID = 1L;

    private float totalImportedQty;
    private float totalImportCost;

    public IngredientStat() {}

    public float getTotalImportedQty() { return totalImportedQty; }
    public void setTotalImportedQty(float totalImportedQty) { this.totalImportedQty = totalImportedQty; }

    public float getTotalImportCost() { return totalImportCost; }
    public void setTotalImportCost(float totalImportCost) { this.totalImportCost = totalImportCost; }
}
