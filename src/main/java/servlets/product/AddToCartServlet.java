/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Add to cart servlet handling adding products to session-based shopping cart
 */
package servlets.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import lib.SessionManagement;
import lib.CartSessionManager;
import models.Cart;
import db.JDBC;

@WebServlet({"/product/addToCart", "/product/addToCart.jsp"})
public class AddToCartServlet extends HttpServlet {
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

    String redirectMsg = "added";
    try {
      // Parse request parameters
      int productId = Integer.parseInt(request.getParameter("productId"));
      Integer caregiverId = parseIntOrNull(request.getParameter("caregiverId"));
      Integer clientId = parseIntOrNull(request.getParameter("clientId"));
      String specialRequests = request.getParameter("specialRequests");
      String timeslot = request.getParameter("timeslot");

      if (productId <= 0) {
        redirectMsg = "invalid_product";
      } else {
        // Fetch product details from database 
        String serviceName = "";
        double price = 0.0;
        
        try (Connection conn = JDBC.connect();
             PreparedStatement pstmt = conn.prepareStatement(
                 "SELECT name, price FROM product WHERE product_id = ? AND is_active = true")) {
          pstmt.setInt(1, productId);
          try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
              serviceName = rs.getString("name");
              price = rs.getDouble("price");
              
              // Add to SESSION cart (not database!)
              Cart cart = CartSessionManager.getCart(request);
              cart.addItem(productId, serviceName, price, 1, caregiverId, clientId, specialRequests, timeslot);
              CartSessionManager.saveCart(request, cart);
              
              redirectMsg = "added";
            } else {
              redirectMsg = "product_not_found";
            }
          }
        } catch (SQLException e) {
          e.printStackTrace();
          redirectMsg = "db_error";
        }
      }
    } catch (NumberFormatException e) {
      redirectMsg = "invalid_input";
    }

    response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=" + redirectMsg);
  }
  
  /**
   * Helper method to parse Integer or return null
   */
  private Integer parseIntOrNull(String value) {
    if (value == null || value.trim().isEmpty()) return null;
    try {
      return Integer.parseInt(value.trim());
    } catch (NumberFormatException e) {
      return null;
    }
  }
}