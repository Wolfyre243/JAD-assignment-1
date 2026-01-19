/*
 * Name: Karys Goh Yi Xin
 * Date: January 14, 2026
 * Description: Utility class for handling image uploads for services
 */
package lib;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

public class ImageUploadUtil {
    
    // Allowed image file extensions
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif", "webp");
    
    // Maximum file size (5MB)
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;
    
    // Upload directory relative to webapp
    private static final String UPLOAD_DIR = "images/services/";
    
    /**
     * Process image upload and return the filename
     * @param request HTTP request containing the file upload
     * @param partName Name of the file input field
     * @return filename of uploaded image or null if no upload/error
     * @throws ServletException, IOException
     */
    public static String processImageUpload(HttpServletRequest request, String partName) 
            throws ServletException, IOException {
        
        Part filePart = request.getPart(partName);
        
        // Check if file was uploaded
        if (filePart == null || filePart.getSize() == 0) {
            return null; // No file uploaded
        }
        
        // Validate file size
        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new IOException("File size exceeds maximum allowed size of 5MB");
        }
        
        // Get original filename
        String originalFileName = getFileName(filePart);
        if (originalFileName == null || originalFileName.trim().isEmpty()) {
            throw new IOException("Invalid file name");
        }
        
        // Validate file extension
        String fileExtension = getFileExtension(originalFileName);
        if (!isValidImageExtension(fileExtension)) {
            throw new IOException("Invalid file type. Allowed types: " + String.join(", ", ALLOWED_EXTENSIONS));
        }
        
        // Generate unique filename
        String uniqueFileName = generateUniqueFileName(fileExtension);
        
        // Get upload directory path
        String uploadPath = getUploadPath(request);
        
        // Ensure upload directory exists
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save file
        Path targetPath = Paths.get(uploadPath, uniqueFileName);
        Files.copy(filePart.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
        
        return uniqueFileName;
    }
    
    /**
     * Delete an image file from the upload directory
     * @param request HTTP request to get context path
     * @param fileName Name of the file to delete
     * @return true if deleted successfully, false otherwise
     */
    public static boolean deleteImage(HttpServletRequest request, String fileName) {
        if (fileName == null || fileName.equals("default.png")) {
            return false; // Don't delete default image
        }
        
        try {
            String uploadPath = getUploadPath(request);
            Path filePath = Paths.get(uploadPath, fileName);
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get the upload directory path
     */
    private static String getUploadPath(HttpServletRequest request) {
        return request.getServletContext().getRealPath("/") + UPLOAD_DIR;
    }
    
    /**
     * Extract filename from Part object
     */
    private static String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
    
    /**
     * Extract file extension from filename
     */
    private static String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex + 1).toLowerCase();
        }
        return "";
    }
    
    /**
     * Check if file extension is valid for images
     */
    private static boolean isValidImageExtension(String extension) {
        return ALLOWED_EXTENSIONS.contains(extension.toLowerCase());
    }
    
    /**
     * Generate unique filename with timestamp and UUID
     */
    private static String generateUniqueFileName(String extension) {
        return "service_" + System.currentTimeMillis() + "_" + 
               UUID.randomUUID().toString().substring(0, 8) + "." + extension;
    }
    
    /**
     * Get the web-accessible path for an image
     * @param fileName The image filename
     * @return Web path for the image
     */
    public static String getImageWebPath(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return UPLOAD_DIR + "default.png";
        }
        return UPLOAD_DIR + fileName;
    }
}