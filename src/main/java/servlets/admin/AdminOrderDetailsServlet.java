/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Admin order details servlet displaying specific order information and bookings
 */
package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lib.SessionManagement;

/**
 * Servlet wrapper for /admin/adminOrderDetails.
 * Performs auth checks and forwards to the protected JSP under WEB-INF.
 */
@WebServlet("/admin/adminOrderDetails")
public class AdminOrderDetailsServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // Require logged in admin
    if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }

  // Include the common header, the component, then the footer so the servlet can serve a full page
  request.getRequestDispatcher("/WEB-INF/components/common/header.jsp").include(request, response);
  request.getRequestDispatcher("/WEB-INF/components/admin/adminOrderDetails.jsp").include(request, response);
  request.getRequestDispatcher("/WEB-INF/components/common/footer.jsp").include(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // For now, handle POST the same as GET. If later you need to handle form submission,
    // implement here and forward or redirect accordingly.
    doGet(request, response);
  }
}
