/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Remove from cart servlet handling item removal from session-based cart
 */
package servlets.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lib.SessionManagement;
import lib.CartSessionManager;
import models.Cart;

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

    // Changed from cartItemId to itemIndex
    String itemIndexStr = request.getParameter("itemIndex");
    String redirectMsg = "removed";
    
    if (itemIndexStr == null || itemIndexStr.trim().isEmpty()) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid");
      return;
    }

    try {
      int itemIndex = Integer.parseInt(itemIndexStr.trim());
      
      // Get cart from session
      Cart cart = CartSessionManager.getCart(request);
      
      // Remove item by index
      if (cart.removeItemByIndex(itemIndex)) {
        CartSessionManager.saveCart(request, cart);
        redirectMsg = "removed";
      } else {
        redirectMsg = "not_found";
      }
    } catch (NumberFormatException e) {
      redirectMsg = "invalid";
    } catch (Exception e) {
      e.printStackTrace();
      redirectMsg = "error";
    }

    response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=" + redirectMsg);
  }
}