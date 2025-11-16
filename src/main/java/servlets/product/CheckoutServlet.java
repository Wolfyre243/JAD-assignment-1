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

@WebServlet({"/product/checkout", "/product/checkout.jsp"})
public class CheckoutServlet extends HttpServlet {
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

    String cartIdStr = request.getParameter("cartId");
    if (cartIdStr == null || cartIdStr.trim().isEmpty()) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid_cart");
      return;
    }

    try {
      int cartId = Integer.parseInt(cartIdStr.trim());
      Integer userId = (Integer) request.getSession().getAttribute("userId");
      int orderId = CartHandler.checkoutCart(userId, cartId);
      response.sendRedirect(request.getContextPath() + "/product/orderConfirmation.jsp?orderId=" + orderId);
    } catch (NumberFormatException e) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid_cart");
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=db_error");
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=checkout_error");
    }
  }
}
