/*
 * Name: Karys Goh Yi Xin
 * Date: January 14, 2026
 * Description: Caregiver model for managing caregiver data with profile images
 */
package models;

import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import db.JDBC;

public class Caregiver implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int caregiverId;
    private int userId;
    private String firstName;
    private String lastName;
    private String qualifications;
    private double hourlyRate;
    private String photoUrl;
    private String profileImagePath;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    public Caregiver() {}
    
    public Caregiver(int caregiverId, String firstName, String lastName, 
                    String qualifications, double hourlyRate, String photoUrl,
                    String profileImagePath, Timestamp createdAt, Timestamp updatedAt) {
        this.caregiverId = caregiverId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.qualifications = qualifications;
        this.hourlyRate = hourlyRate;
        this.photoUrl = photoUrl;
        this.profileImagePath = profileImagePath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Constructor with userId
    public Caregiver(int caregiverId, int userId, String firstName, String lastName, 
                    String qualifications, double hourlyRate, String photoUrl,
                    String profileImagePath, Timestamp createdAt, Timestamp updatedAt) {
        this.caregiverId = caregiverId;
        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.qualifications = qualifications;
        this.hourlyRate = hourlyRate;
        this.photoUrl = photoUrl;
        this.profileImagePath = profileImagePath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    /**
     * Get all caregivers
     */
    public static List<Caregiver> getAllCaregivers() throws SQLException {
        List<Caregiver> caregivers = new ArrayList<>();
        String sql = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, photo_url, profile_image_path, created_at, updated_at FROM caregiver ORDER BY first_name, last_name";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (conn == null) throw new SQLException("Database connection failed");
            
            while (rs.next()) {
                caregivers.add(mapResultSet(rs));
            }
        }
        return caregivers;
    }
    
    /**
     * Get caregiver by ID
     */
    public static Caregiver getCaregiverById(int caregiverId) throws SQLException {
        String sql = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, photo_url, profile_image_path, created_at, updated_at FROM caregiver WHERE caregiver_id = ?";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Database connection failed");
            pstmt.setInt(1, caregiverId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * Get caregivers who provide a specific service
     */
    public static List<Caregiver> getCaregiversForService(int productId) throws SQLException {
        List<Caregiver> caregivers = new ArrayList<>();
        String sql = "SELECT c.caregiver_id, c.user_id, c.first_name, c.last_name, c.qualifications, " +
                    "c.hourly_rate, c.photo_url, c.profile_image_path, c.created_at, c.updated_at " +
                    "FROM caregiver c " +
                    "JOIN service_caregiver sc ON c.caregiver_id = sc.caregiver_id " +
                    "WHERE sc.product_id = ? AND sc.is_available = true " +
                    "ORDER BY c.first_name, c.last_name";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Database connection failed");
            pstmt.setInt(1, productId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    caregivers.add(mapResultSetFromServiceCaregiver(rs));
                }
            }
        }
        return caregivers;
    }
    
    /**
     * Map ResultSet to Caregiver object
     */
    private static Caregiver mapResultSet(ResultSet rs) throws SQLException {
        return new Caregiver(
            rs.getInt("caregiver_id"),
            rs.getInt("user_id"),
            rs.getString("first_name"),
            rs.getString("last_name"),
            rs.getString("qualifications"),
            rs.getDouble("hourly_rate"),
            rs.getString("photo_url"),
            rs.getString("profile_image_path"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at")
        );
    }
    
    /**
     * Map ResultSet to Caregiver object from service_caregiver join (uses actual schema columns)
     */
    private static Caregiver mapResultSetFromServiceCaregiver(ResultSet rs) throws SQLException {
        return new Caregiver(
            rs.getInt("caregiver_id"),
            rs.getString("first_name"),
            rs.getString("last_name"),
            rs.getString("qualifications"),
            rs.getDouble("hourly_rate"),
            null,  // photo_url - not in joined query
            rs.getString("profile_image_path"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at")
        );
    }
    
    /**
     * Get full name
     */
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    /**
     * Get profile image web path
     */
    public String getProfileImageWebPath() {
        if (profileImagePath == null || profileImagePath.trim().isEmpty()) {
            return "images/caregivers/default_profile.png";
        }
        return "images/caregivers/" + profileImagePath;
    }
    
    // Getters and Setters
    public int getCaregiverId() { return caregiverId; }
    public void setCaregiverId(int caregiverId) { this.caregiverId = caregiverId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getQualifications() { return qualifications; }
    public void setQualifications(String qualifications) { this.qualifications = qualifications; }
    
    public double getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(double hourlyRate) { this.hourlyRate = hourlyRate; }
    
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    
    public String getProfileImagePath() { return profileImagePath; }
    public void setProfileImagePath(String profileImagePath) { this.profileImagePath = profileImagePath; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}