package handlers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class CaregiverProfileHandler {
    
    /**
     * Get caregiver profile by ID
     */
    public static Map<String, Object> getCaregiverProfile(Connection conn, int caregiverId) throws Exception {
        String query = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, photo_url, profile_image_path, created_at, updated_at FROM caregiver WHERE caregiver_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, caregiverId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSet(rs);
            }
        }
        return null;
    }
    
    /**
     * Update caregiver profile
     */
    public static boolean updateCaregiverProfile(Connection conn, int caregiverId, String firstName, String lastName, 
                                                   String qualifications, double hourlyRate) throws Exception {
        String query = "UPDATE caregiver SET first_name = ?, last_name = ?, qualifications = ?, hourly_rate = ?, updated_at = NOW() WHERE caregiver_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, qualifications);
            pstmt.setDouble(4, hourlyRate);
            pstmt.setInt(5, caregiverId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Update caregiver profile image path
     */
    public static boolean updateProfileImagePath(Connection conn, int caregiverId, String profileImagePath) throws Exception {
        String query = "UPDATE caregiver SET profile_image_path = ?, updated_at = NOW() WHERE caregiver_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, profileImagePath);
            pstmt.setInt(2, caregiverId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Get caregiver by user ID
     */
    public static Map<String, Object> getCaregiverByUserId(Connection conn, int userId) throws Exception {
        String query = "SELECT caregiver_id, user_id, first_name, last_name, qualifications, hourly_rate, photo_url, profile_image_path, created_at, updated_at FROM caregiver WHERE user_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSet(rs);
            }
        }
        return null;
    }
    
    /**
     * Map ResultSet to Map
     */
    private static Map<String, Object> mapResultSet(ResultSet rs) throws Exception {
        Map<String, Object> caregiver = new HashMap<>();
        caregiver.put("caregiverId", rs.getInt("caregiver_id"));
        caregiver.put("userId", rs.getInt("user_id"));
        caregiver.put("firstName", rs.getString("first_name"));
        caregiver.put("lastName", rs.getString("last_name"));
        caregiver.put("qualifications", rs.getString("qualifications"));
        caregiver.put("hourlyRate", rs.getDouble("hourly_rate"));
        caregiver.put("photoUrl", rs.getString("photo_url"));
        caregiver.put("profileImagePath", rs.getString("profile_image_path"));
        caregiver.put("createdAt", rs.getTimestamp("created_at"));
        caregiver.put("updatedAt", rs.getTimestamp("updated_at"));
        return caregiver;
    }
}
