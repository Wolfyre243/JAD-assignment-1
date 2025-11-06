<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import='db.JDBC' %>
<%
Integer userId = (Integer) session.getAttribute("userId");
String cartIdStr = request.getParameter("cartId");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
	conn = JDBC.connect();
    if (conn == null) {
        throw new SQLException("Failed to connect to database using JDBC utility.");
    }

    // Start transaction
    conn.setAutoCommit(false);
    
    int cartId = Integer.parseInt(cartIdStr);
    
    // Create order
    String createOrderSql = "INSERT INTO \"order\" (user_id, created_at, updated_at) " +
                            "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id";
    pstmt = conn.prepareStatement(createOrderSql);
    pstmt.setInt(1, userId);
    rs = pstmt.executeQuery();
    rs.next();
    int orderId = rs.getInt("order_id");
    
    rs.close();
    pstmt.close();
    
    // Get cart items and create bookings
    String getItemsSql = "SELECT product_id, caregiver_id, client_id, special_requests " +
                         "FROM cart_item WHERE cart_id = ?";
    pstmt = conn.prepareStatement(getItemsSql);
    pstmt.setInt(1, cartId);
    rs = pstmt.executeQuery();
    
    PreparedStatement bookingStmt = conn.prepareStatement(
        "INSERT INTO booking (order_id, product_id, caregiver_id, client_id, special_requests, created_at, updated_at) " +
        "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    );
    
    while (rs.next()) {
        bookingStmt.setInt(1, orderId);
        bookingStmt.setInt(2, rs.getInt("product_id"));
        
        Integer caregiverId = (Integer) rs.getObject("caregiver_id");
        if (caregiverId != null) {
            bookingStmt.setInt(3, caregiverId);
        } else {
            bookingStmt.setNull(3, Types.INTEGER);
        }
        
        Integer clientId = (Integer) rs.getObject("client_id");
        if (clientId != null) {
            bookingStmt.setInt(4, clientId);
        } else {
            bookingStmt.setNull(4, Types.INTEGER);
        }
        
        String specialRequests = rs.getString("special_requests");
        if (specialRequests != null) {
            bookingStmt.setString(5, specialRequests);
        } else {
            bookingStmt.setNull(5, Types.VARCHAR);
        }
        
        bookingStmt.executeUpdate();
    }
    
    bookingStmt.close();
    rs.close();
    pstmt.close();
    
    // Mark cart as checked out
    String updateCartSql = "UPDATE cart SET checked_out = true, updated_at = CURRENT_TIMESTAMP WHERE cart_id = ?";
    pstmt = conn.prepareStatement(updateCartSql);
    pstmt.setInt(1, cartId);
    pstmt.executeUpdate();
    
    conn.commit();
    
    response.sendRedirect("orderConfirmation.jsp?orderId=" + orderId);
    
} catch (Exception e) {
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException se) {}
    }
    e.printStackTrace();
    response.sendRedirect("viewCart.jsp?msg=checkout_error");
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>