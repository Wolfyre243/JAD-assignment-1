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
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/caregiver/setServiceTimeslots")
public class SetServiceTimeslotsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }
        Integer userId = (Integer) session.getAttribute("userId");
        Integer userRoleId = (Integer) session.getAttribute("userRoleId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }
        // Only caregivers (role id 5) may access this servlet
        if (userRoleId == null || userRoleId.intValue() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only caregivers can manage availability");
            return;
        }
        int caregiverId = -1;
        try {
            models.Caregiver c = models.Caregiver.getCaregiverByUserId(userId);
            if (c == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "User is not a caregiver");
                return;
            }
            caregiverId = c.getCaregiverId();
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) action = "create";

        if ("delete".equals(action)) {
            String availIdStr = request.getParameter("availabilityId");
            if (availIdStr == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing availability id"); return; }
            int availId = Integer.parseInt(availIdStr);
            try {
                boolean ok = models.CaregiverAvailability.deleteById(availId, caregiverId);
                if (!ok) response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unable to delete");
                else response.sendRedirect(request.getContextPath() + "/caregiver/setServiceTimeslots.jsp?success=1");
                return;
            } catch (SQLException e) { throw new ServletException(e); }
        }

        // create or update
        String serviceIdStr = request.getParameter("serviceId");
        String dateStr = request.getParameter("availabilityDate");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        if (serviceIdStr == null || dateStr == null || startTimeStr == null || endTimeStr == null ||
            serviceIdStr.isEmpty() || dateStr.isEmpty() || startTimeStr.isEmpty() || endTimeStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }
        int serviceId = Integer.parseInt(serviceIdStr);
        // Verify the caregiver is actually assigned to this service
        try {
            java.util.ArrayList<models.Product> assigned = models.CaregiverService.getAssignedServices(caregiverId);
            boolean ok = false;
            for (models.Product p : assigned) {
                if (p.getProductId() == serviceId) { ok = true; break; }
            }
            if (!ok) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not assigned to this service");
                return;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
        Date availabilityDate = Date.valueOf(dateStr);
        Time startTime = Time.valueOf(startTimeStr + ":00");
        Time endTime = Time.valueOf(endTimeStr + ":00");
        if (!endTime.after(startTime)) {
            // Redirect back to the form with an error message and preserve submitted values
            String redirect = request.getContextPath() + "/caregiver/setServiceTimeslots.jsp?error=end_before_start";
            try {
                redirect += "&serviceId=" + java.net.URLEncoder.encode(String.valueOf(serviceId), "UTF-8");
                redirect += "&availabilityDate=" + java.net.URLEncoder.encode(dateStr, "UTF-8");
                redirect += "&startTime=" + java.net.URLEncoder.encode(startTimeStr, "UTF-8");
                redirect += "&endTime=" + java.net.URLEncoder.encode(endTimeStr, "UTF-8");
                if (request.getParameter("action") != null) {
                    redirect += "&action=" + java.net.URLEncoder.encode(request.getParameter("action"), "UTF-8");
                }
            } catch (java.io.UnsupportedEncodingException e) {
                // fallback to simple redirect without encoding
            }
            response.sendRedirect(redirect);
            return;
        }
        if ("update".equals(action)) {
            String availIdStr = request.getParameter("availabilityId");
            if (availIdStr == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing availability id"); return; }
            int availId = Integer.parseInt(availIdStr);
            try {
                boolean updated = models.CaregiverAvailability.updateAvailability(availId, caregiverId, availabilityDate, startTime, endTime);
                if (!updated) response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unable to update");
                else response.sendRedirect(request.getContextPath() + "/caregiver/setServiceTimeslots.jsp?success=1");
                return;
            } catch (SQLException e) { throw new ServletException(e); }
        }

        // create
        try (Connection conn = db.JDBC.connect()) {
            String sql = "INSERT INTO caregiver_availability (caregiver_id, product_id, availability_date, start_time, end_time) VALUES (?, ?, ?, ?, ?) ON CONFLICT (caregiver_id, product_id, availability_date, start_time, end_time) DO NOTHING";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, caregiverId);
                ps.setInt(2, serviceId);
                ps.setDate(3, availabilityDate);
                ps.setTime(4, startTime);
                ps.setTime(5, endTime);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
        response.sendRedirect(request.getContextPath() + "/caregiver/setServiceTimeslots.jsp?success=1");
    }
}
