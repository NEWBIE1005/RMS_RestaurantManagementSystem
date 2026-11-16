package com.rms.model;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Thực thể Thực đơn Combo.
 */
public class Combo implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private float discountRate;
    private float totalPrice;
    private String description;
    private ArrayList<ComboDish> dsComboDish;

    public Combo() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public float getDiscountRate() { return discountRate; }
    public void setDiscountRate(float discountRate) { this.discountRate = discountRate; }

    public float getTotalPrice() { return totalPrice; }
    public void setTotalPrice(float totalPrice) { this.totalPrice = totalPrice; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public ArrayList<ComboDish> getDsComboDish() { return dsComboDish; }
    public void setDsComboDish(ArrayList<ComboDish> dsComboDish) { this.dsComboDish = dsComboDish; }
}
