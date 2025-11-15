package servlets.admin;

import db.JDBC;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.sql.*;

@WebServlet("/admin/dashboard/stats")
public class AdminDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws jakarta.servlet.ServletException, java.io.IOException {

        // 1. Check if admin is logged in
        HttpSession session = req.getSession();
        if (session.getAttribute("admin") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        // 2. Get numbers from database
        int totalUsers = countFromTable("user");
        int totalOrders = countFromTable("order");
        int totalFeedback = countFromTable("feedback");
        int totalProducts = countFromTable("product");

        // 3. Send numbers to JSP
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalFeedback", totalFeedback);
        req.setAttribute("totalProducts", totalProducts);

          // 4. Show the dashboard component (used by AJAX or direct stats view)
          // Compose a full page: header + component + footer
          req.getRequestDispatcher("/WEB-INF/components/common/header.jsp").include(req, resp);
          req.getRequestDispatcher("/WEB-INF/components/admin/adminDashboard.jsp").include(req, resp);
          req.getRequestDispatcher("/WEB-INF/components/common/footer.jsp").include(req, resp);
    }

    private int countFromTable(String table) {
        try (Connection c = JDBC.connect();
             PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM \"" + table + "\"");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }
}