package com.rms.model;

/**
 * Thực thể Khách hàng (kế thừa User).
 */
public class Customer extends User {
    private static final long serialVersionUID = 1L;

    private String customerCode;
    private String membershipLevel;
    private int rewardPoints;

    public Customer() {}

    public String getCustomerCode() { return customerCode; }
    public void setCustomerCode(String customerCode) { this.customerCode = customerCode; }

    public String getMembershipLevel() { return membershipLevel; }
    public void setMembershipLevel(String membershipLevel) { this.membershipLevel = membershipLevel; }

    public int getRewardPoints() { return rewardPoints; }
    public void setRewardPoints(int rewardPoints) { this.rewardPoints = rewardPoints; }
}
