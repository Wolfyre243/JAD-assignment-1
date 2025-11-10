<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Details</title>
</head>
<body>
    <%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    
    if (userId == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String orderIdStr = request.getParameter("orderId");
    %>
    
    <h1>Order Details</h1>
    <a href="adminOrders.jsp">Back to Orders</a>
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
        
        // Get order info
        String orderSql = "SELECT o.order_id, o.created_at, u.email " +
                          "FROM \"order\" o " +
                          "JOIN \"user\" u ON o.user_id = u.user_id " +
                          "WHERE o.order_id = ?";
        pstmt = conn.prepareStatement(orderSql);
        pstmt.setInt(1, Integer.parseInt(orderIdStr));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int orderId = rs.getInt("order_id");
            Timestamp createdAt = rs.getTimestamp("created_at");
            String email = rs.getString("email");
    %>
    
    <h2>Order #<%= orderId %></h2>
    <p><strong>User:</strong> <%= email %></p>
    <p><strong>Order Date:</strong> <%= createdAt %></p>
    
    <h3>Bookings</h3>
    
    <%
            rs.close();
            pstmt.close();
            
            // Get bookings
            String bookingSql = "SELECT b.booking_id, p.name as product_name, " +
                                "b.special_requests, b.created_at " +
                                "FROM booking b " +
                                "LEFT JOIN product p ON b.product_id = p.product_id " +
                                "WHERE b.order_id = ?";
            pstmt = conn.prepareStatement(bookingSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();
    %>
    
    <table border="1">
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Product/Service</th>
                <th>Special Requests</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                int bookingId = rs.getInt("booking_id");
                String productName = rs.getString("product_name");
                String specialRequests = rs.getString("special_requests");
                Timestamp bookingCreatedAt = rs.getTimestamp("created_at");
        %>
            <tr>
                <td><%= bookingId %></td>
                <td><%= productName != null ? productName : "N/A" %></td>
                <td><%= specialRequests != null ? specialRequests : "None" %></td>
                <td><%= bookingCreatedAt %></td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    
    <%
        } else {
            out.println("<p>Order not found.</p>");
        }
    } catch (Exception e) {
        out.println("<p>Error loading order details: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>
