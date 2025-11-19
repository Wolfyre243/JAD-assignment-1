<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin user management with role aggregation, status toggle, and last login using JDBC utility and AuthServlet
--%>
    <h1>User Management</h1>
    <p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
    <hr>

    <%
        Integer currentUserId = (Integer) request.getAttribute("currentUserId");

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
        java.util.List<java.util.Map<String,Object>> users = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("users");
        if (users == null || users.isEmpty()) {
    %>
        <p><em>No users found.</em></p>
    <%
        } else {
    %>
        <table>
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
                for (java.util.Map<String,Object> u : users) {
                    int uid = (Integer) u.get("userId");
                    String email = (String) u.get("email");
                    boolean isActive = (Boolean) u.get("isActive");
                    java.sql.Timestamp createdAt = (java.sql.Timestamp) u.get("createdAt");
                    java.sql.Timestamp lastLogin = (java.sql.Timestamp) u.get("lastLogin");
                    String roles = (String) u.get("roles");

                    String formattedCreated = createdAt != null ? createdAt.toString().substring(0, 19).replace("T", " ") : "";
                    String formattedLastLogin = (lastLogin != null) ? lastLogin.toString().substring(0, 19).replace("T", " ") : "Never";

                    boolean isCurrentAdmin = (currentUserId != null && uid == currentUserId);
            %>
                <tr>
                    <td><%= uid %></td>
                    <td><%= email %></td>
                    <td><%= roles %></td>
                    <% String _statusClass = isActive ? "status-active" : "status-inactive"; %>
                    <td class="<%= _statusClass %>"><%= isActive ? "Active" : "Inactive" %></td>
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
                            <a href="<%= request.getContextPath() %>/admin/user?action=activate&userId=<%= uid %>"
                               onclick="return confirm('Activate this user?');"
                               style="color: green;">Activate</a>
                        <% } %>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
        }
    %>

