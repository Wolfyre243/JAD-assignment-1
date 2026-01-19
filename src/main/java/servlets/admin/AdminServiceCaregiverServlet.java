/*
 * Name: Karys Goh Yi Xin
 * Date: January 14, 2026
 * Description: Admin servlet to manage service-caregiver assignments
 */
package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import handlers.AdminServiceHandler;
import handlers.AdminCaregiverHandler;
import lib.SessionManagement;

@WebServlet({"/admin/service-caregivers", "/admin/service-caregiver"})
public class AdminServiceCaregiverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr.trim());
            
            // Get service details
            java.util.Map<String, Object> service = AdminServiceHandler.getServiceById(productId);
            if (service == null) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
                return;
            }
            
            // Get caregivers assigned to this service
            java.util.List<java.util.Map<String, Object>> assignedCaregivers = AdminCaregiverHandler.getCaregiversForService(productId);
            
            // Get all active caregivers not assigned to this service
            java.util.List<java.util.Map<String, Object>> allCaregivers = AdminCaregiverHandler.listCaregivers();
            java.util.List<java.util.Map<String, Object>> availableCaregivers = new java.util.ArrayList<>();
            
            // Filter out already assigned caregivers and inactive ones
            for (java.util.Map<String, Object> caregiver : allCaregivers) {
                boolean isActive = (Boolean) caregiver.get("isActive");
                if (!isActive) continue;
                
                int caregiverId = (Integer) caregiver.get("caregiverId");
                boolean alreadyAssigned = false;
                
                for (java.util.Map<String, Object> assigned : assignedCaregivers) {
                    if (caregiverId == (Integer) assigned.get("caregiverId")) {
                        alreadyAssigned = true;
                        break;
                    }
                }
                
                if (!alreadyAssigned) {
                    availableCaregivers.add(caregiver);
                }
            }
            
            request.setAttribute("service", service);
            request.setAttribute("assignedCaregivers", assignedCaregivers);
            request.setAttribute("availableCaregivers", availableCaregivers);
            
            request.getRequestDispatcher("/WEB-INF/components/admin/adminServiceCaregivers.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");
        String caregiverIdStr = request.getParameter("caregiverId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr.trim());
            
            if ("assign".equals(action)) {
                handleAssign(request, response, productId, caregiverIdStr);
            } else if ("remove".equals(action)) {
                handleRemove(request, response, productId, caregiverIdStr);
            } else if ("toggle".equals(action)) {
                handleToggle(request, response, productId, caregiverIdStr);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=invalid");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
        }
    }

    private void handleAssign(HttpServletRequest request, HttpServletResponse response, int productId, String caregiverIdStr) throws IOException {
        if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=invalid");
            return;
        }

        try {
            int caregiverId = Integer.parseInt(caregiverIdStr.trim());
            String isAvailableStr = request.getParameter("isAvailable");
            boolean isAvailable = Boolean.parseBoolean(isAvailableStr);

            boolean success = AdminCaregiverHandler.assignCaregiverToService(productId, caregiverId, isAvailable);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=assigned");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=assign_error");
            }
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=db_error");
        }
    }

    private void handleRemove(HttpServletRequest request, HttpServletResponse response, int productId, String caregiverIdStr) throws IOException {
        if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=invalid");
            return;
        }

        try {
            int caregiverId = Integer.parseInt(caregiverIdStr.trim());
            boolean success = AdminCaregiverHandler.removeCaregiverFromService(productId, caregiverId);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=removed");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=remove_error");
            }
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=db_error");
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response, int productId, String caregiverIdStr) throws IOException {
        if (caregiverIdStr == null || caregiverIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=invalid");
            return;
        }

        try {
            int caregiverId = Integer.parseInt(caregiverIdStr.trim());
            String isAvailableStr = request.getParameter("isAvailable");
            boolean isAvailable = Boolean.parseBoolean(isAvailableStr);

            boolean success = AdminCaregiverHandler.assignCaregiverToService(productId, caregiverId, isAvailable);
            
            if (success) {
                String status = isAvailable ? "available" : "unavailable";
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=" + status);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=toggle_error");
            }
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/service-caregivers?productId=" + productId + "&msg=db_error");
        }
    }
}