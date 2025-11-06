<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Management</title>
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
    
    <h1>Order Management</h1>
    <a href="adminDashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <h2>All Orders</h2>
    
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
        
        String sql = "SELECT o.order_id, o.created_at, u.email, " +
                     "COUNT(b.booking_id) as booking_count " +
                     "FROM \"order\" o " +
                     "JOIN \"user\" u ON o.user_id = u.user_id " +
                     "LEFT JOIN booking b ON o.order_id = b.order_id " +
                     "GROUP BY o.order_id, o.created_at, u.email " +
                     "ORDER BY o.created_at DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
    %>
    
    <table border="1">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>User Email</th>
                <th>Number of Bookings</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            Timestamp createdAt = rs.getTimestamp("created_at");
            String email = rs.getString("email");
            int bookingCount = rs.getInt("booking_count");
        %>
            <tr>
                <td><%= orderId %></td>
                <td><%= email %></td>
                <td><%= bookingCount %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="adminOrderDetails.jsp?orderId=<%= orderId %>">View Details</a>
                </td>
            </tr>
        <%
        }
        %>
        </tbody>
    </table>
    
    <%
    } catch (Exception e) {
        out.println("<p>Error loading orders: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>