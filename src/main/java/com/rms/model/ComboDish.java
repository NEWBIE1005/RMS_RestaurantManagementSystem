package com.rms.model;

import java.io.Serializable;

/**
 * Thực thể Chi tiết món ăn trong Combo.
 */
public class ComboDish implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Combo combo;
    private Dish dish;
    private int quantity;

    public ComboDish() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Combo getCombo() { return combo; }
    public void setCombo(Combo combo) { this.combo = combo; }

    public Dish getDish() { return dish; }
    public void setDish(Dish dish) { this.dish = dish; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
