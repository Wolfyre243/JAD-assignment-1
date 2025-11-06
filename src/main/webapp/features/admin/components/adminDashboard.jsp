<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
</head>
<body>
    <%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    
    if (userId == null || !"admin".equals(userRole)) {
        response.sendRedirect("../../auth/components/login.jsp");
        return;
    }
    %>
    
    <h1>Admin Dashboard</h1>
    <p>Welcome, Admin!</p>
    <hr>
    
    <%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
            "neondb_owner",
            "npg_6dLgQzjR9OEa"
        );
        
        // Get statistics
        int totalUsers = 0;
        int totalOrders = 0;
        int totalFeedback = 0;
        int totalProducts = 0;
        
        // Count users
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM \"user\"");
        rs = pstmt.executeQuery();
        if (rs.next()) totalUsers = rs.getInt(1);
        rs.close();
        pstmt.close();
        
        // Count orders
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM \"order\"");
        rs = pstmt.executeQuery();
        if (rs.next()) totalOrders = rs.getInt(1);
        rs.close();
        pstmt.close();
        
        // Count feedback
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM feedback");
        rs = pstmt.executeQuery();
        if (rs.next()) totalFeedback = rs.getInt(1);
        rs.close();
        pstmt.close();
        
        // Count products
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM product");
        rs = pstmt.executeQuery();
        if (rs.next()) totalProducts = rs.getInt(1);
        rs.close();
        pstmt.close();
    %>
    
    <h2>Statistics</h2>
    <table border="1">
        <tr>
            <td><strong>Total Users:</strong></td>
            <td><%= totalUsers %></td>
        </tr>
        <tr>
            <td><strong>Total Orders:</strong></td>
            <td><%= totalOrders %></td>
        </tr>
        <tr>
            <td><strong>Total Feedback:</strong></td>
            <td><%= totalFeedback %></td>
        </tr>
        <tr>
            <td><strong>Total Products:</strong></td>
            <td><%= totalProducts %></td>
        </tr>
    </table>
    
    <%
    } catch (Exception e) {
        out.println("<p>Error loading statistics: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
    
    <hr>
    <h2>Management Sections</h2>
    <ul>
        <li><a href="adminUsers.jsp">User Management</a></li>
        <li><a href="adminFeedback.jsp">Feedback Management</a></li>
        <li><a href="adminOrders.jsp">Order Management</a></li>
        <li><a href="adminServices.jsp">Services Management</a></li>
    </ul>
    
    <hr>
    <a href="logout.jsp">Logout</a>
</body>
</html>