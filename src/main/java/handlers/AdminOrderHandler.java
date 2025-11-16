package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminOrderHandler {

    public static List<Map<String,Object>> listOrders() throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT o.order_id, o.created_at, u.email, COUNT(b.booking_id) AS booking_count FROM \"order\" o JOIN \"user\" u ON o.user_id = u.user_id LEFT JOIN booking b ON o.order_id = b.order_id GROUP BY o.order_id, o.created_at, u.email ORDER BY o.created_at DESC";
        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (conn == null) throw new SQLException("Connection failed");
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("orderId", rs.getInt("order_id"));
                m.put("createdAt", rs.getTimestamp("created_at"));
                m.put("email", rs.getString("email"));
                m.put("bookingCount", rs.getInt("booking_count"));
                list.add(m);
            }
        }
        return list;
    }

    public static Map<String,Object> getOrderDetails(int orderId) throws SQLException {
        String orderSql = "SELECT o.order_id, o.created_at, u.email FROM \"order\" o JOIN \"user\" u ON o.user_id = u.user_id WHERE o.order_id = ?";
        String bookingSql = "SELECT b.booking_id, p.name AS product_name, b.special_requests, b.created_at FROM booking b LEFT JOIN product p ON b.product_id = p.product_id WHERE b.order_id = ? ORDER BY b.created_at";
        try (Connection conn = JDBC.connect()) {
            if (conn == null) throw new SQLException("Connection failed");
            Map<String,Object> result = new HashMap<>();

            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    result.put("orderId", rs.getInt("order_id"));
                    result.put("createdAt", rs.getTimestamp("created_at"));
                    result.put("email", rs.getString("email"));
                }
            }

            List<Map<String,Object>> bookings = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(bookingSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> b = new HashMap<>();
                        b.put("bookingId", rs.getInt("booking_id"));
                        b.put("productName", rs.getString("product_name"));
                        b.put("specialRequests", rs.getString("special_requests"));
                        b.put("createdAt", rs.getTimestamp("created_at"));
                        bookings.add(b);
                    }
                }
            }

            result.put("bookings", bookings);
            return result;
        }
    }
}
