<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
Integer adminId = (Integer) session.getAttribute("userId");
String userRole = (String) session.getAttribute("userRole");

if (adminId == null || !"admin".equals(userRole)) {
    response.sendRedirect("../../auth/components/login.jsp");
    return;
}

String feedbackIdStr = request.getParameter("feedbackId");

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection(
        "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
        "neondb_owner",
        "npg_6dLgQzjR9OEa"
    );
    
    String sql = "DELETE FROM feedback WHERE feedback_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(feedbackIdStr));
    pstmt.executeUpdate();
    
    response.sendRedirect("adminFeedback.jsp?msg=deleted");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("adminFeedback.jsp?msg=error");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>