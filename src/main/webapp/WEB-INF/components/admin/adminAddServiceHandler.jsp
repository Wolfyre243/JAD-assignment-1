<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure handler to add new product/service using JDBC utility and AuthServlet session
--%>
<%

    // === INPUT PARAMETERS ===
    String name = request.getParameter("name");
    String categoryIdStr = request.getParameter("categoryId");
    String description = request.getParameter("description");
    String priceStr = request.getParameter("price");
    String isActiveStr = request.getParameter("isActive");

    // === VALIDATION ===
    if (name == null || name.trim().isEmpty() ||
        categoryIdStr == null || priceStr == null || isActiveStr == null) {
        response.sendRedirect("adminAddService.jsp?msg=invalid");
        return;
    }

    int categoryId;
    double price;
    try {
        categoryId = Integer.parseInt(categoryIdStr);
        price = Double.parseDouble(priceStr);
        if (price < 0) throw new NumberFormatException();
    } catch (NumberFormatException e) {
        response.sendRedirect("adminAddService.jsp?msg=invalid");
        return;
    }

    boolean isActive = Boolean.parseBoolean(isActiveStr);

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // === JDBC: Insert new product using utility class ===
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        String sql = 
            "INSERT INTO product (category_id, name, description, price, is_active, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, categoryId);
        pstmt.setString(2, name.trim());
        pstmt.setString(3, description != null ? description.trim() : null);
        pstmt.setDouble(4, price);
        pstmt.setBoolean(5, isActive);

        int rows = pstmt.executeUpdate();
        if (rows == 0) throw new SQLException("Insert failed");

        response.sendRedirect("adminServices.jsp?msg=added");

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("adminAddService.jsp?msg=db_error");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminAddService.jsp?msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>