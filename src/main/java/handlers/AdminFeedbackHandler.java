/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Handler for admin feedback management with filtering by service and caregiver
 */
package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminFeedbackHandler {

    /**
     * List all feedback (no filter)
     */
    public static List<Map<String,Object>> listFeedback() throws SQLException {
        return listFeedback(null, null);
    }

    /**
     * List feedback with optional product filter
     * @param productId - If null, returns all feedback. If not null, filters by product.
     */
    public static List<Map<String,Object>> listFeedback(Integer productId) throws SQLException {
        return listFeedback(productId, null);
    }

    /**
     * List feedback with optional product and caregiver filters
     * @param productId - If null, no product filter. If not null, filters by product.
     * @param caregiverId - If null, no caregiver filter. If not null, filters by caregiver.
     */
    public static List<Map<String,Object>> listFeedback(Integer productId, Integer caregiverId) throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT f.feedback_id, f.overall_rating, f.caregiver_rating, f.comments, f.created_at, ");
        sql.append("u.email, p.name AS product_name, f.product_id, f.caregiver_id, ");
        sql.append("CONCAT(c.first_name, ' ', c.last_name) AS caregiver_name ");
        sql.append("FROM feedback f ");
        sql.append("JOIN \"user\" u ON f.user_id = u.user_id ");
        sql.append("LEFT JOIN product p ON f.product_id = p.product_id ");
        sql.append("LEFT JOIN caregiver c ON f.caregiver_id = c.caregiver_id ");
        
        // Build WHERE clause dynamically
        List<String> conditions = new ArrayList<>();
        if (productId != null) {
            conditions.add("f.product_id = ?");
        }
        if (caregiverId != null) {
            conditions.add("f.caregiver_id = ?");
        }
        
        if (!conditions.isEmpty()) {
            sql.append("WHERE ");
            sql.append(String.join(" AND ", conditions));
            sql.append(" ");
        }
        
        sql.append("ORDER BY f.created_at DESC");
        
        try (Connection conn = JDBC.connect(); 
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            if (conn == null) throw new SQLException("Connection failed");
            
            int paramIndex = 1;
            if (productId != null) {
                pstmt.setInt(paramIndex++, productId);
            }
            if (caregiverId != null) {
                pstmt.setInt(paramIndex++, caregiverId);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("feedbackId", rs.getInt("feedback_id"));
                    m.put("overallRating", rs.getInt("overall_rating"));
                    m.put("caregiverRating", rs.getObject("caregiver_rating") != null ? rs.getInt("caregiver_rating") : null);
                    m.put("comments", rs.getString("comments"));
                    m.put("createdAt", rs.getTimestamp("created_at"));
                    m.put("email", rs.getString("email"));
                    m.put("productName", rs.getString("product_name"));
                    m.put("productId", rs.getObject("product_id"));
                    m.put("caregiverId", rs.getObject("caregiver_id"));
                    m.put("caregiverName", rs.getString("caregiver_name"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    /**
     * Get all products/services for filter dropdown
     */
    public static List<Map<String,Object>> listAllProducts() throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT product_id, name FROM product WHERE is_active = true ORDER BY name";
        
        try (Connection conn = JDBC.connect(); 
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("productId", rs.getInt("product_id"));
                m.put("name", rs.getString("name"));
                list.add(m);
            }
        }
        return list;
    }

    /**
     * Get all caregivers for filter dropdown
     */
    public static List<Map<String,Object>> listAllCaregivers() throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT caregiver_id, CONCAT(first_name, ' ', last_name) AS name " +
                    "FROM caregiver " +
                    "ORDER BY first_name, last_name";
        
        try (Connection conn = JDBC.connect(); 
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("caregiverId", rs.getInt("caregiver_id"));
                m.put("name", rs.getString("name"));
                list.add(m);
            }
        }
        return list;
    }

    public static boolean deleteFeedback(int feedbackId) throws SQLException {
        String sql = "DELETE FROM feedback WHERE feedback_id = ?";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, feedbackId);
            return pstmt.executeUpdate() > 0;
        }
    }
}
