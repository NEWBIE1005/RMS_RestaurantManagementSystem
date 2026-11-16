package com.rms.model;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Thực thể Loại món ăn.
 */
public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private String name;
    private String description;
    private ArrayList<Dish> dsDish;

    public Category() {}

    public Category(int id, String code, String name, String description) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public ArrayList<Dish> getDsDish() { return dsDish; }
    public void setDsDish(ArrayList<Dish> dsDish) { this.dsDish = dsDish; }
}
