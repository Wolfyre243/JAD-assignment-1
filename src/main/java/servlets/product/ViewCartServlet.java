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

/**
 * Servlet to display the shopping cart
 */
@WebServlet({"/product/viewCart", "/product/viewCart.jsp"})
public class ViewCartServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request)) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }
    
    // Get cart from session
    Cart cart = CartSessionManager.getCart(request);
    
    // Set cart data as request attributes for JSP
    request.setAttribute("cart", cart);
    request.setAttribute("items", cart.getItems());
    request.setAttribute("total", cart.getTotal());
    request.setAttribute("itemCount", cart.getItemCount());
    
    request.getRequestDispatcher("/WEB-INF/components/product/viewCart.jsp").forward(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doGet(request, response);
  }
}