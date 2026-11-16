package com.rms.model;

/**
 * Thực thể Nhân viên (kế thừa User).
 */
public class Staff extends User {
    private static final long serialVersionUID = 1L;

    private String staffCode;
    private String position;
    private float salary;

    public Staff() {}

    public String getStaffCode() { return staffCode; }
    public void setStaffCode(String staffCode) { this.staffCode = staffCode; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public float getSalary() { return salary; }
    public void setSalary(float salary) { this.salary = salary; }
}
