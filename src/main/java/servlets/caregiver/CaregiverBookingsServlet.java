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
import models.Booking;
import models.Caregiver;
import models.Client;
import models.User;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Servlet to show bookings assigned to the logged-in caregiver
 */
@WebServlet({"/caregiver/bookings", "/caregiver/bookings/"})
public class CaregiverBookingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Require login and caregiver role
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

            models.Caregiver cg = Caregiver.getCaregiverByUserId(userId);
            if (cg == null) {
                request.setAttribute("error", "No caregiver profile found for current user.");
                request.getRequestDispatcher("/caregiver/bookings/index.jsp").forward(request, response);
                return;
            }

            int caregiverId = cg.getCaregiverId();
            ArrayList<Booking> bookings = Booking.getAllCaregiverBookings(caregiverId);

            // Build view list with contact name/email for each booking
            java.util.List<java.util.Map<String, Object>> bookingViews = new java.util.ArrayList<>();
            try (java.sql.Connection conn = db.JDBC.connect()) {
                for (Booking b : bookings) {
                    java.util.Map<String, Object> view = new java.util.HashMap<>();
                    view.put("booking", b);
                    String contactName = null;
                    String contactEmail = null;
                    // Prefer client details when present
                    int clientId = b.getClientId();
                    if (clientId > 0) {
                        try {
                            Client client = Client.getClientById(clientId);
                            if (client != null) {
                                contactName = (client.getFirstName() != null ? client.getFirstName() : "") + (client.getLastName() != null ? (" " + client.getLastName()) : "");
                                contactEmail = client.getEmail();
                            }
                        } catch (Exception e) { /* ignore */ }
                    }
                    // Fallback: derive from order's user_id
                    if ((contactEmail == null || contactEmail.isEmpty())) {
                        try {
                            java.sql.PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM \"order\" WHERE order_id = ?");
                            ps.setInt(1, b.getOrderId());
                            java.sql.ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                int orderUserId = rs.getInt("user_id");
                                try {
                                    User u = User.getUserById(orderUserId);
                                    if (u != null) {
                                        contactEmail = u.getEmail();
                                    }
                                } catch (Exception ex) { /* ignore */ }
                            }
                            rs.close();
                            ps.close();
                        } catch (Exception e) { /* ignore */ }
                    }

                    view.put("contactName", (contactName != null && !contactName.trim().isEmpty()) ? contactName.trim() : null);
                    view.put("contactEmail", contactEmail);
                    bookingViews.add(view);
                }
            }

            request.setAttribute("bookingViews", bookingViews);
            request.getRequestDispatcher("/caregiver/bookings/index.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading caregiver bookings: " + e.getMessage());
            request.getRequestDispatcher("/caregiver/bookings/index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
