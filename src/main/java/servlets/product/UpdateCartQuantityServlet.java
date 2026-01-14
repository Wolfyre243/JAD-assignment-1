/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Update cart quantity servlet handling quantity changes in session-based cart
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

@WebServlet({"/product/updateCartQuantity", "/product/updateCartQuantity.jsp"})
public class UpdateCartQuantityServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }
    response.sendRedirect(request.getContextPath() + "/product/viewCart");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }

    // Changed from cartItemId to itemIndex (position in cart array)
    String itemIndexStr = request.getParameter("itemIndex");
    String quantityStr = request.getParameter("quantity");
    String redirectMsg = "updated";

    if (itemIndexStr == null || quantityStr == null) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=invalid");
      return;
    }

    try {
      int itemIndex = Integer.parseInt(itemIndexStr);
      int quantity = Integer.parseInt(quantityStr);
      
      if (quantity < 1 || quantity > 99 || itemIndex < 0) {
        redirectMsg = "invalid_quantity";
      } else {
        // Get cart from session
        Cart cart = CartSessionManager.getCart(request);
        
        // Update quantity in memory
        if (itemIndex < cart.getItems().size()) {
          cart.getItems().get(itemIndex).setQuantity(quantity);
          CartSessionManager.saveCart(request, cart);
          redirectMsg = "updated";
        } else {
          redirectMsg = "not_found";
        }
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