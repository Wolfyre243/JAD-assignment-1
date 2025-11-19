<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<h1>Edit Service</h1>
<p><a href="<%= request.getContextPath() %>/admin/services">← Back to Services</a></p>
<hr>

<%
    java.util.Map<String,Object> service = (java.util.Map<String,Object>) request.getAttribute("service");
    java.util.List<java.util.Map<String,Object>> categories = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("categories");
    String serviceError = (String) request.getAttribute("serviceError");
    if (serviceError != null) {
%>
    <p class="msg-error"><%= serviceError %></p>
<%
    } else if (service == null) {
%>
    <p><em>No service selected.</em></p>
<%
    } else {
        int productId = (Integer) service.get("productId");
        String name = (String) service.get("name");
        int selectedCat = (Integer) service.get("categoryId");
        String description = (String) service.get("description");
        double price = (Double) service.get("price");
        boolean isActive = (Boolean) service.get("isActive");
%>
    <form action="<%= request.getContextPath() %>/admin/service" method="post">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="productId" value="<%= productId %>">
        
        <label>Name:</label>
        <input type="text" name="name" value="<%= name %>" required>
        
        <label>Category:</label>
        <select name="categoryId" required>
            <% if (categories != null) {
                for (java.util.Map<String,Object> c : categories) {
                    int catId = (Integer) c.get("categoryId");
                    String catName = (String) c.get("categoryName");
                    boolean selected = (catId == selectedCat);
            %>
                    <option value="<%= catId %>" <%= selected ? "selected" : "" %>><%= catName %></option>
            <%   }
            } %>
        </select>
        
        <label>Description:</label>
        <textarea name="description" rows="5"><%= description != null ? description : "" %></textarea>
        
        <label>Price:</label>
        <input type="number" name="price" step="0.01" min="0" value="<%= String.format("%.2f", price) %>" required>
        
        <label>Active:</label>
        <div style="margin-bottom: 15px;">
            <input type="radio" name="isActive" value="true" id="edit-active-yes" <%= isActive ? "checked" : "" %>>
            <label for="edit-active-yes" style="display: inline; margin-right: 15px;">Yes</label>
            <input type="radio" name="isActive" value="false" id="edit-active-no" <%= !isActive ? "checked" : "" %>>
            <label for="edit-active-no" style="display: inline;">No</label>
        </div>
        
        <button type="submit" class="btn">Save Changes</button>
        <a href="<%= request.getContextPath() %>/admin/services" class="btn btn-secondary">Cancel</a>
    </form>
<%
    }
%>