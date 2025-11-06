<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Services Management</title>
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
    
    <h1>Services Management</h1>
    <a href="adminDashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <% 
    String message = request.getParameter("msg");
    if (message != null) {
        if (message.equals("activated")) {
    %>
        <p>Service activated successfully!</p>
    <% 
        } else if (message.equals("deactivated")) {
    %>
        <p>Service deactivated successfully!</p>
    <% 
        } else if (message.equals("error")) {
    %>
        <p>Error updating service status.</p>
    <% 
        }
    }
    %>
    
    <h2>All Services/Products</h2>
    <a href="adminAddService.jsp">Add New Service</a>
    <br><br>
    
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
        
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.is_active, " +
                     "c.name as category_name " +
                     "FROM product p " +
                     "JOIN category c ON p.category_id = c.category_id " +
                     "ORDER BY p.product_id";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
    %>
    
    <table border="1">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Category</th>
                <th>Description</th>
                <th>Price</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
        while (rs.next()) {
            int productId = rs.getInt("product_id");
            String name = rs.getString("name");
            String description = rs.getString("description");
            double price = rs.getDouble("price");
            boolean isActive = rs.getBoolean("is_active");
            String categoryName = rs.getString("category_name");
        %>
            <tr>
                <td><%= productId %></td>
                <td><%= name %></td>
                <td><%= categoryName %></td>
                <td><%= description %></td>
                <td>$<%= String.format("%.2f", price) %></td>
                <td><%= isActive ? "Active" : "Inactive" %></td>
                <td>
                    <% if (isActive) { %>
                        <a href="adminServiceAction.jsp?action=deactivate&productId=<%= productId %>" 
                           onclick="return confirm('Deactivate this service?')">Deactivate</a>
                    <% } else { %>
                        <a href="adminServiceAction.jsp?action=activate&productId=<%= productId %>" 
                           onclick="return confirm('Activate this service?')">Activate</a>
                    <% } %>
                    |
                    <a href="adminEditService.jsp?productId=<%= productId %>">Edit</a>
                </td>
            </tr>
        <%
        }
        %>
        </tbody>
    </table>
    
    <%
    } catch (Exception e) {
        out.println("<p>Error loading services: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>