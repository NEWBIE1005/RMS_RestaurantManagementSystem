package com.rms.model;

import java.io.Serializable;

/**
 * Thực thể Nguyên liệu kho.
 */
public class Ingredient implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private String name;
    private String unit;
    private float unitPrice;
    private float stockQuantity;
    private float minStockThreshold;

    public Ingredient() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public float getUnitPrice() { return unitPrice; }
    public void setUnitPrice(float unitPrice) { this.unitPrice = unitPrice; }

    public float getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(float stockQuantity) { this.stockQuantity = stockQuantity; }

    public float getMinStockThreshold() { return minStockThreshold; }
    public void setMinStockThreshold(float minStockThreshold) { this.minStockThreshold = minStockThreshold; }
}
