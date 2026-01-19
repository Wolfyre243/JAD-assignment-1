<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Karys Goh Yi Xin  
  Date: January 14, 2026
  Description: Admin caregiver edit form page with profile image management
--%>

<h1>Edit Caregiver</h1>
<p><a href="<%= request.getContextPath() %>/admin/caregivers">← Back to Caregivers</a></p>
<hr>

<%
    java.util.Map<String,Object> caregiver = (java.util.Map<String,Object>) request.getAttribute("caregiver");
    String caregiverError = (String) request.getAttribute("caregiverError");
    if (caregiverError != null) {
%>
    <p class="msg-error"><%= caregiverError %></p>
<%
    } else if (caregiver == null) {
%>
    <p><em>No caregiver selected.</em></p>
<%
    } else {
        int caregiverId = (caregiver.get("caregiverId") instanceof Number) ? ((Number) caregiver.get("caregiverId")).intValue() : Integer.parseInt(caregiver.get("caregiverId").toString());
        String firstName = (String) caregiver.get("firstName");
        String lastName = (String) caregiver.get("lastName");
        String qualifications = (String) caregiver.get("qualifications");
        double hourlyRate = (caregiver.get("hourlyRate") instanceof Number) ? ((Number) caregiver.get("hourlyRate")).doubleValue() : 0.0;
        String profileImagePath = (String) caregiver.get("profileImagePath");
%>
    <form action="<%= request.getContextPath() %>/admin/caregiver" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="caregiverId" value="<%= caregiverId %>">
        
        <label>First Name:</label>
        <input type="text" name="firstName" value="<%= firstName %>" required>
        
        <label>Last Name:</label>
        <input type="text" name="lastName" value="<%= lastName %>" required>
        
        <label>Qualifications:</label>
        <textarea name="specialization" required style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; font-family: 'Georgia', serif; min-height: 100px;"><%= qualifications != null ? qualifications : "" %></textarea>
        
        <label>Hourly Rate ($):</label>
        <input type="number" name="yearsOfExperience" min="0" step="0.01" value="<%= String.format("%.2f", hourlyRate) %>" required>
        
        <label>Profile Image:</label>
        <div style="margin-bottom: 15px;">
            <% if (profileImagePath != null && !profileImagePath.trim().isEmpty()) { %>
                <div style="margin-bottom: 15px;">
                    <strong>Current Profile Image:</strong><br>
                    <img src="<%= request.getContextPath() %>/images/caregivers/<%= profileImagePath %>" 
                         alt="Current profile image" 
                         style="width: 120px; height: 120px; object-fit: cover; border-radius: 50%; border: 3px solid #ddd; margin: 10px 0;">
                    <p style="margin: 5px 0; font-size: 14px; color: #666;"><%= profileImagePath %></p>
                </div>
            <% } %>
            
            <input type="file" name="profileImageFile" accept="image/*" style="margin-bottom: 10px;">
            <div style="margin-bottom: 10px;">
                <input type="checkbox" name="keepCurrentImage" value="true" id="keepCurrentImage" checked>
                <label for="keepCurrentImage" style="display: inline; margin-left: 5px;">Keep current profile image</label>
            </div>
            <small style="display: block; color: #666;">
                Supported formats: JPG, JPEG, PNG, GIF, WebP (Max: 5MB)<br>
                Uncheck "Keep current image" and select a file to replace the current profile image<br>
                Recommended: Square image, at least 200x200 pixels
            </small>
        </div>
        
        <button type="submit" class="btn">Save Changes</button>
        <a href="<%= request.getContextPath() %>/admin/caregivers" class="btn btn-secondary">Cancel</a>
    </form>

<script>
// Profile image management for edit caregiver form
const fileInput = document.querySelector('input[name="profileImageFile"]');
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
                preview.style.marginTop = '15px';
                preview.style.padding = '15px';
                preview.style.border = '2px solid #4CAF50';
                preview.style.borderRadius = '10px';
                preview.style.backgroundColor = '#f9fff9';
                fileInput.parentNode.appendChild(preview);
            }
            preview.innerHTML = '<strong style="color: #4CAF50;">New Profile Image Preview:</strong><br>' +
                              '<img src="' + e.target.result + '" alt="New Preview" style="width: 120px; height: 120px; object-fit: cover; border-radius: 50%; border: 3px solid #4CAF50; margin: 10px 0;"><br>' +
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

<style>
    /* Form styling for caregiver management */
    form {
        max-width: 600px;
    }
    
    label {
        display: block;
        font-weight: bold;
        margin-bottom: 5px;
        margin-top: 15px;
        color: #333;
    }
    
    input[type="text"], 
    input[type="email"], 
    input[type="tel"], 
    input[type="number"], 
    select {
        width: 100%;
        padding: 8px 12px;
        font-size: 14px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-family: 'Georgia', serif;
    }
    
    input[type="file"] {
        padding: 5px;
        border: 1px dashed #ccc;
        border-radius: 5px;
        background: #fafafa;
        width: 100%;
    }
    
    .btn {
        background: #b3003b;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
        text-decoration: none;
        display: inline-block;
        margin: 20px 10px 10px 0;
        font-family: 'Georgia', serif;
    }
    
    .btn:hover {
        background: #8b0028;
    }
    
    .btn-secondary {
        background: #666;
    }
    
    .btn-secondary:hover {
        background: #555;
    }
    
    .msg-error {
        color: #d32f2f;
        background: #ffebee;
        padding: 10px;
        border-radius: 5px;
        border-left: 4px solid #d32f2f;
    }
</style>