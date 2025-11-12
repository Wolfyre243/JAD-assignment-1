<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure handler to activate/deactivate product using JDBC utility and AuthServlet session
--%>
<%
    // === INPUT VALIDATION ===
    String action = request.getParameter("action");
    String productIdStr = request.getParameter("productId");

    if (productIdStr == null || productIdStr.trim().isEmpty() ||
        !("activate".equals(action) || "deactivate".equals(action))) {
        response.sendRedirect("adminServices.jsp?msg=invalid");
        return;
    }

    int productId;
    try {
        productId = Integer.parseInt(productIdStr.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("adminServices.jsp?msg=invalid");
        return;
    }

    boolean newStatus = "activate".equals(action);

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // === JDBC: Update product status using utility class ===
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        String sql = 
            "UPDATE product SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setBoolean(1, newStatus);
        pstmt.setInt(2, productId);

        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            response.sendRedirect("adminServices.jsp?msg=not_found");
        } else {
            response.sendRedirect("adminServices.jsp?msg=" + action + "d");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("adminServices.jsp?msg=db_error");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminServices.jsp?msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>