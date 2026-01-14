/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Admin service/product management servlet handling CRUD operations
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
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import handlers.AdminServiceHandler;
import lib.SessionManagement;
import lib.ImageUploadUtil;

@WebServlet("/admin/service")
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024, // 5MB
    maxRequestSize = 10 * 1024 * 1024, // 10MB
    fileSizeThreshold = 1024 * 1024 // 1MB
)
public class AdminServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        // If no action parameter is present, delegate to the AdminPanel listing which
        // prepares `services`, `categories` and handles include=add|edit views.
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String include = request.getParameter("include");
            try {
                String target = request.getContextPath() + "/admin/services";
                if (include != null && !include.trim().isEmpty()) {
                    target += "?include=" + URLEncoder.encode(include, "UTF-8");
                }
                response.sendRedirect(target);
            } catch (UnsupportedEncodingException e) {
                response.sendRedirect(request.getContextPath() + "/admin/services");
            }
            return;
        }

        // Handle delete action
        if ("delete".equals(action)) {
            String productIdStr = request.getParameter("productId");
            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdStr.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
                return;
            }

            try {
                boolean ok = AdminServiceHandler.deleteService(productId);
                if (!ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/services?msg=deleted");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
            }
            return;
        }

        // Only support activate/deactivate as GET actions
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty() || !("activate".equals(action) || "deactivate".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        boolean newStatus = "activate".equals(action);
        try {
            boolean ok = AdminServiceHandler.setServiceActive(productId, newStatus);
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=" + action + "d");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle add/edit via POST
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            handleAdd(request, response);
            return;
        } else if ("edit".equals(action)) {
            handleEdit(request, response);
            return;
        }
        // Other POST actions can be implemented (edit)
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        String categoryIdStr = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String isActiveStr = request.getParameter("isActive");

        if (name == null || name.trim().isEmpty() || categoryIdStr == null || priceStr == null || isActiveStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/service?msg=invalid&redirect=add");
            return;
        }

        int categoryId;
        double price;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
            price = Double.parseDouble(priceStr);
            if (price < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/service?msg=invalid&redirect=add");
            return;
        }

        boolean isActive = Boolean.parseBoolean(isActiveStr);

        // Handle image upload
        String imagePath = null;
        try {
            imagePath = ImageUploadUtil.processImageUpload(request, "imageFile");
        } catch (ServletException | IOException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=upload_error&details=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        try {
            boolean ok = AdminServiceHandler.addService(categoryId, name.trim(), 
                description != null ? description.trim() : null, price, isActive, imagePath);
            if (!ok) {
                // Clean up uploaded image if database insert failed
                if (imagePath != null) {
                    ImageUploadUtil.deleteImage(request, imagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=added");
            }
        } catch (SQLException e) {
            // Clean up uploaded image if database error
            if (imagePath != null) {
                ImageUploadUtil.deleteImage(request, imagePath);
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String productIdStr = request.getParameter("productId");
        String name = request.getParameter("name");
        String categoryIdStr = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String isActiveStr = request.getParameter("isActive");
        String keepCurrentImage = request.getParameter("keepCurrentImage");

        if (productIdStr == null || productIdStr.trim().isEmpty() || name == null || name.trim().isEmpty() || 
            categoryIdStr == null || priceStr == null || isActiveStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        int productId;
        int categoryId;
        double price;
        try {
            productId = Integer.parseInt(productIdStr);
            categoryId = Integer.parseInt(categoryIdStr);
            price = Double.parseDouble(priceStr);
            if (price < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        boolean isActive = Boolean.parseBoolean(isActiveStr);

        // Handle image upload
        String newImagePath = null;
        String oldImagePath = null;
        
        try {
            // Get current service to find old image
            java.util.Map<String, Object> currentService = AdminServiceHandler.getServiceById(productId);
            if (currentService != null) {
                oldImagePath = (String) currentService.get("imagePath");
            }
            
            // Check if user wants to keep current image or upload new one
            if ("true".equals(keepCurrentImage)) {
                newImagePath = oldImagePath; // Keep existing image
            } else {
                // Try to upload new image
                newImagePath = ImageUploadUtil.processImageUpload(request, "imageFile");
                if (newImagePath == null) {
                    newImagePath = oldImagePath; // No new image uploaded, keep old one
                }
            }
        } catch (ServletException | IOException | SQLException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=upload_error&details=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        try {
            boolean ok = AdminServiceHandler.updateService(productId, categoryId, name.trim(), 
                description != null ? description.trim() : null, price, isActive, newImagePath);
            if (!ok) {
                // Clean up new uploaded image if database update failed
                if (newImagePath != null && !newImagePath.equals(oldImagePath)) {
                    ImageUploadUtil.deleteImage(request, newImagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
            } else {
                // Delete old image if a new one was successfully uploaded and saved
                if (newImagePath != null && !newImagePath.equals(oldImagePath) && oldImagePath != null) {
                    ImageUploadUtil.deleteImage(request, oldImagePath);
                }
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=updated");
            }
        } catch (SQLException e) {
            // Clean up new uploaded image if database error
            if (newImagePath != null && !newImagePath.equals(oldImagePath)) {
                ImageUploadUtil.deleteImage(request, newImagePath);
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }
}
