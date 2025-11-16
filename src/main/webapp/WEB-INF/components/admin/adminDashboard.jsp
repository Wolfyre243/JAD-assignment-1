<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin dashboard with real-time statistics using JDBC utility and AuthServlet session
--%>
    <h1>Admin Dashboard</h1>
    <p>Welcome, Admin!</p>
    <hr>

    <%
        // Prefer the `stats` map provided by AdminPanelServlet, but also accept
        // individual attributes (`totalUsers`, `totalOrders`, etc.) which some
        // servlets (e.g., AdminDashboardServlet) may set directly.
        java.util.Map<String,Integer> stats = (java.util.Map<String,Integer>) request.getAttribute("stats");
        if (stats == null) {
            // Try to build a map from individual attributes if available
            Integer tu = (Integer) request.getAttribute("totalUsers");
            Integer to = (Integer) request.getAttribute("totalOrders");
            Integer tf = (Integer) request.getAttribute("totalFeedback");
            Integer tp = (Integer) request.getAttribute("totalProducts");
            if (tu != null || to != null || tf != null || tp != null) {
                stats = new java.util.HashMap<>();
                stats.put("totalUsers", tu != null ? tu : 0);
                stats.put("totalOrders", to != null ? to : 0);
                stats.put("totalFeedback", tf != null ? tf : 0);
                stats.put("totalProducts", tp != null ? tp : 0);
            }
        }

        if (stats == null) {
    %>
        <p style="color:red;">Dashboard data not available.</p>
    <%
        } else {
            Integer totalUsers = stats.get("totalUsers");
            Integer totalOrders = stats.get("totalOrders");
            Integer totalFeedback = stats.get("totalFeedback");
            Integer totalProducts = stats.get("totalProducts");
    %>

    <h2>Statistics</h2>
    <table border="1" cellpadding="8" cellspacing="0">
        <tr><th>Metric</th><th>Count</th></tr>
        <tr><td><strong>Total Users</strong></td><td><%= totalUsers != null ? totalUsers : 0 %></td></tr>
        <tr><td><strong>Total Orders</strong></td><td><%= totalOrders != null ? totalOrders : 0 %></td></tr>
        <tr><td><strong>Total Feedback</strong></td><td><%= totalFeedback != null ? totalFeedback : 0 %></td></tr>
        <tr><td><strong>Total Products</strong></td><td><%= totalProducts != null ? totalProducts : 0 %></td></tr>
    </table>

    <%
        }
    %>

    <hr>
    <h2>Management Sections</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/admin/users">User Management</a></li>
        <li><a href="<%= request.getContextPath() %>/admin/feedback">Feedback Management</a></li>
        <li><a href="<%= request.getContextPath() %>/admin/orders">Order Management</a></li>
        <li><a href="<%= request.getContextPath() %>/admin/services">Services Management</a></li>
    </ul>

    <hr>
    <a href="${pageContext.request.contextPath}/auth/logout">Logout</a>

