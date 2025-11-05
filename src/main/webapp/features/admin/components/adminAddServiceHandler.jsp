<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
Integer adminId = (Integer) session.getAttribute("userId");
String userRole = (String) session.getAttribute("userRole");

if (adminId == null || !"admin".equals(userRole)) {
    response.sendRedirect("login.jsp");
    return;
}

String name = request.getParameter("name");
String categoryIdStr = request.getParameter("categoryId");
String description = request.getParameter("description");
String priceStr = request.getParameter("price");
String isActiveStr = request.getParameter("isActive");

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection(
        "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
        "neondb_owner",
        "npg_6dLgQzjR9OEa"
    );
    
    String sql = "INSERT INTO product (category_id, name, description, price, is_active, created_at, updated_at) " +
                 "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(categoryIdStr));
    pstmt.setString(2, name);
    pstmt.setString(3, description);
    pstmt.setDouble(4, Double.parseDouble(priceStr));
    pstmt.setBoolean(5, Boolean.parseBoolean(isActiveStr));
    pstmt.executeUpdate();
    
    response.sendRedirect("adminServices.jsp?msg=added");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("adminAddService.jsp?msg=error");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
