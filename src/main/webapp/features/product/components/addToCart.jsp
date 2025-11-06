<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
/* ======================================
Author: Goh Yi Xin Karys (DIT-2B-01, P2424431)
Last Edited: 06/11/2025
Description: Secure cart addition with session auth and DB transaction
======================================= */
--%>
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
    // -------------------------------------------------
    // 1. AUTHENTICATION (session set by AuthServlet)
    // -------------------------------------------------
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }

    // -------------------------------------------------
    // 2. INPUT PARAMETERS
    // -------------------------------------------------
    Integer productId = parseIntSafely(request.getParameter("productId"));
    Integer caregiverId = parseIntSafely(request.getParameter("caregiverId"));
    Integer clientId = parseIntSafely(request.getParameter("clientId"));
    String specialRequests = request.getParameter("specialRequests");

    // -------------------------------------------------
    // 3. VALIDATION
    // -------------------------------------------------
    if (productId == null) {
        response.sendRedirect("products.jsp?msg=invalid_product");
        return;
    }

    // -------------------------------------------------
    // 4. DATABASE: Get/Create Cart + Add Item
    // -------------------------------------------------
    String redirectMsg = "added";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        conn.setAutoCommit(false);

        // --- Step 1: Get or create cart ---
        pstmt = conn.prepareStatement(
            "SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false"
        );
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        int cartId;
        if (rs.next()) {
            cartId = rs.getInt(1);
        } else {
            rs.close();
            pstmt.close();

            pstmt = conn.prepareStatement(
                "INSERT INTO cart (user_id, checked_out, created_at, updated_at) " +
                "VALUES (?, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING cart_id"
            );
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            if (!rs.next()) throw new SQLException("Failed to create cart");
            cartId = rs.getInt(1);
        }

        rs.close();
        pstmt.close();

        // --- Step 2: Insert cart item ---
        pstmt = conn.prepareStatement(
            "INSERT INTO cart_item (cart_id, product_id, caregiver_id, client_id, special_requests, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
        );
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
        conn.commit();

    } catch (NumberFormatException e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        redirectMsg = "invalid_input";
    } catch (SQLException e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        redirectMsg = "db_error";
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        redirectMsg = "error";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }

    // -------------------------------------------------
    // 5. REDIRECT
    // -------------------------------------------------
    response.sendRedirect("products.jsp?msg=" + redirectMsg);
%>