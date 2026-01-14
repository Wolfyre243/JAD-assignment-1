/*
 * Name: GitHub Copilot
 * Date: January 14, 2026
 * Description: Service details servlet to show service information with available caregivers
 */
package servlets.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import models.Product;
import models.Caregiver;
import lib.SessionManagement;

@WebServlet("/services/details")
public class ServiceDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/services");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr.trim());
            
            // Get the product/service details
            Product product = Product.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/services?msg=not_found");
                return;
            }
            
            // Get available caregivers for this service
            java.util.List<Caregiver> availableCaregivers = Caregiver.getCaregiversForService(productId);
            
            // Set session data for the JSP (same as AuthServlet pattern)
            Object userId = request.getSession(false) != null ? request.getSession(false).getAttribute("userId") : null;
            Object roleId = request.getSession(false) != null ? request.getSession(false).getAttribute("roleId") : null;
            
            request.setAttribute("sessUserId", userId);
            request.setAttribute("sessRoleId", roleId);
            request.setAttribute("product", product);
            request.setAttribute("availableCaregivers", availableCaregivers);
            
            // Forward to the JSP
            request.getRequestDispatcher("/services/details/viewDetails.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/services?msg=invalid");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/services?msg=error");
        }
    }
}