<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin form to add new service with category dropdown using JDBC utility and AuthServlet session
--%>
    <h1>Add New Service</h1>
    <p><a href="<%= request.getContextPath() %>/admin/services">← Back to Services</a></p>
    <hr>

    <!-- Form submits to AdminServiceServlet -->
    <form action="<%= request.getContextPath() %>/admin/service" method="post">
        <input type="hidden" name="action" value="add" />
        
        <label>Service Name:</label>
        <input type="text" name="name" required>
        
        <label>Category:</label>
        <select name="categoryId" required>
            <option value="">Select Category</option>
            <%
                java.util.List<java.util.Map<String,Object>> categories = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("categories");
                if (categories != null) {
                    for (java.util.Map<String,Object> c : categories) {
                        int categoryId = (Integer) c.get("categoryId");
                        String categoryName = (String) c.get("name");
            %>
                        <option value="<%= categoryId %>"><%= categoryName %></option>
            <%
                    }
                } else {
            %>
                    <option>Error loading categories</option>
            <%
                }
            %>
        </select>
        
        <label>Description:</label>
        <textarea name="description" rows="5"></textarea>
        
        <label>Price:</label>
        <input type="number" name="price" step="0.01" min="0" required>
        
        <label>Active:</label>
        <div style="margin-bottom: 15px;">
            <input type="radio" name="isActive" value="true" id="active-yes" checked>
            <label for="active-yes" style="display: inline; margin-right: 15px;">Yes</label>
            <input type="radio" name="isActive" value="false" id="active-no">
            <label for="active-no" style="display: inline;">No</label>
        </div>
        
        <button type="submit" class="btn">Add Service</button>
        <a href="<%= request.getContextPath() %>/admin/services" class="btn btn-secondary">Cancel</a>
    </form>

