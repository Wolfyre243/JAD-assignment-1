<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin form to edit existing service with pre-filled data using JDBC utility and AuthServlet session
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Service</title>
</head>
<body>
    <%
        // === INPUT VALIDATION ===
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect("adminServices.jsp?msg=invalid");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("adminServices.jsp?msg=invalid");
            return;
        }
    %>

    <h1>Edit Service</h1>
    <a href="adminServices.jsp">Back to Services</a>
    <hr>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Fetch product details using utility ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            // Load product
            String sql = "SELECT product_id, category_id, name, description, price, is_active FROM product WHERE product_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
    %>
                <p style="color:red;">Service not found.</p>
                <a href="adminServices.jsp">Back to Services</a>
    <%
                return;
            }

            // Extract product data
            int categoryId = rs.getInt("category_id");
            String name = rs.getString("name");
            String description = rs.getString("description");
            double price = rs.getDouble("price");
            boolean isActive = rs.getBoolean("is_active");

            rs.close();
            pstmt.close();
    %>

    <form action="adminEditServiceHandler.jsp" method="post">
        <input type="hidden" name="productId" value="<%= productId %>">
        <table>
            <tr>
                <td><label>Service Name:</label></td>
                <td><input type="text" name="name" value="<%= name %>" required></td>
            </tr>
            <tr>
                <td><label>Category:</label></td>
                <td>
                    <select name="categoryId" required>
                        <%
                            // === JDBC: Load categories ===
                            String catSql = "SELECT category_id, name FROM category ORDER BY name";
                            pstmt = conn.prepareStatement(catSql);
                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                int catId = rs.getInt("category_id");
                                String catName = rs.getString("name");
                                boolean selected = (catId == categoryId);
                        %>
                                <option value="<%= catId %>" <%= selected ? "selected" : "" %>><%= catName %></option>
                        <%
                            }
                        %>
                    </select>
                </td>
            </tr>
            <tr>
                <td><label>Description:</label></td>
                <td><textarea name="description" rows="5" cols="50"><%= description != null ? description : "" %></textarea></td>
            </tr>
            <tr>
                <td><label>Price:</label></td>
                <td><input type="number" name="price" step="0.01" min="0" value="<%= String.format("%.2f", price) %>" required></td>
            </tr>
            <tr>
                <td><label>Active:</label></td>
                <td>
                    <input type="radio" name="isActive" value="true" <%= isActive ? "checked" : "" %>> Yes
                    <input type="radio" name="isActive" value="false" <%= !isActive ? "checked" : "" %>> No
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <button type="submit">Update Service</button>
                    <a href="adminServices.jsp">Cancel</a>
                </td>
            </tr>
        </table>
    </form>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading service: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>
</body>
</html>