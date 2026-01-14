<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: GitHub Copilot
  Date: January 14, 2026
  Description: Admin caregiver management with list, add, edit, activate/deactivate and profile image display
--%>
    <h1>Caregiver Management</h1>
    <p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
    <hr>

    <%
        // === DISPLAY FEEDBACK MESSAGES ===
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String color = "";
            switch (msg) {
                case "added":      text = "Caregiver added successfully!";      color = "green"; break;
                case "updated":    text = "Caregiver updated successfully!";    color = "green"; break;
                case "deleted":    text = "Caregiver deleted successfully!";    color = "green"; break;
                case "activated":  text = "Caregiver activated successfully!";  color = "green"; break;
                case "deactivated":text = "Caregiver deactivated successfully!";color = "green"; break;
                case "invalid":    text = "Invalid request.";                   color = "red";   break;
                case "not_found":  text = "Caregiver not found.";               color = "red";   break;
                case "db_error":   text = "Database error. Please try again.";  color = "red";   break;
                case "upload_error": 
                    String details = request.getParameter("details");
                    text = "Profile image upload error: " + (details != null ? details : "Please check file format and size.");
                    color = "red"; 
                    break;
                default:           text = "Action completed.";                  color = "green";
            }
    %>
    <% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; %>
    <p class="<%= _msgClass %>"><%= text %></p>
    <%
        }
    %>

    <h2>All Caregivers</h2>
    <p><a href="<%= request.getContextPath() %>/admin/caregivers?include=add" class="btn">+ Add New Caregiver</a></p>

    <%
        java.util.List<java.util.Map<String,Object>> caregivers = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("caregivers");
        String caregiversError = (String) request.getAttribute("caregiversError");
        if (caregiversError != null) {
    %>
        <p class="msg-error"><%= caregiversError %></p>
    <%
        } else if (caregivers == null || caregivers.isEmpty()) {
    %>
        <p><em>No caregivers available.</em></p>
    <%
        } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Profile Image</th>
                    <th>Name</th>
                    <th>Qualifications</th>
                    <th>Hourly Rate</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (java.util.Map<String,Object> row : caregivers) {
                    int caregiverId = (row.get("caregiverId") instanceof Number) ? ((Number) row.get("caregiverId")).intValue() : Integer.parseInt(row.get("caregiverId").toString());
                    String firstName = (String) row.get("firstName");
                    String lastName = (String) row.get("lastName");
                    String fullName = (String) row.get("fullName");
                    String qualifications = (String) row.get("qualifications");
                    double hourlyRate = (row.get("hourlyRate") instanceof Number) ? ((Number) row.get("hourlyRate")).doubleValue() : 0.0;
                    String profileImagePath = (String) row.get("profileImagePath");
            %>
                <tr>
                    <td><%= caregiverId %></td>
                    <td>
                        <% if (profileImagePath != null && !profileImagePath.trim().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/images/caregivers/<%= profileImagePath %>" 
                                 alt="<%= fullName %>" 
                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%; border: 2px solid #ddd;">
                        <% } else { %>
                            <img src="<%= request.getContextPath() %>/images/caregivers/default_profile.png" 
                                 alt="No image" 
                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%; border: 2px solid #ddd; opacity: 0.6;">
                        <% } %>
                    </td>
                    <td><strong><%= fullName %></strong></td>
                    <td><%= qualifications != null ? qualifications : "N/A" %></td>
                    <td>$<%= String.format("%.2f", hourlyRate) %>/hr</td>
                    <td>
                        <a href="<%= request.getContextPath() %>/admin/caregivers?include=edit&caregiverId=<%= caregiverId %>">Edit</a>
                        |
                        <a href="<%= request.getContextPath() %>/admin/caregiver?action=delete&caregiverId=<%= caregiverId %>" 
                           onclick="return confirm('Delete this caregiver?');" 
                           style="color: red;">Delete</a>
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

<style>
    /* Caregiver-specific styles */
    table td {
        vertical-align: middle;
        text-align: center;
    }
    
    table td:first-child,
    table td:nth-child(3),
    table td:nth-child(4) {
        text-align: left;
    }
</style>