<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import='db.JDBC' %>
<%
Integer userId = (Integer) session.getAttribute("userId");
String cartItemIdStr = request.getParameter("cartItemId");
String quantityStr = request.getParameter("quantity");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;

try {
    int quantity = Integer.parseInt(quantityStr);
    
    // Validate quantity
    if (quantity < 1 || quantity > 99) {
        response.sendRedirect("viewCart.jsp?msg=invalid_quantity");
        return;
    }
    
    conn = JDBC.connect();
    if (conn == null) {
        throw new SQLException("Failed to connect to database using JDBC utility.");
    }

    // Start transaction
    conn.setAutoCommit(false);
    
    String sql = "UPDATE cart_item SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE cart_item_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, quantity);
    pstmt.setInt(2, Integer.parseInt(cartItemIdStr));
    pstmt.executeUpdate();
    
    response.sendRedirect("viewCart.jsp?msg=updated");
    
} catch (NumberFormatException e) {
    e.printStackTrace();
    response.sendRedirect("viewCart.jsp?msg=invalid_quantity");
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("viewCart.jsp?msg=error");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
