/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
*/

package servlets.caregiver;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lib.SessionManagement;
import models.Caregiver;
import handlers.AdminOrderHandler;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Servlet for caregivers to view order details for orders that include bookings assigned to them.
 */
@WebServlet({"/caregiver/orderView", "/caregiver/orderView/"})
public class CaregiverOrderViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isCaregiver(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        Integer userId = SessionManagement.getUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        try {
            models.Caregiver cg = Caregiver.getCaregiverByUserId(userId);
            if (cg == null) {
                request.setAttribute("error", "No caregiver profile found for current user.");
                request.getRequestDispatcher("/caregiver/bookings/index.jsp").forward(request, response);
                return;
            }

            String orderIdStr = request.getParameter("orderId");
            if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/caregiver/bookings?error=invalid_order");
                return;
            }

            int orderId = Integer.parseInt(orderIdStr);
            int caregiverId = cg.getCaregiverId();

            // Verify that this caregiver has at least one booking in the order
            boolean ownsBooking = false;
            try (Connection conn = db.JDBC.connect();
                 PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM booking WHERE order_id = ? AND caregiver_id = ? LIMIT 1")) {
                ps.setInt(1, orderId);
                ps.setInt(2, caregiverId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) ownsBooking = true;
                }
            }

            if (!ownsBooking) {
                response.sendRedirect(request.getContextPath() + "/caregiver/bookings?error=access_denied");
                return;
            }

            // Load order details (admin-style) and forward to shared order details JSP
            java.util.Map<String, Object> orderDetails = AdminOrderHandler.getOrderDetails(orderId);
            if (orderDetails == null) {
                response.sendRedirect(request.getContextPath() + "/caregiver/bookings?error=not_found");
                return;
            }

            request.setAttribute("orderDetails", orderDetails);
            request.getRequestDispatcher("/WEB-INF/components/user/orderDetails.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load order: " + e.getMessage());
            request.getRequestDispatcher("/caregiver/bookings/index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
