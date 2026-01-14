<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Admin service/product edit form page
--%>

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
        String imagePath = (String) service.get("imagePath");
%>
    <form action="<%= request.getContextPath() %>/admin/service" method="post" enctype="multipart/form-data">
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
        
        <label>Service Image:</label>
        <div style="margin-bottom: 15px;">
            <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                <div style="margin-bottom: 10px;">
                    <img src="<%= request.getContextPath() %>/images/services/<%= imagePath %>" 
                         alt="Current service image" 
                         style="max-width: 200px; max-height: 150px; border: 1px solid #ddd; border-radius: 5px;">
                    <p style="margin: 5px 0; font-size: 14px; color: #666;">Current image: <%= imagePath %></p>
                </div>
            <% } %>
            
            <input type="file" name="imageFile" accept="image/*" style="margin-bottom: 10px;">
            <div style="margin-bottom: 10px;">
                <input type="checkbox" name="keepCurrentImage" value="true" id="keepCurrentImage" checked>
                <label for="keepCurrentImage" style="display: inline; margin-left: 5px;">Keep current image</label>
            </div>
            <small style="display: block; color: #666;">
                Supported formats: JPG, JPEG, PNG, GIF, WebP (Max: 5MB)<br>
                Uncheck "Keep current image" and select a file to replace the current image
            </small>
        </div>
        
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

<script>
// Image upload management for edit service form
const fileInput = document.querySelector('input[name="imageFile"]');
const keepCurrentCheckbox = document.querySelector('input[name="keepCurrentImage"]');

// Handle file selection
fileInput.addEventListener('change', function(e) {
    const file = e.target.files[0];
    let preview = document.getElementById('newImagePreview');
    
    if (file) {
        // Validate file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
            alert('File size exceeds 5MB limit. Please choose a smaller image.');
            e.target.value = '';
            if (preview) preview.remove();
            return;
        }
        
        // Validate file type
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
        if (!allowedTypes.includes(file.type)) {
            alert('Invalid file type. Please select a JPG, PNG, GIF, or WebP image.');
            e.target.value = '';
            if (preview) preview.remove();
            return;
        }
        
        // Automatically uncheck "keep current image" when new file is selected
        keepCurrentCheckbox.checked = false;
        
        const reader = new FileReader();
        reader.onload = function(e) {
            if (!preview) {
                preview = document.createElement('div');
                preview.id = 'newImagePreview';
                preview.style.marginTop = '10px';
                preview.style.padding = '10px';
                preview.style.border = '1px solid #4CAF50';
                preview.style.borderRadius = '5px';
                preview.style.backgroundColor = '#f9f9f9';
                fileInput.parentNode.appendChild(preview);
            }
            preview.innerHTML = '<strong style="color: #4CAF50;">New Image Preview:</strong><br>' +
                              '<img src="' + e.target.result + '" alt="New Preview" style="max-width: 200px; max-height: 150px; border: 1px solid #ddd; border-radius: 5px; margin: 5px 0;"><br>' +
                              '<small style="color: #666;">' + file.name + ' (' + (file.size / 1024 / 1024).toFixed(2) + ' MB)</small>';
        };
        reader.readAsDataURL(file);
    } else {
        if (preview) preview.remove();
        keepCurrentCheckbox.checked = true;
    }
});

// Handle keep current image checkbox
keepCurrentCheckbox.addEventListener('change', function(e) {
    if (e.target.checked) {
        // Clear file input if user wants to keep current image
        fileInput.value = '';
        const preview = document.getElementById('newImagePreview');
        if (preview) preview.remove();
    }
});
</script>
<%
    }
%>