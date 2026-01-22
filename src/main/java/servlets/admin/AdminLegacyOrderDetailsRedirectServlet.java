/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Redirect servlet for legacy admin order details JSP URLs to new servlet-based URLs
 */
package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;
import lib.SessionManagement;

// Disabled: Use AdminOrderDetailsServlet instead (/admin/adminOrderDetails)
// @WebServlet("/admin/adminOrderDetails.jsp")
public class AdminLegacyOrderDetailsRedirectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // keep existing auth behaviour: require admin
        if (!SessionManagement.isLoggedIn(req) || !SessionManagement.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login/");
            return;
        }

        String orderId = req.getParameter("orderId");
        String target = req.getContextPath() + "/admin/orders";
        if (orderId != null && !orderId.trim().isEmpty()) {
            try {
                target += "?include=details&orderId=" + URLEncoder.encode(orderId.trim(), "UTF-8");
            } catch (UnsupportedEncodingException e) {
                target += "?include=details&orderId=" + orderId.trim();
            }
        }

        resp.sendRedirect(target);
    }
}
