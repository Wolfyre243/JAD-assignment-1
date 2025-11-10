<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Securely remove cart item with user ownership validation and transaction safety
--%>
<%
    // === 1. AUTHENTICATION ===
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }

    // === 2. INPUT VALIDATION ===
    String cartItemIdStr = request.getParameter("cartItemId");
    if (cartItemIdStr == null || cartItemIdStr.trim().isEmpty()) {
        response.sendRedirect("viewCart.jsp?msg=invalid");
        return;
    }

    int cartItemId;
    try {
        cartItemId = Integer.parseInt(cartItemIdStr.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("viewCart.jsp?msg=invalid");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // Get DB connection
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Database connection failed");

        // Start transaction
        conn.setAutoCommit(false);

        // Secure DELETE: ensure item belongs to user's active cart
        pstmt = conn.prepareStatement(
            "DELETE FROM cart_item " +
            "WHERE cart_item_id = ? " +
            "  AND cart_id IN (SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false)"
        );
        pstmt.setInt(1, cartItemId);
        pstmt.setInt(2, userId);

        int rows = pstmt.executeUpdate();

        if (rows == 0) {
            // No rows deleted → item not found or not owned
            response.sendRedirect("viewCart.jsp?msg=not_found");
        } else {
            conn.commit();
            response.sendRedirect("viewCart.jsp?msg=removed");
        }

    } catch (SQLException e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        response.sendRedirect("viewCart.jsp?msg=db_error");
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        response.sendRedirect("viewCart.jsp?msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
    }
%>