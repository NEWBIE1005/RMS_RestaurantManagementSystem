package com.rms.model;

import java.io.Serializable;

/**
 * Thực thể Bàn ăn trong nhà hàng.
 */
public class Table implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String tableNumber;
    private int capacity;
    private int floor;
    private String status;
    private String description;

    public Table() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public int getFloor() { return floor; }
    public void setFloor(int floor) { this.floor = floor; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
