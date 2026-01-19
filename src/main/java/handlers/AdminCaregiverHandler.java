/*
 * Name: Karys Goh Yi Xin
 * Date: January 14, 2026
 * Description: Handler for admin caregiver management operations including CRUD and image uploads
 */
package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminCaregiverHandler {

    /**
     * Get all caregivers with their details
     */
    public static List<Map<String, Object>> listCaregivers() throws SQLException {
        List<Map<String, Object>> caregivers = new ArrayList<>();
        String sql = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, " +
                    "photo_url, profile_image_path, created_at, updated_at FROM caregiver ORDER BY first_name, last_name";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (conn == null) throw new SQLException("Connection failed");
            
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("caregiverId", rs.getInt("caregiver_id"));
                m.put("userId", rs.getInt("user_id"));
                m.put("firstName", rs.getString("first_name"));
                m.put("lastName", rs.getString("last_name"));
                m.put("fullName", rs.getString("first_name") + " " + rs.getString("last_name"));
                m.put("email", "");  // Not in schema
                m.put("phoneNumber", "");  // Not in schema
                m.put("specialization", rs.getString("qualifications"));
                m.put("yearsOfExperience", "");  // Not in schema
                m.put("qualifications", rs.getString("qualifications"));
                m.put("hourlyRate", rs.getDouble("hourly_rate"));
                m.put("photoUrl", rs.getString("photo_url"));
                m.put("profileImagePath", rs.getString("profile_image_path"));
                m.put("isActive", true);  // No is_active in schema, assume all are active
                m.put("createdAt", rs.getTimestamp("created_at"));
                m.put("updatedAt", rs.getTimestamp("updated_at"));
                caregivers.add(m);
            }
        }
        return caregivers;
    }

    /**
     * Get caregiver by ID
     */
    public static Map<String, Object> getCaregiverById(int caregiverId) throws SQLException {
        String sql = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, " +
                    "photo_url, profile_image_path FROM caregiver WHERE caregiver_id = ?";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, caregiverId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("caregiverId", rs.getInt("caregiver_id"));
                    m.put("userId", rs.getInt("user_id"));
                    m.put("firstName", rs.getString("first_name"));
                    m.put("lastName", rs.getString("last_name"));
                    m.put("fullName", rs.getString("first_name") + " " + rs.getString("last_name"));
                    m.put("qualifications", rs.getString("qualifications"));
                    m.put("hourlyRate", rs.getDouble("hourly_rate"));
                    m.put("photoUrl", rs.getString("photo_url"));
                    m.put("profileImagePath", rs.getString("profile_image_path"));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Add new caregiver
     */
    public static boolean addCaregiver(String firstName, String lastName, String qualifications, 
                                     double hourlyRate, String photoUrl, String profileImagePath) throws SQLException {
        String sql = "INSERT INTO caregiver (first_name, last_name, qualifications, hourly_rate, " +
                    "photo_url, profile_image_path, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, qualifications);
            pstmt.setDouble(4, hourlyRate);
            pstmt.setString(5, photoUrl);
            pstmt.setString(6, profileImagePath);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Update caregiver
     */
    public static boolean updateCaregiver(int caregiverId, String firstName, String lastName, 
                                        String qualifications, double hourlyRate, String photoUrl,
                                        String profileImagePath) throws SQLException {
        String sql = "UPDATE caregiver SET first_name = ?, last_name = ?, qualifications = ?, " +
                    "hourly_rate = ?, photo_url = ?, profile_image_path = ?, updated_at = NOW() " +
                    "WHERE caregiver_id = ?";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, qualifications);
            pstmt.setDouble(4, hourlyRate);
            pstmt.setString(5, photoUrl);
            pstmt.setString(6, profileImagePath != null ? profileImagePath : "default_profile.png");
            pstmt.setInt(7, caregiverId);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Set caregiver active/inactive status - NOT SUPPORTED (no is_active column in schema)
     * This is a no-op for compatibility
     */
    public static boolean setCaregiverActive(int caregiverId, boolean active) throws SQLException {
        // Schema doesn't have is_active column, so this is not supported
        // All caregivers are considered active
        return true;
    }

    /**
     * Get caregivers for a specific service
     */
    public static List<Map<String, Object>> getCaregiversForService(int productId) throws SQLException {
        List<Map<String, Object>> caregivers = new ArrayList<>();
        String sql = "SELECT c.caregiver_id, c.first_name, c.last_name, " +
                    "CONCAT(c.first_name, ' ', c.last_name) AS full_name, " +
                    "c.qualifications, c.hourly_rate, c.profile_image_path, " +
                    "sc.is_available " +
                    "FROM caregiver c " +
                    "JOIN service_caregiver sc ON c.caregiver_id = sc.caregiver_id " +
                    "WHERE sc.product_id = ? " +
                    "ORDER BY c.first_name, c.last_name";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, productId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("caregiverId", rs.getInt("caregiver_id"));
                    m.put("firstName", rs.getString("first_name"));
                    m.put("lastName", rs.getString("last_name"));
                    m.put("fullName", rs.getString("full_name"));
                    m.put("specialization", rs.getString("qualifications"));
                    m.put("yearsOfExperience", "");
                    m.put("profileImagePath", rs.getString("profile_image_path"));
                    m.put("isAvailable", rs.getBoolean("is_available"));
                    m.put("isAvailable", rs.getBoolean("is_available"));
                    caregivers.add(m);
                }
            }
        }
        return caregivers;
    }

    /**
     * Assign caregiver to service
     */
    public static boolean assignCaregiverToService(int productId, int caregiverId, boolean isAvailable) throws SQLException {
        String sql = "INSERT INTO service_caregiver (product_id, caregiver_id, is_available, " +
                    "created_at, updated_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) " +
                    "ON CONFLICT (product_id, caregiver_id) DO UPDATE SET " +
                    "is_available = EXCLUDED.is_available, updated_at = CURRENT_TIMESTAMP";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, productId);
            pstmt.setInt(2, caregiverId);
            pstmt.setBoolean(3, isAvailable);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Remove caregiver from service
     */
    public static boolean removeCaregiverFromService(int productId, int caregiverId) throws SQLException {
        String sql = "DELETE FROM service_caregiver WHERE product_id = ? AND caregiver_id = ?";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, productId);
            pstmt.setInt(2, caregiverId);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Get services assigned to a caregiver
     */
    public static List<Map<String, Object>> getServicesForCaregiver(int caregiverId) throws SQLException {
        List<Map<String, Object>> services = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.description, p.price, " +
                    "sc.is_available " +
                    "FROM product p " +
                    "JOIN service_caregiver sc ON p.product_id = sc.product_id " +
                    "WHERE sc.caregiver_id = ? " +
                    "ORDER BY p.name";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, caregiverId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("productId", rs.getInt("product_id"));
                    m.put("name", rs.getString("name"));
                    m.put("description", rs.getString("description"));
                    m.put("price", rs.getDouble("price"));
                    m.put("isAvailable", rs.getBoolean("is_available"));
                    services.add(m);
                }
            }
        }
        return services;
    }

    /**
     * Delete caregiver - cascades to delete service_caregiver associations
     */
    public static boolean deleteCaregiver(int caregiverId) throws SQLException {
        try (Connection conn = JDBC.connect()) {
            if (conn == null) throw new SQLException("Connection failed");
            
            // Start transaction
            conn.setAutoCommit(false);
            
            try {
                // First, delete all service_caregiver associations for this caregiver
                String deleteServiceCaregiverSql = "DELETE FROM service_caregiver WHERE caregiver_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteServiceCaregiverSql)) {
                    pstmt.setInt(1, caregiverId);
                    pstmt.executeUpdate();
                }
                
                // Then, delete the caregiver
                String deleteCaregiverSql = "DELETE FROM caregiver WHERE caregiver_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteCaregiverSql)) {
                    pstmt.setInt(1, caregiverId);
                    int result = pstmt.executeUpdate();
                    
                    // Commit transaction only if caregiver deletion was successful
                    if (result > 0) {
                        conn.commit();
                        return true;
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }
}