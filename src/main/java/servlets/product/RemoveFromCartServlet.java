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

@WebServlet({"/product/removeFromCart", "/product/removeFromCart.jsp"})
public class RemoveFromCartServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login");
      return;
    }
    response.sendRedirect(request.getContextPath() + "/product/viewCart");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login");
      return;
    }

    String cartItemIdStr = request.getParameter("cartItemId");
    String redirectMsg = "removed";
    if (cartItemIdStr == null || cartItemIdStr.trim().isEmpty()) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid");
      return;
    }

    try {
      int cartItemId = Integer.parseInt(cartItemIdStr.trim());
      Integer userId = (Integer) request.getSession().getAttribute("userId");
      boolean ok = CartHandler.removeCartItem(userId, cartItemId);
      if (!ok) redirectMsg = "not_found";
    } catch (NumberFormatException e) {
      redirectMsg = "invalid";
    } catch (SQLException e) {
      e.printStackTrace();
      redirectMsg = "db_error";
    }

    response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=" + redirectMsg);
  }
}
