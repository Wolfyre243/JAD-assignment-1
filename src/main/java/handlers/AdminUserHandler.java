package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminUserHandler {

    public static java.util.List<java.util.Map<String,Object>> listUsers() throws SQLException {
        java.util.List<java.util.Map<String,Object>> users = new java.util.ArrayList<>();

        String sql = 
            "SELECT u.user_id, u.email, u.is_active, u.created_at, u.last_login, " +
            " COALESCE(STRING_AGG(r.name, ', '), 'No roles') AS roles " +
            "FROM \"user\" u " +
            "LEFT JOIN user_role ur ON u.user_id = ur.user_id " +
            "LEFT JOIN role r ON ur.role_id = r.role_id " +
            "GROUP BY u.user_id, u.email, u.is_active, u.created_at, u.last_login " +
            "ORDER BY u.user_id";

        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            while (rs.next()) {
                java.util.Map<String,Object> m = new java.util.HashMap<>();
                m.put("userId", rs.getInt("user_id"));
                m.put("email", rs.getString("email"));
                m.put("isActive", rs.getBoolean("is_active"));
                m.put("createdAt", rs.getTimestamp("created_at"));
                m.put("lastLogin", rs.getTimestamp("last_login"));
                m.put("roles", rs.getString("roles"));
                users.add(m);
            }
        }

        return users;
    }

    public static boolean setUserActive(int userId, boolean isActive) throws SQLException {
        String sql = "UPDATE \"user\" SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setBoolean(1, isActive);
            pstmt.setInt(2, userId);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        }
    }
}
