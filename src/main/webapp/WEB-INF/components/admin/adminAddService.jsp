<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Service</title>
</head>
<body>
    <%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    
    if (userId == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    %>
    
    <h1>Add New Service</h1>
    <a href="adminServices.jsp">Back to Services</a>
    <hr>
    
    <form action="adminAddServiceHandler.jsp" method="post">
        <table>
            <tr>
                <td><label>Service Name:</label></td>
                <td><input type="text" name="name" required></td>
            </tr>
            <tr>
                <td><label>Category:</label></td>
                <td>
                    <select name="categoryId" required>
                        <option value="">Select Category</option>
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
                            
                            String sql = "SELECT category_id, name FROM category ORDER BY name";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            while (rs.next()) {
                                int categoryId = rs.getInt("category_id");
                                String categoryName = rs.getString("name");
                        %>
                        <option value="<%= categoryId %>"><%= categoryName %></option>
                        <%
                            }
                        } catch (Exception e) {
                            out.println("<option>Error loading categories</option>");
                            e.printStackTrace();
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                            if (conn != null) try { conn.close(); } catch (SQLException e) {}
                        }
                        %>
                    </select>
                </td>
            </tr>
            <tr>
                <td><label>Description:</label></td>
                <td><textarea name="description" rows="5" cols="50"></textarea></td>
            </tr>
            <tr>
                <td><label>Price:</label></td>
                <td><input type="number" name="price" step="0.01" min="0" required></td>
            </tr>
            <tr>
                <td><label>Active:</label></td>
                <td>
                    <input type="radio" name="isActive" value="true" checked> Yes
                    <input type="radio" name="isActive" value="false"> No
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <button type="submit">Add Service</button>
                    <a href="adminServices.jsp">Cancel</a>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>