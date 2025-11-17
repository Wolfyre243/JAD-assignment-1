package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminFeedbackHandler {

    public static List<Map<String,Object>> listFeedback() throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT f.feedback_id, f.overall_rating, f.caregiver_rating, f.comments, f.created_at, u.email FROM feedback f JOIN \"user\" u ON f.user_id = u.user_id ORDER BY f.created_at DESC";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("feedbackId", rs.getInt("feedback_id"));
                m.put("overallRating", rs.getInt("overall_rating"));
                m.put("caregiverRating", rs.getObject("caregiver_rating") != null ? rs.getInt("caregiver_rating") : null);
                m.put("comments", rs.getString("comments"));
                m.put("createdAt", rs.getTimestamp("created_at"));
                m.put("email", rs.getString("email"));
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
