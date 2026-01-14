/*
 * Name: GitHub Copilot
 * Date: January 14, 2026
 * Description: Admin caregiver management servlet with CRUD operations and image upload support
 */
package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import handlers.AdminCaregiverHandler;
import lib.SessionManagement;
import lib.ImageUploadUtil;

@WebServlet("/admin/caregiver")
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024, // 5MB
    maxRequestSize = 10 * 1024 * 1024, // 10MB
    fileSizeThreshold = 1024 * 1024 // 1MB
)
public class AdminCaregiverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            // Redirect to caregiver listing
            response.sendRedirect(request.getContextPath() + "/admin/caregivers");
            return;
        }

        // Handle delete action
        if ("delete".equals(action)) {
            String caregiverIdStr = request.getParameter("caregiverId");
            if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
                return;
            }

            int caregiverId;
            try {
                caregiverId = Integer.parseInt(caregiverIdStr.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
                return;
            }

            try {
                boolean ok = AdminCaregiverHandler.deleteCaregiver(caregiverId);
                if (!ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=not_found");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=deleted");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=db_error");
            }
            return;
        }

        // Handle activate/deactivate actions
        String caregiverIdStr = request.getParameter("caregiverId");
        if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty() || 
            !("activate".equals(action) || "deactivate".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        int caregiverId;
        try {
            caregiverId = Integer.parseInt(caregiverIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        boolean newStatus = "activate".equals(action);
        try {
            boolean ok = AdminCaregiverHandler.setCaregiverActive(caregiverId, newStatus);
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=" + action + "d");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=db_error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            handleAdd(request, response);
        } else if ("edit".equals(action)) {
            handleEdit(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String specialization = request.getParameter("specialization");
        String yearsOfExperienceStr = request.getParameter("yearsOfExperience");
        String isActiveStr = request.getParameter("isActive");

        // Validation
        if (firstName == null || firstName.trim().isEmpty() || 
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phoneNumber == null || phoneNumber.trim().isEmpty() ||
            specialization == null || specialization.trim().isEmpty() ||
            yearsOfExperienceStr == null || isActiveStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        int yearsOfExperience;
        try {
            yearsOfExperience = Integer.parseInt(yearsOfExperienceStr);
            if (yearsOfExperience < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        boolean isActive = Boolean.parseBoolean(isActiveStr);

        // Handle profile image upload
        String profileImagePath = null;
        try {
            profileImagePath = processProfileImageUpload(request);
        } catch (ServletException | IOException e) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=upload_error&details=" + 
                                URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        try {
            // Extract hourly rate from specialization or use default
            double hourlyRate = 0.0;
            try {
                // Specialization field might contain hourly rate or be a description
                if (specialization != null && !specialization.trim().isEmpty()) {
                    try {
                        hourlyRate = Double.parseDouble(specialization.trim());
                    } catch (NumberFormatException e) {
                        hourlyRate = 0.0; // Use default if not a number
                    }
                }
            } catch (Exception e) {
                hourlyRate = 0.0;
            }
            
            boolean ok = AdminCaregiverHandler.addCaregiver(
                firstName.trim(), lastName.trim(), specialization.trim(), 
                hourlyRate, "", profileImagePath
            );
            
            if (!ok) {
                // Clean up uploaded image if database insert failed
                if (profileImagePath != null) {
                    deleteProfileImage(request, profileImagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=db_error");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=added");
            }
        } catch (SQLException e) {
            // Clean up uploaded image if database error
            if (profileImagePath != null) {
                deleteProfileImage(request, profileImagePath);
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=db_error");
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String caregiverIdStr = request.getParameter("caregiverId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String specialization = request.getParameter("specialization");  // Maps to qualifications
        String yearsOfExperienceStr = request.getParameter("yearsOfExperience");  // Maps to hourlyRate
        String keepCurrentImage = request.getParameter("keepCurrentImage");

        // Validation
        if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty() ||
            firstName == null || firstName.trim().isEmpty() || 
            lastName == null || lastName.trim().isEmpty() ||
            specialization == null || specialization.trim().isEmpty() ||
            yearsOfExperienceStr == null || yearsOfExperienceStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        int caregiverId;
        double hourlyRate;
        try {
            caregiverId = Integer.parseInt(caregiverIdStr);
            hourlyRate = Double.parseDouble(yearsOfExperienceStr);
            if (hourlyRate < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=invalid");
            return;
        }

        // Handle profile image upload
        String newImagePath = null;
        String oldImagePath = null;
        
        try {
            // Get current caregiver to find old image
            java.util.Map<String, Object> currentCaregiver = AdminCaregiverHandler.getCaregiverById(caregiverId);
            if (currentCaregiver != null) {
                oldImagePath = (String) currentCaregiver.get("profileImagePath");
            }
            
            // Check if user wants to keep current image or upload new one
            if ("true".equals(keepCurrentImage)) {
                newImagePath = oldImagePath; // Keep existing image
            } else {
                // Try to upload new image
                newImagePath = processProfileImageUpload(request);
                if (newImagePath == null) {
                    newImagePath = oldImagePath; // No new image uploaded, keep old one
                }
            }
        } catch (ServletException | IOException | SQLException e) {
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=upload_error&details=" + 
                                URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        try {
            boolean ok = AdminCaregiverHandler.updateCaregiver(
                caregiverId, firstName.trim(), lastName.trim(), 
                specialization.trim(), hourlyRate, "", newImagePath
            );
            
            if (!ok) {
                // Clean up new uploaded image if database update failed
                if (newImagePath != null && !newImagePath.equals(oldImagePath)) {
                    deleteProfileImage(request, newImagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=not_found");
            } else {
                // Delete old image if a new one was successfully uploaded and saved
                if (newImagePath != null && !newImagePath.equals(oldImagePath) && 
                    oldImagePath != null && !oldImagePath.equals("default_profile.png")) {
                    deleteProfileImage(request, oldImagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=updated");
            }
        } catch (SQLException e) {
            // Clean up new uploaded image if database error
            if (newImagePath != null && !newImagePath.equals(oldImagePath)) {
                deleteProfileImage(request, newImagePath);
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/caregivers?msg=db_error");
        }
    }

    /**
     * Process profile image upload specifically for caregivers
     */
    private String processProfileImageUpload(HttpServletRequest request) throws ServletException, IOException {
        // Use ImageUploadUtil but customize for caregiver directory
        String uploadPath = request.getServletContext().getRealPath("/") + "images/caregivers/";
        
        jakarta.servlet.http.Part filePart = request.getPart("profileImageFile");
        if (filePart == null || filePart.getSize() == 0) {
            return null; // No file uploaded
        }
        
        // Validate file size
        if (filePart.getSize() > 5 * 1024 * 1024) {
            throw new IOException("File size exceeds maximum allowed size of 5MB");
        }
        
        // Get original filename and validate extension
        String originalFileName = getFileName(filePart);
        if (originalFileName == null || originalFileName.trim().isEmpty()) {
            throw new IOException("Invalid file name");
        }
        
        String fileExtension = getFileExtension(originalFileName);
        if (!isValidImageExtension(fileExtension)) {
            throw new IOException("Invalid file type. Allowed types: JPG, JPEG, PNG, GIF, WebP");
        }
        
        // Generate unique filename for caregiver profile
        String uniqueFileName = "caregiver_" + System.currentTimeMillis() + "_" + 
                               java.util.UUID.randomUUID().toString().substring(0, 8) + "." + fileExtension;
        
        // Ensure upload directory exists
        java.io.File uploadDir = new java.io.File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save file
        java.nio.file.Path targetPath = java.nio.file.Paths.get(uploadPath, uniqueFileName);
        java.nio.file.Files.copy(filePart.getInputStream(), targetPath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        
        return uniqueFileName;
    }
    
    private void deleteProfileImage(HttpServletRequest request, String fileName) {
        if (fileName == null || fileName.equals("default_profile.png")) {
            return; // Don't delete default image
        }
        
        try {
            String uploadPath = request.getServletContext().getRealPath("/") + "images/caregivers/";
            java.nio.file.Path filePath = java.nio.file.Paths.get(uploadPath, fileName);
            java.nio.file.Files.deleteIfExists(filePath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private String getFileName(jakarta.servlet.http.Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
    
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex + 1).toLowerCase();
        }
        return "";
    }
    
    private boolean isValidImageExtension(String extension) {
        String[] allowedExtensions = {"jpg", "jpeg", "png", "gif", "webp"};
        for (String allowed : allowedExtensions) {
            if (allowed.equals(extension.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}