<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%!
    // Helper method to parse integer safely
    private Integer parseIntSafely(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    // Helper method to set nullable integer parameter
    private void setNullableInt(PreparedStatement pstmt, int paramIndex, Integer value) throws SQLException {
        if (value != null) {
            pstmt.setInt(paramIndex, value);
        } else {
            pstmt.setNull(paramIndex, Types.INTEGER);
        }
    }
%>
<%
// Get user ID from session (assumes user is logged in)
Integer userId = (Integer) session.getAttribute("userId");

if (userId == null) {
    response.sendRedirect("../../auth/login.jsp");
    return;
}

// Get and validate parameters
Integer productId = parseIntSafely(request.getParameter("productId"));
Integer caregiverId = parseIntSafely(request.getParameter("caregiverId"));
Integer clientId = parseIntSafely(request.getParameter("clientId"));
String specialRequests = request.getParameter("specialRequests");

// Validate required parameters
if (productId == null) {
    response.sendRedirect("products.jsp?msg=invalid_product");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // Load PostgreSQL driver
    Class.forName("org.postgresql.Driver");
    
    // Establish database connection
    conn = DriverManager.getConnection(
	    "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
	    "neondb_owner",
	    "npg_6dLgQzjR9OEa"
	);
    
    // Start transaction
    conn.setAutoCommit(false);
    
    // Step 1: Get or create cart for user
    String getCartSql = "SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false";
    pstmt = conn.prepareStatement(getCartSql);
    pstmt.setInt(1, userId);
    rs = pstmt.executeQuery();
    
    int cartId;
    if (rs.next()) {
        // Cart exists
        cartId = rs.getInt("cart_id");
    } else {
        // Create new cart
        rs.close();
        pstmt.close();
        
        String createCartSql = "INSERT INTO cart (user_id, checked_out, created_at, updated_at) " +
                               "VALUES (?, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING cart_id";
        pstmt = conn.prepareStatement(createCartSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            throw new SQLException("Failed to create cart");
        }
        cartId = rs.getInt("cart_id");
    }
    
    rs.close();
    pstmt.close();
    
    // Step 2: Add item to cart
    String addItemSql = "INSERT INTO cart_item (cart_id, product_id, caregiver_id, client_id, " +
                        "special_requests, created_at, updated_at) " +
                        "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
    pstmt = conn.prepareStatement(addItemSql);
    pstmt.setInt(1, cartId);
    pstmt.setInt(2, productId);
    setNullableInt(pstmt, 3, caregiverId);
    setNullableInt(pstmt, 4, clientId);
    
    if (specialRequests != null && !specialRequests.trim().isEmpty()) {
        pstmt.setString(5, specialRequests.trim());
    } else {
        pstmt.setNull(5, Types.VARCHAR);
    }
    
    pstmt.executeUpdate();
    
    // Commit transaction
    conn.commit();
    
    // Redirect with success message
    response.sendRedirect("products.jsp?msg=added");
    
} catch (NumberFormatException e) {
    // Invalid number format
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException se) {}
    }
    response.sendRedirect("products.jsp?msg=invalid_input");
} catch (SQLException e) {
    // Database error
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException se) {}
    }
    e.printStackTrace();
    response.sendRedirect("products.jsp?msg=db_error");
} catch (Exception e) {
    // Other errors
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException se) {}
    }
    e.printStackTrace();
    response.sendRedirect("products.jsp?msg=error");
} finally {
    // Always close resources in reverse order
    if (rs != null) {
        try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
    if (pstmt != null) {
        try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
    if (conn != null) {
        try { 
            conn.setAutoCommit(true); // Reset auto-commit
            conn.close(); 
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }
}
%>