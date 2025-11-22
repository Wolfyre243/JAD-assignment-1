<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Checkout processing page (legacy, replaced by CheckoutServlet)
--%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure checkout — converts active cart to order + bookings with full transaction safety
--%>
<%
    // === 1. AUTHENTICATION ===
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }

    // === 2. INPUT VALIDATION ===
    String cartIdStr = request.getParameter("cartId");
    if (cartIdStr == null || cartIdStr.trim().isEmpty()) {
        response.sendRedirect("viewCart.jsp?msg=invalid_cart");
        return;
    }

    int cartId;
    try {
        cartId = Integer.parseInt(cartIdStr.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("viewCart.jsp?msg=invalid_cart");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement bookingStmt = null;

    try {
        // Get DB connection
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Database connection failed");

        // Start transaction
        conn.setAutoCommit(false);

        // === 3. CREATE ORDER ===
        pstmt = conn.prepareStatement(
            "INSERT INTO \"order\" (user_id, created_at, updated_at) " +
            "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id"
        );
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if (!rs.next()) throw new SQLException("Failed to create order");
        int orderId = rs.getInt(1);
        rs.close(); pstmt.close();

        // === 4. COPY CART ITEMS → BOOKINGS ===
        pstmt = conn.prepareStatement(
            "SELECT product_id, caregiver_id, client_id, special_requests " +
            "FROM cart_item WHERE cart_id = ?"
        );
        pstmt.setInt(1, cartId);
        rs = pstmt.executeQuery();

        bookingStmt = conn.prepareStatement(
            "INSERT INTO booking (order_id, product_id, caregiver_id, client_id, special_requests, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
        );

        int itemCount = 0;
        while (rs.next()) {
            itemCount++;
            bookingStmt.setInt(1, orderId);
            bookingStmt.setInt(2, rs.getInt("product_id"));

            Integer caregiverId = (Integer) rs.getObject("caregiver_id");
            if (caregiverId != null) bookingStmt.setInt(3, caregiverId);
            else bookingStmt.setNull(3, Types.INTEGER);

            Integer clientId = (Integer) rs.getObject("client_id");
            if (clientId != null) bookingStmt.setInt(4, clientId);
            else bookingStmt.setNull(4, Types.INTEGER);

            String special = rs.getString("special_requests");
            if (special != null && !special.trim().isEmpty()) {
                bookingStmt.setString(5, special.trim());
            } else {
                bookingStmt.setNull(5, Types.VARCHAR);
            }

            bookingStmt.executeUpdate();
        }

        if (itemCount == 0) {
            throw new SQLException("Cart is empty");
        }

        rs.close(); pstmt.close(); bookingStmt.close();

        // === 5. MARK CART AS CHECKED OUT ===
        pstmt = conn.prepareStatement(
            "UPDATE cart SET checked_out = true, updated_at = CURRENT_TIMESTAMP WHERE cart_id = ? AND user_id = ?"
        );
        pstmt.setInt(1, cartId);
        pstmt.setInt(2, userId);
        int updated = pstmt.executeUpdate();
        if (updated == 0) throw new SQLException("Cart not found or not owned by user");

        // === 6. COMMIT ===
        conn.commit();
        response.sendRedirect("orderConfirmation.jsp?orderId=" + orderId);

    } catch (SQLException e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        response.sendRedirect("viewCart.jsp?msg=db_error");
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        e.printStackTrace();
        response.sendRedirect("viewCart.jsp?msg=checkout_error");
    } finally {
        // === 7. CLEANUP ===
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (bookingStmt != null) try { bookingStmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
    }
%>