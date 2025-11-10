<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management</title>
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
    
    <h1>User Management</h1>
    <a href="adminDashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <% 
    String message = request.getParameter("msg");
    if (message != null) {
        if (message.equals("activated")) {
    %>
        <p>User activated successfully!</p>
    <% 
        } else if (message.equals("deactivated")) {
    %>
        <p>User deactivated successfully!</p>
    <% 
        } else if (message.equals("error")) {
    %>
        <p>Error updating user status.</p>
    <% 
        }
    }
    %>
    
    <h2>All Users</h2>
    
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
        
        String sql = "SELECT u.user_id, u.email, u.is_active, u.created_at, u.last_login, " +
                     "STRING_AGG(r.name, ', ') as roles " +
                     "FROM \"user\" u " +
                     "LEFT JOIN user_role ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN role r ON ur.role_id = r.role_id " +
                     "GROUP BY u.user_id, u.email, u.is_active, u.created_at, u.last_login " +
                     "ORDER BY u.user_id";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
    %>
    
    <table border="1">
        <thead>
            <tr>
                <th>User ID</th>
                <th>Email</th>
                <th>Roles</th>
                <th>Status</th>
                <th>Created At</th>
                <th>Last Login</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
        while (rs.next()) {
            int uid = rs.getInt("user_id");
            String email = rs.getString("email");
            boolean isActive = rs.getBoolean("is_active");
            Timestamp createdAt = rs.getTimestamp("created_at");
            Timestamp lastLogin = rs.getTimestamp("last_login");
            String roles = rs.getString("roles");
        %>
            <tr>
                <td><%= uid %></td>
                <td><%= email %></td>
                <td><%= roles != null ? roles : "No roles" %></td>
                <td><%= isActive ? "Active" : "Inactive" %></td>
                <td><%= createdAt %></td>
                <td><%= lastLogin != null ? lastLogin : "Never" %></td>
                <td>
                    <% if (isActive) { %>
                        <a href="adminUserAction.jsp?action=deactivate&userId=<%= uid %>" 
                           onclick="return confirm('Deactivate this user?')">Deactivate</a>
                    <% } else { %>
                        <a href="adminUserAction.jsp?action=activate&userId=<%= uid %>" 
                           onclick="return confirm('Activate this user?')">Activate</a>
                    <% } %>
                    |
                    <a href="adminUserDetails.jsp?userId=<%= uid %>">View Details</a>
                </td>
            </tr>
        <%
        }
        %>
        </tbody>
    </table>
    
    <%
    } catch (Exception e) {
        out.println("<p>Error loading users: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>