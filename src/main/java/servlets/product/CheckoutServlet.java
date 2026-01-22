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
        // Detect whether the `booking_end_time` column exists and pick the appropriate INSERT
        boolean hasBookingEndColumn = false;
        try (ResultSet cols = conn.getMetaData().getColumns(null, null, "booking", "booking_end_time")) {
          if (cols.next()) hasBookingEndColumn = true;
        } catch (SQLException ex) {
          // If metadata check fails, conservatively assume column does not exist
          hasBookingEndColumn = false;
        }

        if (hasBookingEndColumn) {
          String insertBookingSqlWithEnd = "INSERT INTO booking (order_id, product_id, caregiver_id, client_id, " +
                                 "special_requests, booking_timeslot, booking_end_time, created_at, updated_at) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
          try (PreparedStatement pstmt = conn.prepareStatement(insertBookingSqlWithEnd)) {
            for (Cart.CartItem item : cart.getItems()) {
              pstmt.setInt(1, orderId);
              pstmt.setInt(2, item.getServiceId());
              pstmt.setObject(3, item.getCaregiverId());
              pstmt.setObject(4, item.getClientId());
              pstmt.setString(5, item.getSpecialRequests());
              // booking_timeslot (start)
              String timeslot = item.getTimeslot();
              if (timeslot != null && !timeslot.isEmpty()) {
                try {
                  String sqlDateTimeStr = timeslot.replace("T", " ") + ":00";
                  java.sql.Timestamp sqlTimestamp = java.sql.Timestamp.valueOf(sqlDateTimeStr);
                  pstmt.setTimestamp(6, sqlTimestamp);
                } catch (IllegalArgumentException e) {
                  pstmt.setNull(6, java.sql.Types.TIMESTAMP);
                }
              } else {
                pstmt.setNull(6, java.sql.Types.TIMESTAMP);
              }

              // booking_end_time
              String timeslotEnd = null;
              try { timeslotEnd = item.getTimeslotEnd(); } catch (NoSuchMethodError ex) { timeslotEnd = null; }
              if (timeslotEnd != null && !timeslotEnd.isEmpty()) {
                try {
                  String sqlDateTimeEndStr = timeslotEnd.replace("T", " ") + ":00";
                  java.sql.Timestamp sqlEndTimestamp = java.sql.Timestamp.valueOf(sqlDateTimeEndStr);
                  pstmt.setTimestamp(7, sqlEndTimestamp);
                } catch (IllegalArgumentException e) {
                  pstmt.setNull(7, java.sql.Types.TIMESTAMP);
                }
              } else {
                pstmt.setNull(7, java.sql.Types.TIMESTAMP);
              }

              pstmt.addBatch();
            }
            pstmt.executeBatch();
          }
        } else {
          String insertBookingSql = "INSERT INTO booking (order_id, product_id, caregiver_id, client_id, " +
                               "special_requests, booking_timeslot, created_at, updated_at) " +
                               "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
          try (PreparedStatement pstmt = conn.prepareStatement(insertBookingSql)) {
            for (Cart.CartItem item : cart.getItems()) {
              pstmt.setInt(1, orderId);
              pstmt.setInt(2, item.getServiceId());
              pstmt.setObject(3, item.getCaregiverId());
              pstmt.setObject(4, item.getClientId());
              pstmt.setString(5, item.getSpecialRequests());
              String timeslot = item.getTimeslot();
              if (timeslot != null && !timeslot.isEmpty()) {
                try {
                  String sqlDateTimeStr = timeslot.replace("T", " ") + ":00";
                  java.sql.Timestamp sqlTimestamp = java.sql.Timestamp.valueOf(sqlDateTimeStr);
                  pstmt.setTimestamp(6, sqlTimestamp);
                } catch (IllegalArgumentException ex2) {
                  pstmt.setNull(6, java.sql.Types.TIMESTAMP);
                }
              } else {
                pstmt.setNull(6, java.sql.Types.TIMESTAMP);
              }
              pstmt.addBatch();
            }
            pstmt.executeBatch();
          }
        }
        
        // 3. After inserting bookings, remove any used caregiver availability entries
        String deleteAvailSql = "DELETE FROM caregiver_availability WHERE availability_id = ?";
        try (PreparedStatement delStmt = conn.prepareStatement(deleteAvailSql)) {
          for (Cart.CartItem item : cart.getItems()) {
            Integer availId = item.getAvailabilityId();
            if (availId != null) {
              delStmt.setInt(1, availId);
              delStmt.addBatch();
            }
          }
          try {
            delStmt.executeBatch();
          } catch (SQLException ex) {
            // ignore deletion errors (availability may already be removed)
          }
        }

        // 4. Commit transaction
        conn.commit();

        // 5. Clear cart from session 
        CartSessionManager.clearCart(request);

        // 6. Redirect to order confirmation
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