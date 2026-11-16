package com.rms.model;

import java.io.Serializable;

/**
 * Thực thể Chi tiết phiếu nhập kho.
 */
public class ImportDetail implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Ingredient ingredient;
    private float quantity;
    private float importPrice;
    private float subTotal;

    public ImportDetail() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Ingredient getIngredient() { return ingredient; }
    public void setIngredient(Ingredient ingredient) { this.ingredient = ingredient; }

    public float getQuantity() { return quantity; }
    public void setQuantity(float quantity) { this.quantity = quantity; }

    public float getImportPrice() { return importPrice; }
    public void setImportPrice(float importPrice) { this.importPrice = importPrice; }

    public float getSubTotal() { return subTotal; }
    public void setSubTotal(float subTotal) { this.subTotal = subTotal; }
}
