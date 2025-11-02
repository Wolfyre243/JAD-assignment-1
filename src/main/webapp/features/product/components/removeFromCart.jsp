<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%
Integer userId = (Integer) session.getAttribute("userId");
String cartItemIdStr = request.getParameter("cartItemId");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://your-host:3306/neondb?useSSL=false&serverTimezone=UTC",
        "your-username",
        "your-password"
    );
    
    String sql = "DELETE FROM cart_item WHERE cart_item_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(cartItemIdStr));
    pstmt.executeUpdate();
    
    response.sendRedirect("viewCart.jsp");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("viewCart.jsp?msg=error");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
