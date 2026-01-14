/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Checkout servlet converting session cart to database order and bookings
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

@WebServlet({"/product/checkout", "/product/checkout.jsp"})
public class CheckoutServlet extends HttpServlet {
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
      
      int orderId = 0;
      
      try {
        // 1. Create order record with GST calculations
        double subtotal = cart.getSubtotal();
        double gstAmount = cart.getGSTAmount();
        double totalAmount = cart.getTotalWithGST();
        
        // Try to insert with GST columns first, fallback to basic insert if columns don't exist
        try {
          String insertOrderSql = "INSERT INTO \"order\" (user_id, subtotal, gst_amount, total_amount, created_at, updated_at) " +
                                 "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id";
          try (PreparedStatement pstmt = conn.prepareStatement(insertOrderSql)) {
            pstmt.setInt(1, userId);
            pstmt.setDouble(2, subtotal);
            pstmt.setDouble(3, gstAmount);
            pstmt.setDouble(4, totalAmount);
            try (ResultSet rs = pstmt.executeQuery()) {
              if (!rs.next()) throw new SQLException("Failed to create order");
              orderId = rs.getInt("order_id");
            }
          }
        } catch (SQLException e) {
          // Fallback: GST columns don't exist yet, use basic insert
          if (e.getMessage().contains("column") && e.getMessage().contains("does not exist")) {
            String fallbackSql = "INSERT INTO \"order\" (user_id, created_at, updated_at) " +
                                "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING order_id";
            try (PreparedStatement pstmt = conn.prepareStatement(fallbackSql)) {
              pstmt.setInt(1, userId);
              try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) throw new SQLException("Failed to create order");
                orderId = rs.getInt("order_id");
              }
            }
          } else {
            throw e; // Re-throw if it's not a missing column error
          }
        }
        
        // 2. Insert bookings from cart items
        String insertBookingSql = "INSERT INTO booking (order_id, product_id, caregiver_id, client_id, " +
                                 "special_requests, created_at, updated_at) " +
                                 "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertBookingSql)) {
          for (Cart.CartItem item : cart.getItems()) {
            pstmt.setInt(1, orderId);
            pstmt.setInt(2, item.getServiceId());
            pstmt.setObject(3, item.getCaregiverId());
            pstmt.setObject(4, item.getClientId());
            pstmt.setString(5, item.getSpecialRequests());
            pstmt.addBatch();
          }
          pstmt.executeBatch();
        }
        
        // 3. Commit transaction
        conn.commit();
        
        // 4. Clear cart from session 
        CartSessionManager.clearCart(request);
        
        // 5. Redirect to order confirmation
        response.sendRedirect(request.getContextPath() + "/product/orderConfirmation?orderId=" + orderId);
        
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