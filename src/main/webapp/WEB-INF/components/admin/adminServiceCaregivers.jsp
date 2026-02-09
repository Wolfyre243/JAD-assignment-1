<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Karys Goh Yi Xin
  Date: January 14, 2026
  Description: Admin page to manage caregiver assignments for a specific service
--%>
<h1>Manage Caregivers for Service</h1>
<p><a href="<%= request.getContextPath() %>/admin/services">← Back to Services</a></p>
<hr>

<%
    // === DISPLAY FEEDBACK MESSAGES ===
    String msg = request.getParameter("msg");
    if (msg != null) {
        String text = "";
        String color = "";
        switch (msg) {
            case "assigned":     text = "Caregiver assigned to service successfully!";     color = "green"; break;
            case "removed":      text = "Caregiver removed from service successfully!";    color = "green"; break;
            case "available":    text = "Caregiver marked as available for service!";      color = "green"; break;
            case "unavailable":  text = "Caregiver marked as unavailable for service!";   color = "orange"; break;
            case "assign_error": text = "Failed to assign caregiver to service.";          color = "red";   break;
            case "remove_error": text = "Failed to remove caregiver from service.";       color = "red";   break;
            case "toggle_error": text = "Failed to update caregiver availability.";       color = "red";   break;
            case "invalid":      text = "Invalid request parameters.";                     color = "red";   break;
            case "db_error":     text = "Database error. Please try again.";               color = "red";   break;
            default:             text = "Action completed.";                               color = "green";
        }
%>
<% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; if ("orange".equals(color)) _msgClass = "msg-warning"; %>
<p class="<%= _msgClass %>"><%= text %></p>
<%
    }
%>

<%
    java.util.Map<String,Object> service = (java.util.Map<String,Object>) request.getAttribute("service");
    if (service != null) {
        String serviceName = (String) service.get("name");
        int productId = (Integer) service.get("productId");
%>

<div class="service-info">
    <h2 style="margin: 0; color: #b3003b;"><%= serviceName %></h2>
    <p style="margin: 5px 0; color: #666;">Service ID: #<%= productId %></p>
</div>

<%
    java.util.List<java.util.Map<String,Object>> assignedCaregivers = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("assignedCaregivers");
    java.util.List<java.util.Map<String,Object>> availableCaregivers = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("availableCaregivers");
%>

<!-- Assigned Caregivers Section -->
<div style="margin-bottom: 30px;">
    <h3>Currently Assigned Caregivers</h3>
    <% if (assignedCaregivers != null && !assignedCaregivers.isEmpty()) { %>
        <div class="caregiver-grid">
            <% for (java.util.Map<String,Object> caregiver : assignedCaregivers) { %>
                <%
                    int caregiverId = (caregiver.get("caregiverId") instanceof Number) ? ((Number) caregiver.get("caregiverId")).intValue() : Integer.parseInt(caregiver.get("caregiverId").toString());
                    String fullName = (String) caregiver.get("fullName");
                    String qualifications = (String) caregiver.get("qualifications");
                    double hourlyRate = (caregiver.get("hourlyRate") instanceof Number) ? ((Number) caregiver.get("hourlyRate")).doubleValue() : 0.0;
                    String profileImagePath = (String) caregiver.get("profileImagePath");
                    boolean isAvailable = (Boolean) caregiver.get("isAvailable");
                %>
                <div class="caregiver-card">
                    <img src="<%= request.getContextPath() %>/images/caregivers/<%= profileImagePath != null ? profileImagePath : "default_profile.png" %>" 
                         alt="<%= fullName %>" 
                         class="caregiver-avatar">
                    
                    <div class="caregiver-info">
                        <h4><%= fullName %></h4>
                        <p class="caregiver-details">
                            <strong><%= qualifications != null ? qualifications : "N/A" %></strong> • $<%= String.format("%.2f", hourlyRate) %>/hr
                        </p>
                        <span class="availability-badge <%= isAvailable ? "badge-available" : "badge-unavailable" %>">
                            <%= isAvailable ? "Available" : "Unavailable" %>
                        </span>
                    </div>
                    
                    <div class="caregiver-actions">
                        <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="productId" value="<%= productId %>">
                            <input type="hidden" name="caregiverId" value="<%= caregiverId %>">
                            <input type="hidden" name="isAvailable" value="<%= !isAvailable %>">
                            <button type="submit" 
                                    class="btn-toggle <%= isAvailable ? "btn-make-unavailable" : "btn-make-available" %>"
                                    onclick="return confirm('<%= isAvailable ? "Mark this caregiver as unavailable?" : "Mark this caregiver as available?" %>');">
                                <%= isAvailable ? "Mark Unavailable" : "Mark Available" %>
                            </button>
                        </form>
                        
                        <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="productId" value="<%= productId %>">
                            <input type="hidden" name="caregiverId" value="<%= caregiverId %>">
                            <button type="submit" 
                                    class="btn-remove"
                                    onclick="return confirm('Remove <%= fullName %> from this service?');">
                                Remove
                            </button>
                        </form>
                    </div>
                </div>
            <% } %>
        </div>
    <% } else { %>
        <p><em>No caregivers assigned to this service yet.</em></p>
    <% } %>
</div>

<!-- Add Caregiver Section -->
<div style="margin-top: 30px;">
    <h3>Add Caregivers to Service</h3>
    <% if (availableCaregivers != null && !availableCaregivers.isEmpty()) { %>
        <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" class="assign-form">
            <input type="hidden" name="action" value="assign">
            <input type="hidden" name="productId" value="<%= productId %>">
            
            <label>Select Caregiver:</label>
            <select name="caregiverId" required>
                <option value="">Choose a caregiver...</option>
                <% for (java.util.Map<String,Object> caregiver : availableCaregivers) { %>
                    <%
                        int caregiverId = (caregiver.get("caregiverId") instanceof Number) ? ((Number) caregiver.get("caregiverId")).intValue() : Integer.parseInt(caregiver.get("caregiverId").toString());
                        String fullName = (String) caregiver.get("fullName");
                        String qualifications = (String) caregiver.get("qualifications");
                        double hourlyRate = (caregiver.get("hourlyRate") instanceof Number) ? ((Number) caregiver.get("hourlyRate")).doubleValue() : 0.0;
                    %>
                    <option value="<%= caregiverId %>">
                        <%= fullName %> - <%= qualifications %> ($<%= String.format("%.2f", hourlyRate) %>/hr)
                    </option>
                <% } %>
            </select>
            
            <label>Initial Status:</label>
            <div style="margin-bottom: 15px;">
                <input type="radio" name="isAvailable" value="true" id="available-yes" checked>
                <label for="available-yes" style="display: inline; margin-right: 15px; margin-left: 5px;">Available</label>
                <input type="radio" name="isAvailable" value="false" id="available-no">
                <label for="available-no" style="display: inline; margin-left: 5px;">Unavailable</label>
            </div>
            
            <button type="submit" class="btn">Assign Caregiver</button>
        </form>
    <% } else { %>
        <p><em>All active caregivers are already assigned to this service.</em></p>
    <% } %>
</div>

<%
    } else {
%>
    <p class="msg-error">Service not found.</p>
<%
    }
