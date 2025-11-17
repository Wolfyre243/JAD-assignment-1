package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import handlers.AdminFeedbackHandler;
import lib.SessionManagement;

@WebServlet("/admin/feedback/delete")
public class AdminFeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String feedbackIdStr = request.getParameter("feedbackId");
        if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/feedback?msg=invalid");
            return;
        }

        int feedbackId;
        try {
            feedbackId = Integer.parseInt(feedbackIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/feedback?msg=invalid");
            return;
        }

        try {
            boolean ok = AdminFeedbackHandler.deleteFeedback(feedbackId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/feedback?msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/feedback?msg=not_found");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/feedback?msg=db_error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Do not allow GET for destructive action; redirect to feedback page
        resp.sendRedirect(req.getContextPath() + "/admin/feedback");
    }
}
