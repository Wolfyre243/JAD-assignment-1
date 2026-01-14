package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.util.Map;

import db.JDBC;
import handlers.CaregiverProfileHandler;
import lib.ImageUploadUtil;
import lib.SessionManagement;
import models.User;

/**
 * Caregiver Profile Servlet
 * Allows caregivers to view and update their profile information and upload profile images
 */
@WebServlet("/caregiver/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 10 * 1024 * 1024,   // 10MB
    maxRequestSize = 15 * 1024 * 1024 // 15MB
)
public class CaregiverProfileServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is logged in and has caregiver role
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isCaregiver(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }
        
        try {
            Integer userId = SessionManagement.getUserId(request);
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login/");
                return;
            }
            
            try (Connection conn = JDBC.connect()) {
                // Get caregiver profile by user ID
                Map<String, Object> caregiverProfile = CaregiverProfileHandler.getCaregiverByUserId(conn, userId);
                
                if (caregiverProfile == null) {
                    request.setAttribute("error", "Caregiver profile not found.");
                    request.getRequestDispatcher("/WEB-INF/components/caregiver/profile.jsp").forward(request, response);
                    return;
                }
                
                // Set profile data to request
                request.setAttribute("caregiverProfile", caregiverProfile);
                request.setAttribute("caregiverId", caregiverProfile.get("caregiverId"));
                request.setAttribute("firstName", caregiverProfile.get("firstName"));
                request.setAttribute("lastName", caregiverProfile.get("lastName"));
                request.setAttribute("qualifications", caregiverProfile.get("qualifications"));
                request.setAttribute("hourlyRate", caregiverProfile.get("hourlyRate"));
                request.setAttribute("profileImagePath", caregiverProfile.get("profileImagePath"));
                
                request.getRequestDispatcher("/WEB-INF/components/caregiver/profile.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading profile: " + e.getMessage());
            try {
                request.getRequestDispatcher("/WEB-INF/components/caregiver/profile.jsp").forward(request, response);
            } catch (ServletException | IOException ex) {
                ex.printStackTrace();
            }
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is logged in and has caregiver role
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isCaregiver(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            Integer userId = SessionManagement.getUserId(request);
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login/");
                return;
            }
            
            try (Connection conn = JDBC.connect()) {
                // Get caregiver profile
                Map<String, Object> caregiverProfile = CaregiverProfileHandler.getCaregiverByUserId(conn, userId);
                
                if (caregiverProfile == null) {
                    response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=profile_not_found");
                    return;
                }
                
                int caregiverId = (Integer) caregiverProfile.get("caregiverId");
                
                if ("update".equals(action)) {
                    handleProfileUpdate(request, response, conn, caregiverId);
                } else if ("upload-image".equals(action)) {
                    handleImageUpload(request, response, conn, caregiverId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=invalid_action");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=" + e.getMessage());
        }
    }
    
    /**
     * Handle profile information update
     */
    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response, 
                                     Connection conn, int caregiverId) throws Exception {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String qualifications = request.getParameter("qualifications");
        String hourlyRateStr = request.getParameter("hourlyRate");
        
        // Validate inputs
        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            hourlyRateStr == null || hourlyRateStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=missing_fields");
            return;
        }
        
        try {
            double hourlyRate = Double.parseDouble(hourlyRateStr);
            
            // Update profile
            boolean success = CaregiverProfileHandler.updateCaregiverProfile(conn, caregiverId, 
                firstName.trim(), lastName.trim(), qualifications != null ? qualifications.trim() : "", hourlyRate);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/caregiver/profile?msg=profile_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=update_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=invalid_hourly_rate");
        }
    }
    
    /**
     * Handle profile image upload
     */
    private void handleImageUpload(HttpServletRequest request, HttpServletResponse response, 
                                   Connection conn, int caregiverId) throws Exception {
        try {
            // Upload image using ImageUploadUtil - process the image and get filename
            String fileName = ImageUploadUtil.processImageUpload(request, "profileImage");
            
            if (fileName == null) {
                response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=no_image_selected");
                return;
            }
            
            // Update caregiver profile with new image path
            // Need to move the file to caregivers directory
            String uploadPath = request.getServletContext().getRealPath("/images/services/");
            String caregiverUploadPath = request.getServletContext().getRealPath("/images/caregivers/");
            
            // Ensure caregiver upload directory exists
            File caregiverDir = new File(caregiverUploadPath);
            if (!caregiverDir.exists()) {
                caregiverDir.mkdirs();
            }
            
            // Move file from services to caregivers directory
            File sourceFile = new File(uploadPath, fileName);
            String caregiverFileName = "caregiver_" + caregiverId + "_" + System.currentTimeMillis() + 
                                      fileName.substring(fileName.lastIndexOf('.'));
            File destFile = new File(caregiverUploadPath, caregiverFileName);
            
            if (sourceFile.exists()) {
                java.nio.file.Files.move(sourceFile.toPath(), destFile.toPath(), 
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Update caregiver profile with new image path
            boolean success = CaregiverProfileHandler.updateProfileImagePath(conn, caregiverId, caregiverFileName);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/caregiver/profile?msg=image_uploaded");
            } else {
                response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=image_update_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/caregiver/profile?error=" + e.getMessage());
        }
    }
}
