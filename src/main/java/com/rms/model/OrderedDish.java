package com.rms.model;

import java.io.Serializable;

/**
 * Thực thể Món ăn đã chọn trong đơn gọi món online.
 */
public class OrderedDish implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Dish dish;
    private int quantity;
    private float price;
    private String note;

    public OrderedDish() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Dish getDish() { return dish; }
    public void setDish(Dish dish) { this.dish = dish; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public float getPrice() { return price; }
    public void setPrice(float price) { this.price = price; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public float getSubTotal() {
        return this.price * this.quantity;
    }
}
