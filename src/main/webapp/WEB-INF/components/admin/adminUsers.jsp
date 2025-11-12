<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin user management with role aggregation, status toggle, and last login using JDBC utility and AuthServlet
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management</title>
    <style>
        .msg-success { color: green; font-weight: bold; }
        .msg-error { color: red; font-weight: bold; }
        .status-active { color: green; font-weight: bold; }
        .status-inactive { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>User Management</h1>
    <a href="<%= request.getContextPath() %>/admin/dashboard">Back to Dashboard</a>
    <hr>

    <%
        // Get the current logged-in user ID from session
        Integer currentUserId = (Integer) session.getAttribute("userId");
        if (currentUserId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }
    
        // === DISPLAY FEEDBACK MESSAGES ===
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String color = "";
            switch (msg) {
                case "activated":      text = "User activated successfully!";      color = "green"; break;
                case "deactivated":    text = "User deactivated successfully!";    color = "green"; break;
                case "self_action_denied": text = "You cannot deactivate yourself."; color = "red"; break;
                case "invalid":        text = "Invalid request.";                  color = "red";   break;
                case "not_found":      text = "User not found.";                   color = "red";   break;
                case "db_error":       text = "Database error. Please try again."; color = "red";   break;
                default:               text = "Action completed.";                 color = "green";
            }
    %>
    <% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; %>
    <p class="<%= _msgClass %>"><%= text %></p>
    <%
        }
    %>

    <h2>All Users</h2>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Fetch users with roles using utility class ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = 
                "SELECT u.user_id, u.email, u.is_active, u.created_at, u.last_login, " +
                "       COALESCE(STRING_AGG(r.name, ', '), 'No roles') AS roles " +
                "FROM \"user\" u " +
                "LEFT JOIN user_role ur ON u.user_id = ur.user_id " +
                "LEFT JOIN role r ON ur.role_id = r.role_id " +
                "GROUP BY u.user_id, u.email, u.is_active, u.created_at, u.last_login " +
                "ORDER BY u.user_id";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p><em>No users found.</em></p>
    <%
            } else {
    %>
                <table border="1" cellpadding="8" cellspacing="0">
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

                            String formattedCreated = createdAt.toString().substring(0, 19).replace("T", " ");
                            String formattedLastLogin = (lastLogin != null) 
                                ? lastLogin.toString().substring(0, 19).replace("T", " ") 
                                : "Never";

                            // Check if this is the currently logged-in admin
                            boolean isCurrentAdmin = (uid == currentUserId);
                    %>
                        <tr>
                            <td><%= uid %></td>
                            <td><%= email %></td>
                            <td><%= roles %></td>
                            <% String _statusClass = isActive ? "status-active" : "status-inactive"; %>
                            <td class="<%= _statusClass %>">
                                <%= isActive ? "Active" : "Inactive" %>
                            </td>
                            <td><%= formattedCreated %></td>
                            <td><%= formattedLastLogin %></td>
                            <td>
                                <% if (isActive) { %>
                                    <% if (!isCurrentAdmin) { %>
                                        <a href="<%= request.getContextPath() %>/admin/user?action=deactivate&userId=<%= uid %>"
                                           onclick="return confirm('Deactivate this user?');"
                                           style="color: orange;">Deactivate</a>
                                    <% } else { %>
                                        <span style="color: #999;">Deactivate (self)</span>
                                    <% } %>
                                <% } else { %>
                                                     <a href="<%= request.getContextPath() %>/admin/user?action=deactivate&userId=<%= uid %>"
                                                         onclick="return confirm('Deactivate this user?');"
                                                         style="color: orange;">Deactivate</a>
                                <% } %>
                                                <a href="<%= request.getContextPath() %>/admin/user?action=activate&userId=<%= uid %>"
                                                    onclick="return confirm('Activate this user?');"
                                                    style="color: green;">Activate</a>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading users: " + e.getMessage() + "</p>");
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