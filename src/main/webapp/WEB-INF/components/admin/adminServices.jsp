<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin services management with list, add, edit, activate/deactivate using JDBC utility and AuthServlet
--%>
    <h1>Services Management</h1>
    <a href="<%= request.getContextPath() %>/admin/dashboard">Back to Dashboard</a>
    <hr>

    <%
        // === DISPLAY FEEDBACK MESSAGES ===
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String color = "";
            switch (msg) {
                case "added":      text = "Service added successfully!";      color = "green"; break;
                case "updated":    text = "Service updated successfully!";    color = "green"; break;
                case "activated":  text = "Service activated successfully!";  color = "green"; break;
                case "deactivated":text = "Service deactivated successfully!";color = "green"; break;
                case "invalid":    text = "Invalid request.";                 color = "red";   break;
                case "not_found":  text = "Service not found.";               color = "red";   break;
                case "db_error":   text = "Database error. Please try again.";color = "red";   break;
                default:           text = "Action completed.";                color = "green";
            }
    %>
    <% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; %>
    <p class="<%= _msgClass %>"><%= text %></p>
    <%
        }
    %>

    <h2>All Services/Products</h2>
    <a href="<%= request.getContextPath() %>/admin/services?include=add">Add New Service</a>
    <br><br>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Fetch products using utility class ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = 
                "SELECT p.product_id, p.name, p.description, p.price, p.is_active, " +
                "       c.name AS category_name " +
                "FROM product p " +
                "JOIN category c ON p.category_id = c.category_id " +
                "ORDER BY p.product_id";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p><em>No services available.</em></p>
    <%
            } else {
    %>
                <table border="1" cellpadding="8" cellspacing="0">
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
                            <td><%= description != null && !description.trim().isEmpty() ? description : "—" %></td>
                            <td>$<%= String.format("%.2f", price) %></td>
                            <% String statusClass = isActive ? "status-active" : "status-inactive"; %>
                            <td class="<%= statusClass %>">
                                <%= isActive ? "Active" : "Inactive" %>
                            </td>
                            <td>
                                <% if (isActive) { %>
                                                <a href="<%= request.getContextPath() %>/admin/service?action=deactivate&productId=<%= productId %>"
                                                    onclick="return confirm('Deactivate this service?');"
                                                    style="color: orange;">Deactivate</a>
                                <% } else { %>
                                                <a href="<%= request.getContextPath() %>/admin/service?action=activate&productId=<%= productId %>"
                                                    onclick="return confirm('Activate this service?');"
                                                    style="color: green;">Activate</a>
                                <% } %>
                                          |
                                          <a href="<%= request.getContextPath() %>/admin/services?include=edit&productId=<%= productId %>">Edit</a>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading services: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>

