package com.rms.model;

import java.io.Serializable;
import java.util.Date;

/**
 * Thực thể Đơn đặt bàn trước.
 */
public class Reservation implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Customer customer;
    private Table table;
    private Date bookingTime;
    private int numberOfGuests;
    private String status;
    private String note;

    public Reservation() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public Table getTable() { return table; }
    public void setTable(Table table) { this.table = table; }

    public Date getBookingTime() { return bookingTime; }
    public void setBookingTime(Date bookingTime) { this.bookingTime = bookingTime; }

    public int getNumberOfGuests() { return numberOfGuests; }
    public void setNumberOfGuests(int numberOfGuests) { this.numberOfGuests = numberOfGuests; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
