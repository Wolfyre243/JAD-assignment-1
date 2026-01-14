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

    <!-- Form submits to AdminServiceServlet with multipart encoding for file upload -->
    <form action="<%= request.getContextPath() %>/admin/service" method="post" enctype="multipart/form-data">
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
                        String categoryName = (String) c.get("categoryName");
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
        
        <label>Service Image:</label>
        <div style="margin-bottom: 15px;">
            <input type="file" name="imageFile" accept="image/*" style="margin-bottom: 10px;">
            <small style="display: block; color: #666;">
                Supported formats: JPG, JPEG, PNG, GIF, WebP (Max: 5MB)<br>
                Leave empty to use default image
            </small>
        </div>
        
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

<script>
// Image upload preview for add service form
document.querySelector('input[name="imageFile"]').addEventListener('change', function(e) {
    const file = e.target.files[0];
    let preview = document.getElementById('imagePreview');
    
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
        
        const reader = new FileReader();
        reader.onload = function(e) {
            if (!preview) {
                preview = document.createElement('div');
                preview.id = 'imagePreview';
                preview.style.marginTop = '10px';
                e.target.parentNode.appendChild(preview);
            }
            preview.innerHTML = '<img src="' + e.target.result + '" alt="Preview" style="max-width: 200px; max-height: 150px; border: 1px solid #ddd; border-radius: 5px;"><br><small style="color: #666;">Preview: ' + file.name + ' (' + (file.size / 1024 / 1024).toFixed(2) + ' MB)</small>';
        };
        reader.readAsDataURL(file);
    } else {
        if (preview) preview.remove();
    }
});
</script>