%>

<style>
    .service-info {
        background: white;
        padding: 20px;
        border-radius: 12px;
        margin-bottom: 25px;
        border-left: 4px solid #b3003b;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
    }
    
    .caregiver-grid {
        display: grid;
        gap: 15px;
        margin-top: 15px;
    }
    
    .caregiver-card {
        display: flex;
        align-items: center;
        padding: 15px;
        background: white;
        border-radius: 12px;
        border: 1px solid #ddd;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        transition: box-shadow 0.2s ease;
    }
    
    .caregiver-card:hover {
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }
    
    .caregiver-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        margin-right: 15px;
        object-fit: cover;
        border: 2px solid #ddd;
    }
    
    .caregiver-info {
        flex-grow: 1;
    }
    
    .caregiver-info h4 {
        margin: 0 0 5px 0;
        color: #333;
        font-size: 18px;
    }
    
    .caregiver-details {
        margin: 0;
        color: #666;
        font-size: 14px;
    }
    
    .caregiver-actions {
        display: flex;
        gap: 10px;
        align-items: center;
    }
    
    .assign-form {
        background: white;
        padding: 25px;
        border-radius: 12px;
        border: 1px solid #ddd;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
    }
    
    .btn:hover {
        opacity: 0.9;
        transform: translateY(-1px);
        transition: all 0.2s ease;
    }
    
    .msg-error {
        color: #d32f2f;
        background: #ffebee;
        padding: 15px;
        border-radius: 5px;
        border-left: 4px solid #d32f2f;
    }
    
    .msg-success {
        color: #2e7d32;
        background: #e8f5e8;
        padding: 15px;
        border-radius: 5px;
        border-left: 4px solid #2e7d32;
    }
    
    .msg-warning {
        color: #f57c00;
        background: #fff8e1;
        padding: 15px;
        border-radius: 5px;
        border-left: 4px solid #f57c00;
    }
    
    .availability-badge {
        display: inline-block;
        margin-top: 5px;
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: bold;
    }
    
    .badge-available {
        background: #d4edda;
        color: #155724;
    }
    
    .badge-unavailable {
        background: #f8d7da;
        color: #721c24;
    }
    
    .btn-toggle {
        padding: 6px 12px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 12px;
        font-weight: 500;
        transition: all 0.2s ease;
    }
    
    .btn-toggle:hover {
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }
    
    .btn-make-unavailable {
        background: #ffc107;
        color: #212529;
    }
    
    .btn-make-unavailable:hover {
        background: #e0a800;
    }
    
    .btn-make-available {
        background: #28a745;
        color: white;
    }
    
    .btn-make-available:hover {
        background: #218838;
    }
    
    .btn-remove {
        padding: 6px 12px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 12px;
        font-weight: 500;
        background: #dc3545;
        color: white;
        transition: all 0.2s ease;
    }
    
    .btn-remove:hover {
        background: #c82333;
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }
</style>
