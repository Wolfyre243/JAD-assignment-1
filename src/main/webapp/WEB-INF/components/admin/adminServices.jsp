<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin services management with list, add, edit, activate/deactivate using JDBC utility and AuthServlet
--%>
    <h1>Services Management</h1>
    <p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
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
                case "deleted":    text = "Service deleted successfully!";    color = "green"; break;
                case "activated":  text = "Service activated successfully!";  color = "green"; break;
                case "deactivated":text = "Service deactivated successfully!";color = "green"; break;
                case "invalid":    text = "Invalid request.";                 color = "red";   break;
                case "not_found":  text = "Service not found.";               color = "red";   break;
                case "db_error":   text = "Database error. Please try again.";color = "red";   break;
                case "upload_error": 
                    String details = request.getParameter("details");
                    text = "Image upload error: " + (details != null ? details : "Please check file format and size.");
                    color = "red"; 
                    break;
                default:           text = "Action completed.";                color = "green";
            }
    %>
    <% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; %>
    <p class="<%= _msgClass %>"><%= text %></p>
    <%
        }
    %>

    <h2>All Services/Products</h2>
    <p><a href="<%= request.getContextPath() %>/admin/services?include=add" class="btn">+ Add New Service</a></p>

    <%
        java.util.List<java.util.Map<String,Object>> services = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("services");
        String servicesError = (String) request.getAttribute("servicesError");
        if (servicesError != null) {
    %>
        <p class="msg-error"><%= servicesError %></p>
    <%
        } else if (services == null || services.isEmpty()) {
    %>
        <p><em>No services available.</em></p>
    <%
        } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Image</th>
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
                for (java.util.Map<String,Object> row : services) {
                    int productId = (Integer) row.get("productId");
                    String name = (String) row.get("name");
                    String description = (String) row.get("description");
                    double price = (Double) row.get("price");
                    boolean isActive = Boolean.TRUE.equals(row.get("isActive"));
                    String categoryName = (String) row.get("categoryName");
                    String imagePath = (String) row.get("imagePath");
            %>
                <tr>
                    <td><%= productId %></td>
                    <td>
                        <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/images/services/<%= imagePath %>" 
                                 alt="<%= name %>" 
                                 style="width: 50px; height: 40px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd;">
                        <% } else { %>
                            <img src="<%= request.getContextPath() %>/images/default.png" 
                                 alt="No image" 
                                 style="width: 50px; height: 40px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd; opacity: 0.6;">
                        <% } %>
                    </td>
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
                            <a href="<%= request.getContextPath() %>/admin/service?action=deactivate&productId=<%= productId %>" onclick="return confirm('Deactivate this service?');" style="color: orange;">Deactivate</a>
                        <% } else { %>
                            <a href="<%= request.getContextPath() %>/admin/service?action=activate&productId=<%= productId %>" onclick="return confirm('Activate this service?');" style="color: green;">Activate</a>
                        <% } %>
                        |
                        <a href="<%= request.getContextPath() %>/admin/services?include=edit&productId=<%= productId %>">Edit</a>
                        |
                        <a href="<%= request.getContextPath() %>/admin/service-caregivers?productId=<%= productId %>" 
                           style="color: #007bff;">Manage Caregivers</a>
                        |
                        <a href="<%= request.getContextPath() %>/admin/service?action=delete&productId=<%= productId %>" 
                           onclick="return confirm('Delete this service? This will remove all caregiver associations.');" 
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

