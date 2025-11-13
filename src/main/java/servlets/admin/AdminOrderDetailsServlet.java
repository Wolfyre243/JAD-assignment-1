package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lib.SessionManagement;

/**
 * Servlet wrapper for /admin/adminOrderDetails.jsp.
 * Performs auth checks and forwards to the protected JSP under WEB-INF.
 */
@WebServlet({"/admin/adminOrderDetails", "/admin/adminOrderDetails.jsp"})
public class AdminOrderDetailsServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // Require logged in admin
    if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }

    // Forward to the protected component JSP. Any query params (e.g., orderId) are preserved
    // and can be read by the included JSP via request.getParameter or request.getAttribute.
    request.getRequestDispatcher("/WEB-INF/components/admin/adminOrderDetails.jsp").forward(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // For now, handle POST the same as GET. If later you need to handle form submission,
    // implement here and forward or redirect accordingly.
    doGet(request, response);
  }
}
