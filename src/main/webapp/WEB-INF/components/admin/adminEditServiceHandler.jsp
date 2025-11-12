<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure handler to update product/service using JDBC utility and AuthServlet session
--%>
<%

    // === INPUT PARAMETERS & VALIDATION ===
    String productIdStr = request.getParameter("productId");
    String name = request.getParameter("name");
    String categoryIdStr = request.getParameter("categoryId");
    String description = request.getParameter("description");
    String priceStr = request.getParameter("price");
    String isActiveStr = request.getParameter("isActive");

    // Validate required fields
    if (productIdStr == null || name == null || name.trim().isEmpty() ||
        categoryIdStr == null || priceStr == null || isActiveStr == null) {
        response.sendRedirect("adminEditService.jsp?productId=" + productIdStr + "&msg=invalid");
        return;
    }

    int productId, categoryId;
    double price;
    try {
        productId = Integer.parseInt(productIdStr.trim());
        categoryId = Integer.parseInt(categoryIdStr.trim());
        price = Double.parseDouble(priceStr.trim());
        if (price < 0) throw new NumberFormatException();
    } catch (NumberFormatException e) {
        response.sendRedirect("adminEditService.jsp?productId=" + productIdStr + "&msg=invalid");
        return;
    }

    boolean isActive = Boolean.parseBoolean(isActiveStr);

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // === JDBC: Update product using utility class ===
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        String sql = 
            "UPDATE product SET " +
            "    category_id = ?, name = ?, description = ?, price = ?, " +
            "    is_active = ?, updated_at = CURRENT_TIMESTAMP " +
            "WHERE product_id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, categoryId);
        pstmt.setString(2, name.trim());
        pstmt.setString(3, description != null ? description.trim() : null);
        pstmt.setDouble(4, price);
        pstmt.setBoolean(5, isActive);
        pstmt.setInt(6, productId);

        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            response.sendRedirect("adminEditService.jsp?productId=" + productId + "&msg=not_found");
        } else {
            response.sendRedirect("adminServices.jsp?msg=updated");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("adminEditService.jsp?productId=" + productId + "&msg=db_error");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminEditService.jsp?productId=" + productId + "&msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>