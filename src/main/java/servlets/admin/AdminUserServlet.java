package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import db.JDBC;
import lib.SessionManagement;

@WebServlet("/admin/user")
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        if (userIdStr == null || userIdStr.trim().isEmpty() || !("activate".equals(action) || "deactivate".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/admin/user?msg=invalid&redirect=users");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(userIdStr.trim());
            Integer sessUserId = SessionManagement.getUserId(request);
            if (sessUserId != null && sessUserId == targetUserId && "deactivate".equals(action)) {
                response.sendRedirect(request.getContextPath() + "/admin/user?msg=self_action_denied&redirect=users");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/user?msg=invalid&redirect=users");
            return;
        }

        boolean newStatus = "activate".equals(action);

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = "UPDATE \"user\" SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, newStatus);
            pstmt.setInt(2, targetUserId);

            int rows = pstmt.executeUpdate();
            if (rows == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/users?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users?msg=" + action + "d");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/users?msg=db_error");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
