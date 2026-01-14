<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: GitHub Copilot
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
    
    <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px; border-left: 4px solid #b3003b;">
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
            <div style="display: grid; gap: 15px; margin-top: 15px;">
                <% for (java.util.Map<String,Object> caregiver : assignedCaregivers) { %>
                    <%
                        int caregiverId = (caregiver.get("caregiverId") instanceof Number) ? ((Number) caregiver.get("caregiverId")).intValue() : Integer.parseInt(caregiver.get("caregiverId").toString());
                        String fullName = (String) caregiver.get("fullName");
                        String qualifications = (String) caregiver.get("qualifications");
                        double hourlyRate = (caregiver.get("hourlyRate") instanceof Number) ? ((Number) caregiver.get("hourlyRate")).doubleValue() : 0.0;
                        String profileImagePath = (String) caregiver.get("profileImagePath");
                        boolean isAvailable = (Boolean) caregiver.get("isAvailable");
                    %>
                    <div style="display: flex; align-items: center; padding: 15px; background: white; border-radius: 10px; border: 1px solid #ddd; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <img src="<%= request.getContextPath() %>/images/caregivers/<%= profileImagePath != null ? profileImagePath : "default_profile.png" %>" 
                             alt="<%= fullName %>" 
                             style="width: 60px; height: 60px; border-radius: 50%; margin-right: 15px; object-fit: cover; border: 2px solid #ddd;">
                        
                        <div style="flex-grow: 1;">
                            <h4 style="margin: 0 0 5px 0; color: #333;"><%= fullName %></h4>
                            <p style="margin: 0; color: #666; font-size: 14px;">
                                <strong><%= qualifications != null ? qualifications : "N/A" %></strong> • $<%= String.format("%.2f", hourlyRate) %>/hr
                            </p>
                            <span class="availability-badge" style="display: inline-block; margin-top: 5px; padding: 3px 8px; border-radius: 12px; font-size: 12px; font-weight: bold;"
                                  <%
                                      if (isAvailable) {
                                  %>
                                  style="background: #d4edda; color: #155724;"
                                  <%
                                      } else {
                                  %>
                                  style="background: #f8d7da; color: #721c24;"
                                  <%
                                      }
                                  %>
                                  >
                                <%= isAvailable ? "Available" : "Unavailable" %>
                            </span>
                        </div>
                        
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="productId" value="<%= productId %>">
                                <input type="hidden" name="caregiverId" value="<%= caregiverId %>">
                                <input type="hidden" name="isAvailable" value="<%= !isAvailable %>">
                                <button type="submit" 
                                        style="padding: 6px 12px; border: none; border-radius: 5px; cursor: pointer; font-size: 12px;"
                                        <%
                                            if (isAvailable) {
                                        %>
                                        style="background: #ffc107; color: #212529;"
                                        <%
                                            } else {
                                        %>
                                        style="background: #28a745; color: white;"
                                        <%
                                            }
                                        %>
                                        onclick="return confirm('<%= isAvailable ? "Mark this caregiver as unavailable?" : "Mark this caregiver as available?" %>');">
                                    <%= isAvailable ? "Mark Unavailable" : "Mark Available" %>
                                </button>
                            </form>
                            
                            <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="productId" value="<%= productId %>">
                                <input type="hidden" name="caregiverId" value="<%= caregiverId %>">
                                <button type="submit" 
                                        style="padding: 6px 12px; border: none; border-radius: 5px; cursor: pointer; font-size: 12px; background: #dc3545; color: white;"
                                        onclick="return confirm('Remove <%= fullName %> from this service?');">
                                    Remove
                                </button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <p style="color: #666; font-style: italic;">No caregivers assigned to this service yet.</p>
        <% } %>
    </div>

    <!-- Add Caregiver Section -->
    <div style="margin-top: 30px;">
        <h3>Add Caregivers to Service</h3>
        <% if (availableCaregivers != null && !availableCaregivers.isEmpty()) { %>
            <form action="<%= request.getContextPath() %>/admin/service-caregiver" method="post" 
                  style="background: #f8f9fa; padding: 20px; border-radius: 10px; border: 1px solid #ddd;">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" name="productId" value="<%= productId %>">
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-weight: bold; margin-bottom: 10px; color: #333;">Select Caregiver:</label>
                    <select name="caregiverId" required style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; font-family: 'Georgia', serif;">
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
                </div>
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-weight: bold; margin-bottom: 10px; color: #333;">Initial Status:</label>
                    <div>
                        <input type="radio" name="isAvailable" value="true" id="available-yes" checked>
                        <label for="available-yes" style="display: inline; margin-right: 15px; margin-left: 5px;">Available</label>
                        <input type="radio" name="isAvailable" value="false" id="available-no">
                        <label for="available-no" style="display: inline; margin-left: 5px;">Unavailable</label>
                    </div>
                </div>
                
                <button type="submit" class="btn" style="background: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-family: 'Georgia', serif;">
                    Assign Caregiver
                </button>
            </form>
        <% } else { %>
            <p style="color: #666; font-style: italic;">All active caregivers are already assigned to this service.</p>
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
    .btn:hover {
        opacity: 0.9;
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
</style>
