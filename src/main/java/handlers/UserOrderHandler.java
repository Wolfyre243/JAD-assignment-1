/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Handler for user order management including retrieving order history and order details
 */
package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class UserOrderHandler {

    /**
     * Get all orders for a specific user
     */
    public static List<Map<String, Object>> getUserOrders(int userId) throws SQLException {
        List<Map<String, Object>> orders = new ArrayList<>();
        String sql = "SELECT o.order_id, o.created_at, COUNT(b.booking_id) AS booking_count " +
                    "FROM \"order\" o " +
                    "LEFT JOIN booking b ON o.order_id = b.order_id " +
                    "WHERE o.user_id = ? " +
                    "GROUP BY o.order_id, o.created_at " +
                    "ORDER BY o.created_at DESC";
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    order.put("orderId", rs.getInt("order_id"));
                    order.put("createdAt", rs.getTimestamp("created_at"));
                    order.put("bookingCount", rs.getInt("booking_count"));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    /**
     * Get detailed information for a specific order
     */
    public static Map<String, Object> getOrderDetails(int orderId, int userId) throws SQLException {
        String orderSql = "SELECT o.order_id, o.created_at " +
                         "FROM \"order\" o " +
                         "WHERE o.order_id = ? AND o.user_id = ?";
        
        String bookingsSql = "SELECT b.booking_id, p.name AS product_name, p.price, " +
                           "b.caregiver_id, b.client_id, b.special_requests, b.booking_timeslot, b.created_at " +
                           "FROM booking b " +
                           "LEFT JOIN product p ON b.product_id = p.product_id " +
                           "WHERE b.order_id = ? " +
                           "ORDER BY b.created_at";
        
        try (Connection conn = JDBC.connect()) {
            if (conn == null) throw new SQLException("Connection failed");
            
            Map<String, Object> result = new HashMap<>();
            
            // Get order info
            try (PreparedStatement pstmt = conn.prepareStatement(orderSql)) {
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) return null; // Order not found or doesn't belong to user
                    result.put("orderId", rs.getInt("order_id"));
                    result.put("createdAt", rs.getTimestamp("created_at"));
                }
            }
            
            // Get bookings
            List<Map<String, Object>> bookings = new ArrayList<>();
            double totalAmount = 0.0;
            
            try (PreparedStatement pstmt = conn.prepareStatement(bookingsSql)) {
                pstmt.setInt(1, orderId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> booking = new HashMap<>();
                        booking.put("bookingId", rs.getInt("booking_id"));
                        booking.put("productName", rs.getString("product_name"));
                        booking.put("price", rs.getDouble("price"));
                        booking.put("caregiverId", rs.getObject("caregiver_id"));
                        booking.put("clientId", rs.getObject("client_id"));
                        booking.put("specialRequests", rs.getString("special_requests"));
                        booking.put("bookingTimeslot", rs.getTimestamp("booking_timeslot"));
                        booking.put("createdAt", rs.getTimestamp("created_at"));
                        bookings.add(booking);
                        
                        totalAmount += rs.getDouble("price");
                    }
                }
            }
            
            result.put("bookings", bookings);
            
            // Calculate totals with GST
            double subtotal = totalAmount;
            double gstAmount = subtotal * 0.09; // 9% GST
            double totalWithGST = subtotal + gstAmount;
            
            result.put("subtotal", subtotal);
            result.put("gstAmount", gstAmount);
            result.put("totalAmount", totalWithGST);
            return result;
        }
    }
}
