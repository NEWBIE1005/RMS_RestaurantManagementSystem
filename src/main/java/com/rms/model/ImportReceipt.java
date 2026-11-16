package com.rms.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

/**
 * Thực thể Phiếu nhập nguyên liệu kho.
 */
public class ImportReceipt implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String receiptCode;
    private Supplier supplier;
    private Staff staff;
    private Date importDate;
    private float totalAmount;
    private String note;
    private ArrayList<ImportDetail> dsChiTiet;

    public ImportReceipt() {
        this.dsChiTiet = new ArrayList<>();
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getReceiptCode() { return receiptCode; }
    public void setReceiptCode(String receiptCode) { this.receiptCode = receiptCode; }

    public Supplier getSupplier() { return supplier; }
    public void setSupplier(Supplier supplier) { this.supplier = supplier; }

    public Staff getStaff() { return staff; }
    public void setStaff(Staff staff) { this.staff = staff; }

    public Date getImportDate() { return importDate; }
    public void setImportDate(Date importDate) { this.importDate = importDate; }

    public float getTotalAmount() { return totalAmount; }
    public void setTotalAmount(float totalAmount) { this.totalAmount = totalAmount; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public ArrayList<ImportDetail> getDsChiTiet() { return dsChiTiet; }
    public void setDsChiTiet(ArrayList<ImportDetail> dsChiTiet) { this.dsChiTiet = dsChiTiet; }
}
