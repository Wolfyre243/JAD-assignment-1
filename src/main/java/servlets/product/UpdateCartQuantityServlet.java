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

@WebServlet({"/product/updateCartQuantity", "/product/updateCartQuantity.jsp"})
public class UpdateCartQuantityServlet extends HttpServlet {
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
    String quantityStr = request.getParameter("quantity");
    String redirectMsg = "updated";

    if (cartItemIdStr == null || quantityStr == null) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid");
      return;
    }

    try {
      int cartItemId = Integer.parseInt(cartItemIdStr);
      int quantity = Integer.parseInt(quantityStr);
      if (quantity < 1 || quantity > 99 || cartItemId <= 0) {
        redirectMsg = "invalid_quantity";
      } else {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        boolean ok = CartHandler.updateCartItemQuantity(userId, cartItemId, quantity);
        if (!ok) redirectMsg = "not_found";
      }
    } catch (NumberFormatException e) {
      redirectMsg = "invalid";
    } catch (SQLException e) {
      e.printStackTrace();
      redirectMsg = "db_error";
    }

    response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=" + redirectMsg);
  }
}
