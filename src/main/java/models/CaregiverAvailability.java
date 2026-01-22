/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
*/

package models;

import java.sql.*;
import java.util.ArrayList;

public class CaregiverAvailability {
    private int availabilityId;
    private int caregiverId;
    private int productId;
    private Date availabilityDate;
    private Time startTime;
    private Time endTime;

    public CaregiverAvailability(int availabilityId, int caregiverId, int productId, Date availabilityDate, Time startTime, Time endTime) {
        this.availabilityId = availabilityId;
        this.caregiverId = caregiverId;
        this.productId = productId;
        this.availabilityDate = availabilityDate;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public int getAvailabilityId() { return availabilityId; }
    public int getCaregiverId() { return caregiverId; }
    public int getProductId() { return productId; }
    public Date getAvailabilityDate() { return availabilityDate; }
    public Time getStartTime() { return startTime; }
    public Time getEndTime() { return endTime; }

    public static ArrayList<CaregiverAvailability> getAvailableTimeslots(int productId, Date date) throws SQLException {
        ArrayList<CaregiverAvailability> slots = new ArrayList<>();
        Connection conn = db.JDBC.connect();
        String sql = "SELECT * FROM caregiver_availability WHERE product_id = ? AND availability_date = ? ORDER BY start_time, end_time";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setDate(2, date);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                slots.add(new CaregiverAvailability(
                    rs.getInt("availability_id"),
                    rs.getInt("caregiver_id"),
                    rs.getInt("product_id"),
                    rs.getDate("availability_date"),
                    rs.getTime("start_time"),
                    rs.getTime("end_time")
                ));
            }
        }
        return slots;
    }

    public static ArrayList<CaregiverAvailability> getByCaregiver(int caregiverId) throws SQLException {
        ArrayList<CaregiverAvailability> slots = new ArrayList<>();
        Connection conn = db.JDBC.connect();
        String sql = "SELECT * FROM caregiver_availability WHERE caregiver_id = ? ORDER BY availability_date DESC, start_time";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, caregiverId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                slots.add(new CaregiverAvailability(
                    rs.getInt("availability_id"),
                    rs.getInt("caregiver_id"),
                    rs.getInt("product_id"),
                    rs.getDate("availability_date"),
                    rs.getTime("start_time"),
                    rs.getTime("end_time")
                ));
            }
        }
        return slots;
    }

    public static boolean deleteById(int availabilityId, int caregiverId) throws SQLException {
        Connection conn = db.JDBC.connect();
        String sql = "DELETE FROM caregiver_availability WHERE availability_id = ? AND caregiver_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, availabilityId);
            ps.setInt(2, caregiverId);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    public static boolean updateAvailability(int availabilityId, int caregiverId, Date date, Time startTime, Time endTime) throws SQLException {
        Connection conn = db.JDBC.connect();
        String sql = "UPDATE caregiver_availability SET availability_date = ?, start_time = ?, end_time = ?, updated_at = CURRENT_TIMESTAMP WHERE availability_id = ? AND caregiver_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setTime(2, startTime);
            ps.setTime(3, endTime);
            ps.setInt(4, availabilityId);
            ps.setInt(5, caregiverId);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }
}
