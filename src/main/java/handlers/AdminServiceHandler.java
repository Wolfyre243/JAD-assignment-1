package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

/**
 * AdminServiceHandler: encapsulates DB operations for admin product/service management.
 * Returns lists of Map<String,Object> for simplicity; can be converted to typed models later.
 */
public class AdminServiceHandler {

    public static List<Map<String, Object>> listServices() throws SQLException {
        List<Map<String, Object>> services = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.is_active, c.name AS category_name FROM product p JOIN category c ON p.category_id = c.category_id ORDER BY p.product_id";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("productId", rs.getInt("product_id"));
                m.put("name", rs.getString("name"));
                m.put("description", rs.getString("description"));
                m.put("price", rs.getDouble("price"));
                m.put("isActive", rs.getBoolean("is_active"));
                m.put("categoryName", rs.getString("category_name"));
                services.add(m);
            }
        }
        return services;
    }

    public static List<Map<String, Object>> listCategories() throws SQLException {
        List<Map<String, Object>> cats = new ArrayList<>();
        String sql = "SELECT category_id, name FROM category ORDER BY name";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("categoryId", rs.getInt("category_id"));
                m.put("name", rs.getString("name"));
                cats.add(m);
            }
        }
        return cats;
    }

    public static Map<String, Object> getServiceById(int productId) throws SQLException {
        String sql = "SELECT product_id, category_id, name, description, price, is_active FROM product WHERE product_id = ?";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) return null;
                Map<String, Object> m = new HashMap<>();
                m.put("productId", rs.getInt("product_id"));
                m.put("categoryId", rs.getInt("category_id"));
                m.put("name", rs.getString("name"));
                m.put("description", rs.getString("description"));
                m.put("price", rs.getDouble("price"));
                m.put("isActive", rs.getBoolean("is_active"));
                return m;
            }
        }
    }

    public static boolean setServiceActive(int productId, boolean active) throws SQLException {
        String sql = "UPDATE product SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setBoolean(1, active);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        }
    }

    public static boolean addService(int categoryId, String name, String description, double price, boolean isActive) throws SQLException {
        String sql = "INSERT INTO product (category_id, name, description, price, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, categoryId);
            pstmt.setString(2, name);
            if (description != null) pstmt.setString(3, description); else pstmt.setNull(3, Types.VARCHAR);
            pstmt.setDouble(4, price);
            pstmt.setBoolean(5, isActive);
            return pstmt.executeUpdate() > 0;
        }
    }

    public static boolean updateService(int productId, int categoryId, String name, String description, double price, boolean isActive) throws SQLException {
        String sql = "UPDATE product SET category_id = ?, name = ?, description = ?, price = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            pstmt.setInt(1, categoryId);
            pstmt.setString(2, name);
            if (description != null) pstmt.setString(3, description); else pstmt.setNull(3, Types.VARCHAR);
            pstmt.setDouble(4, price);
            pstmt.setBoolean(5, isActive);
            pstmt.setInt(6, productId);
            return pstmt.executeUpdate() > 0;
        }
    }
}
