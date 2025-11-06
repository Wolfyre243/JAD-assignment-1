<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Service</title>
</head>
<body>
    <%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    
    if (userId == null || !"admin".equals(userRole)) {
        response.sendRedirect("../../auth/components/login.jsp");
        return;
    }
    
    String productIdStr = request.getParameter("productId");
    %>
    
    <h1>Edit Service</h1>
    <a href="adminServices.jsp">Back to Services</a>
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
        
        String sql = "SELECT product_id, category_id, name, description, price, is_active FROM product WHERE product_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(productIdStr));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int productId = rs.getInt("product_id");
            int categoryId = rs.getInt("category_id");
            String name = rs.getString("name");
            String description = rs.getString("description");
            double price = rs.getDouble("price");
            boolean isActive = rs.getBoolean("is_active");
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
                        rs.close();
                        pstmt.close();
                        
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
                <td><input type="number" name="price" step="0.01" min="0" value="<%= price %>" required></td>
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
        } else {
            out.println("<p>Service not found.</p>");
        }
    } catch (Exception e) {
        out.println("<p>Error loading service: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>