<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin form to add new service with category dropdown using JDBC utility and AuthServlet session
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Service</title>
</head>
<body>

    <h1>Add New Service</h1>
    <a href="<%= request.getContextPath() %>/admin/services">Back to Services</a>
    <hr>

    <!-- Form submits to AdminServiceServlet -->
    <form action="<%= request.getContextPath() %>/admin/service" method="post">
        <input type="hidden" name="action" value="add" />
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
                            // === 2. JDBC: Fetch categories using utility class ===
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;

                            try {
                                conn = JDBC.connect();
                                if (conn == null) throw new SQLException("Connection failed");

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
                                // === 3. RESOURCE CLEANUP ===
                                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
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
                    <a href="<%= request.getContextPath() %>/admin/services">Cancel</a>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>