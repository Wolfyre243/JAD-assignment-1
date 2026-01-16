<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: GitHub Copilot
  Date: January 14, 2026
  Description: Caregiver profile page - allows caregivers to view and edit their profile information
--%>
<%
    java.util.Map<String, Object> caregiverProfile = (java.util.Map<String, Object>) request.getAttribute("caregiverProfile");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String errorFromAttribute = (String) request.getAttribute("error");
    if (error == null && errorFromAttribute != null) {
        error = errorFromAttribute;
    }
    
    if (caregiverProfile == null) {
        caregiverProfile = new java.util.HashMap<>();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Caregiver</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: "Georgia", serif;
            background-color: #f5f5f5;
        }
        
        .container {
            max-width: 900px;
            margin: 40px auto;
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .page-title {
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 10px;
            text-align: center;
        }
        
        .page-subtitle {
            font-size: 16px;
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            border-bottom: 2px solid black;
            padding-bottom: 20px;
        }
        
        .breadcrumb {
            margin-bottom: 20px;
            font-size: 16px;
        }
        
        .breadcrumb a {
            color: #000;
            text-decoration: none;
            font-weight: 600;
        }
        
        .breadcrumb a:hover {
            text-decoration: underline;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 16px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 2px solid #28a745;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 2px solid #f5c6cb;
        }
        
        .profile-header {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 40px;
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .profile-image-section {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        
        .profile-image {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #ffbfd0;
            margin-bottom: 20px;
        }
        
        .profile-info h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .profile-info p {
            font-size: 16px;
            color: #666;
            margin: 5px 0;
        }
        
        .form-section {
            margin-bottom: 40px;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #ffbfd0;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            font-weight: bold;
            margin-bottom: 8px;
            font-size: 16px;
        }
        
        input[type="text"],
        input[type="number"],
        textarea,
        input[type="file"] {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #ccc;
            border-radius: 10px;
            font-family: "Georgia", serif;
            font-size: 15px;
            transition: border-color 0.3s;
        }
        
        input[type="text"]:focus,
        input[type="number"]:focus,
        textarea:focus {
            outline: none;
            border-color: #ffbfd0;
            box-shadow: 0 0 5px rgba(255, 191, 208, 0.3);
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        input[type="file"] {
            border: 2px dashed #ffbfd0;
            padding: 15px;
            background: #fff9fa;
            cursor: pointer;
        }
        
        .info-text {
            font-size: 13px;
            color: #999;
            margin-top: 5px;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 25px;
        }
        
        button, .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            font-family: "Georgia", serif;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: #ffbfd0;
            color: #000;
            border: 2px solid #000;
        }
        
        .btn-primary:hover {
            background: #ff9fb5;
            box-shadow: 0 4px 10px rgba(255, 191, 208, 0.4);
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #000;
            border: 2px solid #ccc;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        
        .upload-form-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .upload-preview {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        
        .upload-preview img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #ffbfd0;
            margin-bottom: 15px;
        }
        
        @media (max-width: 768px) {
            .container {
                margin: 20px;
                padding: 20px;
            }
            
            .profile-header {
                grid-template-columns: 1fr;
            }
            
            .upload-form-group {
                grid-template-columns: 1fr;
            }
            
            .page-title {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <!-- NAVBAR -->
    <%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>
    
    <div class="container">
        <h1 class="page-title">My Profile</h1>
        <div class="page-subtitle">Manage your caregiver information and profile picture</div>
        
        <div class="messages">
            <%
                if (msg != null) {
                    String msgText = "";
                    switch (msg) {
                        case "profile_updated":
                            msgText = "Profile updated successfully!";
                            %>
                            <div class="alert alert-success"><%= msgText %></div>
                            <%
                            break;
                        case "image_uploaded":
                            msgText = "Profile image uploaded successfully!";
                            %>
                            <div class="alert alert-success"><%= msgText %></div>
                            <%
                            break;
                    }
                }
                
                if (error != null) {
                    String errorText = "";
                    switch (error) {
                        case "profile_not_found":
                            errorText = "Your caregiver profile was not found.";
                            break;
                        case "missing_fields":
                            errorText = "Please fill in all required fields.";
                            break;
                        case "invalid_hourly_rate":
                            errorText = "Please enter a valid hourly rate.";
                            break;
                        case "update_failed":
                            errorText = "Failed to update profile. Please try again.";
                            break;
                        case "no_image_selected":
                            errorText = "Please select an image to upload.";
                            break;
                        case "image_update_failed":
                            errorText = "Failed to update profile image. Please try again.";
                            break;
                        default:
                            errorText = "An error occurred: " + error;
                    }
                    %>
                    <div class="alert alert-error"><%= errorText %></div>
                    <%
                }
            %>
        </div>
        
        <%
            if (caregiverProfile != null && !caregiverProfile.isEmpty()) {
                String profileImagePath = (String) caregiverProfile.get("profileImagePath");
                String imageUrl = (profileImagePath != null && !profileImagePath.isEmpty())
                    ? request.getContextPath() + "/images/caregivers/" + profileImagePath
                    : request.getContextPath() + "/images/caregivers/default_profile.png";
                String firstName = (String) caregiverProfile.get("firstName");
                String lastName = (String) caregiverProfile.get("lastName");
        %>
        
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="profile-image-section">
                <img src="<%= imageUrl %>" alt="Profile Picture" class="profile-image" id="profileImagePreview">
                <p style="font-weight: bold; margin-top: 10px;"><%= firstName %> <%= lastName %></p>
            </div>
            
            <div class="profile-info">
                <h3><%= firstName %> <%= lastName %></h3>
                <p><strong>Hourly Rate:</strong> $<%= caregiverProfile.get("hourlyRate") %>/hr</p>
                <p><strong>Qualifications:</strong></p>
                <p style="color: #666; font-size: 14px; line-height: 1.6;">
                    <%= caregiverProfile.get("qualifications") != null ? caregiverProfile.get("qualifications") : "Not specified" %>
                </p>
            </div>
        </div>
        
        <!-- Edit Profile Form -->
        <div class="form-section">
            <h2 class="section-title">Update Profile Information</h2>
            
            <form action="<%= request.getContextPath() %>/caregiver/profile" method="post" onsubmit="return validateProfileForm();">
                <input type="hidden" name="action" value="update">
                
                <div class="form-group">
                    <label for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" value="<%= caregiverProfile.get("firstName") != null ? caregiverProfile.get("firstName") : "" %>" required>
                </div>
                
                <div class="form-group">
                    <label for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" value="<%= caregiverProfile.get("lastName") != null ? caregiverProfile.get("lastName") : "" %>" required>
                </div>
                
                <div class="form-group">
                    <label for="hourlyRate">Hourly Rate ($) *</label>
                    <input type="number" id="hourlyRate" name="hourlyRate" step="0.01" min="0" value="<%= caregiverProfile.get("hourlyRate") != null ? caregiverProfile.get("hourlyRate") : "" %>" required>
                </div>
                
                <div class="form-group">
                    <label for="qualifications">Qualifications & Certifications</label>
                    <textarea id="qualifications" name="qualifications" placeholder="e.g., RN, CPR Certified, BSc Nursing..."><%= caregiverProfile.get("qualifications") != null ? caregiverProfile.get("qualifications") : "" %></textarea>
                </div>
                
                <div class="button-group">
                    <button type="submit" class="btn-primary">Save Changes</button>
                    <a href="<%= request.getContextPath() %>/" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
        
        <!-- Upload Image Form -->
        <div class="form-section">
            <h2 class="section-title">Update Profile Picture</h2>
            
            <form action="<%= request.getContextPath() %>/caregiver/profile" method="post" enctype="multipart/form-data" onsubmit="return validateImageUpload();">
                <input type="hidden" name="action" value="upload-image">
                
                <div class="upload-form-group">
                    <div class="form-group">
                        <label for="profileImage">Choose Image</label>
                        <input type="file" id="profileImage" name="profileImage" accept="image/*" required>
                        <p class="info-text">Supported formats: JPG, PNG, GIF (Max 10MB)</p>
                    </div>
                    
                    <div class="upload-preview">
                        <p style="margin-bottom: 10px; font-weight: bold;">Preview:</p>
                        <img src="<%= imageUrl %>" alt="Preview" id="newImagePreview">
                    </div>
                </div>
                
                <div class="button-group">
                    <button type="submit" class="btn-primary">Upload Image</button>
                    <a href="<%= request.getContextPath() %>/" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
        
        <%
            } else {
        %>
            <div class="alert alert-error">Unable to load your profile. Please try again later.</div>
        <%
            }
        %>
    </div>
    
    <script>
        function validateProfileForm() {
            const firstName = document.getElementById('firstName').value.trim();
            const lastName = document.getElementById('lastName').value.trim();
            const hourlyRate = document.getElementById('hourlyRate').value.trim();
            
            if (!firstName || !lastName || !hourlyRate) {
                alert('Please fill in all required fields.');
                return false;
            }
            
            if (isNaN(hourlyRate) || parseFloat(hourlyRate) <= 0) {
                alert('Please enter a valid hourly rate.');
                return false;
            }
            
            return true;
        }
        
        function validateImageUpload() {
            const fileInput = document.getElementById('profileImage');
            const file = fileInput.files[0];
            
            if (!file) {
                alert('Please select an image to upload.');
                return false;
            }
            
            const maxSize = 10 * 1024 * 1024; // 10MB
            if (file.size > maxSize) {
                alert('File size exceeds 10MB limit.');
                return false;
            }
            
            const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
            if (!validTypes.includes(file.type)) {
                alert('Please upload a valid image file (JPG, PNG, or GIF).');
                return false;
            }
            
            return true;
        }
        
        // Show image preview when file is selected
        document.addEventListener('DOMContentLoaded', function() {
            const profileImageInput = document.getElementById('profileImage');
            if (profileImageInput) {
                profileImageInput.addEventListener('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            document.getElementById('newImagePreview').src = e.target.result;
                        };
                        reader.readAsDataURL(file);
                    }
                });
            }
        });
    </script>
</body>
</html>
