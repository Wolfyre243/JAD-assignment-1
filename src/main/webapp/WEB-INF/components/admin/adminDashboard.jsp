<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin dashboard with real-time statistics using JDBC utility and AuthServlet session
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
</head>
<body>
    <%
        // === 1. AUTHENTICATION & AUTHORIZATION (via AuthServlet) ===
        Integer userId = (Integer) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");

        if (userId == null || !"admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
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

        // Initialize counters
        int totalUsers = 0, totalOrders = 0, totalFeedback = 0, totalProducts = 0;

        try {
            // === 2. JDBC: Get connection via utility ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Database connection failed");

            // === 3. FETCH STATISTICS ===
            String[] queries = {
                "SELECT COUNT(*) FROM \"user\"",
                "SELECT COUNT(*) FROM \"order\"",
                "SELECT COUNT(*) FROM feedback",
                "SELECT COUNT(*) FROM product"
            };
            int[] results = {0, 0, 0, 0};

            for (int i = 0; i < queries.length; i++) {
                pstmt = conn.prepareStatement(queries[i]);
                rs = pstmt.executeQuery();
                if (rs.next()) results[i] = rs.getInt(1);
                rs.close(); pstmt.close();
            }

            totalUsers = results[0];
            totalOrders = results[1];
            totalFeedback = results[2];
            totalProducts = results[3];
    %>

    <h2>Statistics</h2>
    <table border="1" cellpadding="8" cellspacing="0">
        <tr><th>Metric</th><th>Count</th></tr>
        <tr><td><strong>Total Users</strong></td><td><%= totalUsers %></td></tr>
        <tr><td><strong>Total Orders</strong></td><td><%= totalOrders %></td></tr>
        <tr><td><strong>Total Feedback</strong></td><td><%= totalFeedback %></td></tr>
        <tr><td><strong>Total Products</strong></td><td><%= totalProducts %></td></tr>
    </table>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading statistics: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === 4. RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
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
    <a href="${pageContext.request.contextPath}/auth/logout">Logout</a>
</body>
</html>