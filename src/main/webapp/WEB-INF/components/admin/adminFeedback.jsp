<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<h1>Feedback Management</h1>
<p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
<hr>

<!-- Filter Section -->
<div style="margin: 20px 0; padding: 20px; background: #f9f9f9; border-radius: 8px;">
    <form method="get" action="<%= request.getContextPath() %>/admin/feedback" style="display: flex; flex-wrap: wrap; align-items: center; gap: 15px;">
        <div style="display: flex; align-items: center; gap: 10px;">
            <label for="productFilter" style="font-weight: bold; font-size: 16px;">Service:</label>
            <select name="productId" id="productFilter" style="padding: 8px 12px; font-size: 15px; border-radius: 5px; border: 1px solid #ccc; font-family: 'Georgia', serif; min-width: 180px;">
                <option value="all">All Services</option>
                <%
                    java.util.List<java.util.Map<String,Object>> products = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("products");
                    String selectedProductId = (String) request.getAttribute("selectedProductId");
                    if (products != null) {
                        for (java.util.Map<String,Object> product : products) {
                            int productId = (Integer) product.get("productId");
                            String productName = (String) product.get("name");
                            boolean isSelected = selectedProductId != null && selectedProductId.equals(String.valueOf(productId));
                %>
                            <option value="<%= productId %>" <%= isSelected ? "selected" : "" %>><%= productName %></option>
                <%
                        }
                    }
                %>
            </select>
        </div>

        <div style="display: flex; align-items: center; gap: 10px;">
            <label for="caregiverFilter" style="font-weight: bold; font-size: 16px;">Caregiver:</label>
            <select name="caregiverId" id="caregiverFilter" style="padding: 8px 12px; font-size: 15px; border-radius: 5px; border: 1px solid #ccc; font-family: 'Georgia', serif; min-width: 180px;">
                <option value="all">All Caregivers</option>
                <%
                    java.util.List<java.util.Map<String,Object>> caregivers = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("caregivers");
                    String selectedCaregiverId = (String) request.getAttribute("selectedCaregiverId");
                    if (caregivers != null) {
                        for (java.util.Map<String,Object> caregiver : caregivers) {
                            int caregiverId = (Integer) caregiver.get("caregiverId");
                            String caregiverName = (String) caregiver.get("name");
                            boolean isSelected = selectedCaregiverId != null && selectedCaregiverId.equals(String.valueOf(caregiverId));
                %>
                            <option value="<%= caregiverId %>" <%= isSelected ? "selected" : "" %>><%= caregiverName %></option>
                <%
                        }
                    }
                %>
            </select>
        </div>

        <button type="submit" style="padding: 8px 20px; background: #ffbfd0; color: #000; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; font-family: 'Georgia', serif;">Apply Filters</button>
        <% if (!"all".equals(selectedProductId) || !"all".equals(selectedCaregiverId)) { %>
            <a href="<%= request.getContextPath() %>/admin/feedback" style="padding: 8px 20px; background: #e0e0e0; color: #000; text-decoration: none; border-radius: 5px; font-weight: bold;">Clear Filters</a>
        <% } %>
    </form>
</div>

<h2>
    <% 
        String filterTitle = "All Feedback";
        java.util.List<String> filterParts = new java.util.ArrayList<>();
        
        if (!"all".equals(selectedProductId) && products != null) {
            for (java.util.Map<String,Object> product : products) {
                if (String.valueOf(product.get("productId")).equals(selectedProductId)) {
                    filterParts.add("Service: " + product.get("name"));
                    break;
                }
            }
        }
        
        if (!"all".equals(selectedCaregiverId) && caregivers != null) {
            for (java.util.Map<String,Object> caregiver : caregivers) {
                if (String.valueOf(caregiver.get("caregiverId")).equals(selectedCaregiverId)) {
                    filterParts.add("Caregiver: " + caregiver.get("name"));
                    break;
                }
            }
        }
        
        if (!filterParts.isEmpty()) {
            filterTitle = "Feedback - " + String.join(" | ", filterParts);
        }
    %>
    <%= filterTitle %>
</h2>

<%
    java.util.List<java.util.Map<String,Object>> feedbacks = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("feedbacks");
    if (feedbacks == null || feedbacks.isEmpty()) {
%>
    <p><em>No feedback available for the selected filters.</em></p>
<%
    } else {
%>
    <p style="margin: 10px 0; color: #555;"><strong><%= feedbacks.size() %></strong> review(s) found</p>
    
    <div style="overflow-x: auto; margin: 20px 0;">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Service</th>
                    <th>Caregiver</th>
                    <th>User Email</th>
                    <th>Overall Rating</th>
                    <th>Caregiver Rating</th>
                    <th>Comments</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (java.util.Map<String,Object> f : feedbacks) {
                    int feedbackId = (Integer) f.get("feedbackId");
                    int overallRating = (Integer) f.get("overallRating");
                    Integer caregiverRating = (Integer) f.get("caregiverRating");
                    String comments = (String) f.get("comments");
                    java.sql.Timestamp createdAt = (java.sql.Timestamp) f.get("createdAt");
                    String email = (String) f.get("email");
                    String productName = (String) f.get("productName");
                    String caregiverName = (String) f.get("caregiverName");
                    String formattedDate = createdAt != null ? createdAt.toString().substring(0,19).replace("T"," ") : "";
            %>
                <tr>
                    <td><%= feedbackId %></td>
                    <td><strong><%= productName != null ? productName : "N/A" %></strong></td>
                    <td><%= caregiverName != null ? caregiverName : "N/A" %></td>
                    <td><%= email %></td>
                    <td><%= overallRating %> / 5</td>
                    <td><%= caregiverRating != null ? caregiverRating + " / 5" : "N/A" %></td>
                    <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><%= comments != null && !comments.trim().isEmpty() ? comments : "No comments" %></td>
                    <td style="white-space: nowrap;"><%= formattedDate %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/admin/feedback?include=delete&feedbackId=<%= feedbackId %>"
                           style="color:red;">Delete</a>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
<%
    }
%>
