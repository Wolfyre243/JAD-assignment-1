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

    // Get cart from SESSION 
    Cart cart = CartSessionManager.getCart(request);
    
    // Check if cart is empty
    if (cart.isEmpty()) {
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=empty_cart");
      return;
    }

    Integer userId = (Integer) request.getSession().getAttribute("userId");
    
    try (Connection conn = JDBC.connect()) {
      conn.setAutoCommit(false);
      
      int cartId = 0;
      int orderId = 0;
      
      try {
        // 1. Create cart record in database with checked_out = TRUE
        String insertCartSql = "INSERT INTO cart (user_id, checked_out, created_at, updated_at) " +
                              "VALUES (?, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING cart_id";
        try (PreparedStatement pstmt = conn.prepareStatement(insertCartSql)) {
          pstmt.setInt(1, userId);
          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()) throw new SQLException("Failed to create cart");
            cartId = rs.getInt("cart_id");
          }
        }
        
        // 2. Insert all cart items from SESSION into database
        String insertItemSql = "INSERT INTO cart_item (cart_id, product_id, caregiver_id, client_id, " +
                              "special_requests, created_at, updated_at) " +
                              "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertItemSql)) {
          for (Cart.CartItem item : cart.getItems()) {
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, item.getServiceId());
            pstmt.setObject(3, item.getCaregiverId());
            pstmt.setObject(4, item.getClientId());
            pstmt.setString(5, item.getSpecialRequests());
            pstmt.addBatch();
          }
          pstmt.executeBatch();
        }
        
        // 3. Create order record
        String insertOrderSql = "INSERT INTO orders (user_id, cart_id, total_amount, order_status, created_at, updated_at) " +
                               "VALUES (?, ?, ?, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id";
        try (PreparedStatement pstmt = conn.prepareStatement(insertOrderSql)) {
          pstmt.setInt(1, userId);
          pstmt.setInt(2, cartId);
          pstmt.setDouble(3, cart.getTotal());
          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()) throw new SQLException("Failed to create order");
            orderId = rs.getInt("order_id");
          }
        }
        
        // 4. Commit transaction
        conn.commit();
        
        // 5. Clear cart from session (very important!)
        CartSessionManager.clearCart(request);
        
        // 6. Redirect to order confirmation
        response.sendRedirect(request.getContextPath() + "/product/orderConfirmation.jsp?orderId=" + orderId);
        
      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
      
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=db_error");
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=checkout_error");
    }
  }
}