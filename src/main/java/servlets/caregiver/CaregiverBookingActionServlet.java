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

import java.io.IOException;

/**
 * Handle caregiver actions on bookings: checkin/checkout
 */
@WebServlet({"/caregiver/bookings/action"})
public class CaregiverBookingActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isCaregiver(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        try {
            Integer userId = SessionManagement.getUserId(request);
            models.Caregiver cg = Caregiver.getCaregiverByUserId(userId);
            if (cg == null) {
                response.sendRedirect(request.getContextPath() + "/caregiver/bookings/?error=no_profile");
                return;
            }

            String action = request.getParameter("action");
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));

            Booking booking = Booking.getBookingById(bookingId);
            if (booking == null || booking.getCaregiverId() != cg.getCaregiverId()) {
                response.sendRedirect(request.getContextPath() + "/caregiver/bookings/?error=not_owner");
                return;
            }

            boolean ok = false;
            if ("checkin".equals(action)) {
                ok = Booking.updateCheckedIn(bookingId, true);
            } else if ("checkout".equals(action)) {
                // when checkout, mark checked_out true and optionally mark checked_in true if not already
                ok = Booking.updateCheckedOut(bookingId, true);
                if (ok && !booking.isCheckedIn()) Booking.updateCheckedIn(bookingId, true);
            } else {
                // Unknown or removed actions (undo) are not supported
                ok = false;
            }

            String redirect = request.getContextPath() + "/caregiver/bookings/";
            if (!ok) redirect += "?error=update_failed";
            response.sendRedirect(redirect);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/caregiver/bookings/?error=exception");
        }
    }
}
