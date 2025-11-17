package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

/**
 * CartHandler: encapsulates data access for the shopping cart so servlets remain presentation-only.
 */
public class CartHandler {

    public static Map<String, Object> getCartForUser(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> items = new ArrayList<>();
        double total = 0.0;
        int cartId = 0;

        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql =
                    "SELECT ci.cart_item_id, ci.quantity, ci.caregiver_id, ci.client_id, ci.special_requests, " +
                    "       p.product_id, p.name, p.price, c.cart_id " +
                    "FROM cart_item ci " +
                    "JOIN cart c ON ci.cart_id = c.cart_id " +
                    "JOIN product p ON ci.product_id = p.product_id " +
                    "WHERE c.user_id = ? AND c.checked_out = false " +
                    "ORDER BY ci.created_at";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("cartItemId", rs.getInt("cart_item_id"));
                item.put("productId", rs.getInt("product_id"));
                item.put("name", rs.getString("name"));
                item.put("price", rs.getDouble("price"));

                Integer qty = (Integer) rs.getObject("quantity");
                item.put("quantity", qty != null ? qty : 1);

                item.put("caregiverId", rs.getObject("caregiver_id"));
                item.put("clientId", rs.getObject("client_id"));
                item.put("specialRequests", rs.getString("special_requests"));

                items.add(item);
                total += rs.getDouble("price") * (qty != null ? qty : 1);
                cartId = rs.getInt("cart_id");
            }

            Map<String, Object> result = new HashMap<>();
            result.put("items", items);
            result.put("total", total);
            result.put("cartId", cartId);
            return result;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    public static boolean updateCartItemQuantity(int userId, int cartItemId, int quantity) throws SQLException {
        String sql = "UPDATE cart_item SET quantity = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE cart_item_id = ? " +
                     "  AND cart_id IN (SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false)";

        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            conn.setAutoCommit(false);
            pstmt.setInt(1, quantity);
            pstmt.setInt(2, cartItemId);
            pstmt.setInt(3, userId);
            int rows = pstmt.executeUpdate();
            conn.commit();
            return rows > 0;
        }
    }

    public static boolean removeCartItem(int userId, int cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_item " +
                     "WHERE cart_item_id = ? " +
                     "  AND cart_id IN (SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false)";

        try (Connection conn = JDBC.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (conn == null) throw new SQLException("Connection failed");
            conn.setAutoCommit(false);
            pstmt.setInt(1, cartItemId);
            pstmt.setInt(2, userId);
            int rows = pstmt.executeUpdate();
            conn.commit();
            return rows > 0;
        }
    }

    public static boolean addToCart(int userId, int productId, Integer caregiverId, Integer clientId, String specialRequests) throws SQLException {
        // Get or create cart, then insert item
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");
            conn.setAutoCommit(false);

            // find existing cart
            pstmt = conn.prepareStatement("SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false");
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            int cartId;
            if (rs.next()) {
                cartId = rs.getInt(1);
            } else {
                rs.close(); pstmt.close();
                pstmt = conn.prepareStatement("INSERT INTO cart (user_id, checked_out, created_at, updated_at) VALUES (?, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING cart_id");
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                if (!rs.next()) throw new SQLException("Failed to create cart");
                cartId = rs.getInt(1);
            }

            if (rs != null) { rs.close(); rs = null; }
            if (pstmt != null) { pstmt.close(); pstmt = null; }

            pstmt = conn.prepareStatement("INSERT INTO cart_item (cart_id, product_id, caregiver_id, client_id, special_requests, created_at, updated_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)");
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, productId);
            if (caregiverId != null) pstmt.setInt(3, caregiverId); else pstmt.setNull(3, Types.INTEGER);
            if (clientId != null) pstmt.setInt(4, clientId); else pstmt.setNull(4, Types.INTEGER);
            if (specialRequests != null && !specialRequests.trim().isEmpty()) pstmt.setString(5, specialRequests.trim()); else pstmt.setNull(5, Types.VARCHAR);

            pstmt.executeUpdate();
            conn.commit();
            return true;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Checkout the user's cart: create an order, copy cart items to bookings, mark cart checked_out.
     * Returns the created orderId on success.
     */
    public static int checkoutCart(int userId, int cartId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement bookingStmt = null;
        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");
            conn.setAutoCommit(false);

            // Create order
            pstmt = conn.prepareStatement("INSERT INTO \"order\" (user_id, created_at, updated_at) VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id");
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            if (!rs.next()) throw new SQLException("Failed to create order");
            int orderId = rs.getInt(1);
            rs.close(); pstmt.close();

            // Copy cart items to bookings
            pstmt = conn.prepareStatement("SELECT product_id, caregiver_id, client_id, special_requests FROM cart_item WHERE cart_id = ?");
            pstmt.setInt(1, cartId);
            rs = pstmt.executeQuery();

            bookingStmt = conn.prepareStatement("INSERT INTO booking (order_id, product_id, caregiver_id, client_id, special_requests, created_at, updated_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)");
            int itemCount = 0;
            while (rs.next()) {
                itemCount++;
                bookingStmt.setInt(1, orderId);
                bookingStmt.setInt(2, rs.getInt("product_id"));

                Integer caregiverId = (Integer) rs.getObject("caregiver_id");
                if (caregiverId != null) bookingStmt.setInt(3, caregiverId); else bookingStmt.setNull(3, Types.INTEGER);

                Integer clientId = (Integer) rs.getObject("client_id");
                if (clientId != null) bookingStmt.setInt(4, clientId); else bookingStmt.setNull(4, Types.INTEGER);

                String special = rs.getString("special_requests");
                if (special != null && !special.trim().isEmpty()) bookingStmt.setString(5, special.trim()); else bookingStmt.setNull(5, Types.VARCHAR);

                bookingStmt.executeUpdate();
            }

            if (itemCount == 0) throw new SQLException("Cart is empty");

            if (rs != null) { rs.close(); rs = null; }
            if (pstmt != null) { pstmt.close(); pstmt = null; }
            if (bookingStmt != null) { bookingStmt.close(); bookingStmt = null; }

            // Mark cart checked out
            pstmt = conn.prepareStatement("UPDATE cart SET checked_out = true, updated_at = CURRENT_TIMESTAMP WHERE cart_id = ? AND user_id = ?");
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, userId);
            int updated = pstmt.executeUpdate();
            if (updated == 0) throw new SQLException("Cart not found or not owned by user");

            conn.commit();
            return orderId;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (bookingStmt != null) try { bookingStmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }
    }
}
