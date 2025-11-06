<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
Integer adminId = (Integer) session.getAttribute("userId");
String userRole = (String) session.getAttribute("userRole");

if (adminId == null || !"admin".equals(userRole)) {
    response.sendRedirect("../../auth/components/login.jsp");
    return;
}

String action = request.getParameter("action");
String productIdStr = request.getParameter("productId");

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection(
        "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
        "neondb_owner",
        "npg_6dLgQzjR9OEa"
    );
    
    boolean newStatus = "activate".equals(action);
    
    String sql = "UPDATE product SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setBoolean(1, newStatus);
    pstmt.setInt(2, Integer.parseInt(productIdStr));
    pstmt.executeUpdate();
    
    response.sendRedirect("adminServices.jsp?msg=" + action + "d");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("adminServices.jsp?msg=error");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>