<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%
    // -------------------------------------------------
    // 1. AUTHENTICATION 
    // -------------------------------------------------
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }

    // -------------------------------------------------
    // 2. INPUT PARAMETERS
    // -------------------------------------------------
    String cartItemIdStr = request.getParameter("cartItemId");
    String quantityStr   = request.getParameter("quantity");

    if (cartItemIdStr == null || quantityStr == null) {
        response.sendRedirect("viewCart.jsp?msg=invalid");
        return;
    }

    int cartItemId, quantity;
    try {
        cartItemId = Integer.parseInt(cartItemIdStr);
        quantity   = Integer.parseInt(quantityStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("viewCart.jsp?msg=invalid");
        return;
    }

    // -------------------------------------------------
    // 3. VALIDATION
    // -------------------------------------------------
    if (quantity < 1 || quantity > 99 || cartItemId <= 0) {
        response.sendRedirect("viewCart.jsp?msg=invalid_quantity");
        return;
    }

    // -------------------------------------------------
    // 4. DATABASE UPDATE (transaction + ownership check)
    // -------------------------------------------------
    String redirectMsg = "updated";

    try (
        Connection conn = JDBC.connect();
        PreparedStatement pstmt = conn.prepareStatement(
            "UPDATE cart_item SET quantity = ?, updated_at = CURRENT_TIMESTAMP " +
            "WHERE cart_item_id = ? " +
            "  AND cart_id IN (SELECT cart_id FROM cart WHERE user_id = ? AND checked_out = false)"
        )
    ) {
        if (conn == null) throw new SQLException("Connection failed");

        conn.setAutoCommit(false);

        pstmt.setInt(1, quantity);
        pstmt.setInt(2, cartItemId);
        pstmt.setInt(3, userId);   // <-- ensures the item belongs to the logged-in user

        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            redirectMsg = "not_found";
        }

        conn.commit();
    } catch (SQLException e) {
        e.printStackTrace();
        redirectMsg = "db_error";
    } catch (Exception e) {
        e.printStackTrace();
        redirectMsg = "error";
    }

    // -------------------------------------------------
    // 5. REDIRECT
    // -------------------------------------------------
    response.sendRedirect("viewCart.jsp?msg=" + redirectMsg);
%>