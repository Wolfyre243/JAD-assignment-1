package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import handlers.AdminDashboardHandler;
import lib.SessionManagement;

@WebServlet("/admin/dashboard/stats")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(req) || !SessionManagement.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login/");
            return;
        }

        try {
            Map<String,Integer> stats = AdminDashboardHandler.getStats();
            req.setAttribute("totalUsers", stats.getOrDefault("totalUsers", 0));
            req.setAttribute("totalOrders", stats.getOrDefault("totalOrders", 0));
            req.setAttribute("totalFeedback", stats.getOrDefault("totalFeedback", 0));
            req.setAttribute("totalProducts", stats.getOrDefault("totalProducts", 0));
        } catch (SQLException e) {
            // on error, fall back to zeros
            req.setAttribute("totalUsers", 0);
            req.setAttribute("totalOrders", 0);
            req.setAttribute("totalFeedback", 0);
            req.setAttribute("totalProducts", 0);
            e.printStackTrace();
        }

        // Compose a full page: header + component + footer
        req.getRequestDispatcher("/WEB-INF/components/common/header.jsp").include(req, resp);
        req.getRequestDispatcher("/WEB-INF/components/admin/adminDashboard.jsp").include(req, resp);
        req.getRequestDispatcher("/WEB-INF/components/common/footer.jsp").include(req, resp);
    }
}