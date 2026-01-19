<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Karys Goh Yi Xin
  Date: January 14, 2026
  Description: Admin form to add new caregiver with profile image upload
--%>
    <h1>Add New Caregiver</h1>
    <p><a href="<%= request.getContextPath() %>/admin/caregivers">← Back to Caregivers</a></p>
    <hr>

    <!-- Form submits to AdminCaregiverServlet with multipart encoding for file upload -->
    <form action="<%= request.getContextPath() %>/admin/caregiver" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="add" />
        
        <label>First Name:</label>
        <input type="text" name="firstName" required>
        
        <label>Last Name:</label>
        <input type="text" name="lastName" required>
        
        <label>Email:</label>
        <input type="email" name="email" required>
        
        <label>Phone Number:</label>
        <input type="tel" name="phoneNumber" required>
        
        <label>Specialization:</label>
        <select name="specialization" required>
            <option value="">Select Specialization</option>
            <option value="Personal Care">Personal Care</option>
            <option value="Medical Care">Medical Care</option>
            <option value="Companionship">Companionship</option>
            <option value="Meal Preparation">Meal Preparation</option>
            <option value="Housekeeping">Housekeeping</option>
            <option value="Transportation">Transportation</option>
            <option value="Physiotherapy">Physiotherapy</option>
            <option value="Nursing">Nursing</option>
            <option value="General Care">General Care</option>
        </select>
        
        <label>Years of Experience:</label>
        <input type="number" name="yearsOfExperience" min="0" max="50" required>
        
        <label>Profile Image:</label>
        <div style="margin-bottom: 15px;">
            <input type="file" name="profileImageFile" accept="image/*" style="margin-bottom: 10px;">
            <small style="display: block; color: #666;">
                Supported formats: JPG, JPEG, PNG, GIF, WebP (Max: 5MB)<br>
                Leave empty to use default profile image<br>
                Recommended: Square image, at least 200x200 pixels
            </small>
        </div>
        
        <label>Active:</label>
        <div style="margin-bottom: 15px;">
            <input type="radio" name="isActive" value="true" id="active-yes" checked>
            <label for="active-yes" style="display: inline; margin-right: 15px;">Yes</label>
            <input type="radio" name="isActive" value="false" id="active-no">
            <label for="active-no" style="display: inline;">No</label>
        </div>
        
        <button type="submit" class="btn">Add Caregiver</button>
        <a href="<%= request.getContextPath() %>/admin/caregivers" class="btn btn-secondary">Cancel</a>
    </form>

<script>
// Profile image upload preview for add caregiver form
document.querySelector('input[name="profileImageFile"]').addEventListener('change', function(e) {
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
                preview.style.padding = '10px';
                preview.style.border = '1px solid #4CAF50';
                preview.style.borderRadius = '10px';
                preview.style.backgroundColor = '#f9fff9';
                file.target.parentNode.appendChild(preview);
            }
            preview.innerHTML = '<strong style="color: #4CAF50;">Profile Image Preview:</strong><br>' +
                              '<img src="' + e.target.result + '" alt="Preview" style="width: 150px; height: 150px; object-fit: cover; border-radius: 50%; border: 3px solid #4CAF50; margin: 10px 0;"><br>' +
                              '<small style="color: #666;">' + file.name + ' (' + (file.size / 1024 / 1024).toFixed(2) + ' MB)</small>';
        };
        reader.readAsDataURL(file);
    } else {
        if (preview) preview.remove();
    }
});
</script>

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
</style>