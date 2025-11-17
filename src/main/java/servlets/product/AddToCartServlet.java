package servlets.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import lib.SessionManagement;
import handlers.CartHandler;

@WebServlet({"/product/addToCart", "/product/addToCart.jsp"})
public class AddToCartServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login");
      return;
    }
    response.sendRedirect(request.getContextPath() + "/products.jsp");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login");
      return;
    }

    String redirectMsg = "added";
    try {
      Integer userId = (Integer) request.getSession().getAttribute("userId");
      int productId = Integer.parseInt(request.getParameter("productId"));
      Integer caregiverId = null;
      Integer clientId = null;
      try { String c = request.getParameter("caregiverId"); if (c != null && !c.trim().isEmpty()) caregiverId = Integer.parseInt(c); } catch (NumberFormatException ignored) {}
      try { String c = request.getParameter("clientId"); if (c != null && !c.trim().isEmpty()) clientId = Integer.parseInt(c); } catch (NumberFormatException ignored) {}
      String specialRequests = request.getParameter("specialRequests");

      if (productId <= 0) {
        redirectMsg = "invalid_product";
      } else {
        boolean ok = CartHandler.addToCart(userId, productId, caregiverId, clientId, specialRequests);
        if (!ok) redirectMsg = "db_error";
      }
    } catch (NumberFormatException e) {
      redirectMsg = "invalid_input";
    } catch (SQLException e) {
      e.printStackTrace();
      redirectMsg = "db_error";
    }

    response.sendRedirect(request.getContextPath() + "/products.jsp?msg=" + redirectMsg);
  }
}
