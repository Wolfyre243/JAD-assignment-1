/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 16/01/2025
  Description: Booking Servlet for handling all booking related CRUD operations.
*/

package servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lib.SessionManagement;
import models.Booking;
import models.Client;
import models.User;
import handlers.UserOrderHandler;

import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import db.JDBC;


@WebServlet("/bookings")
public class BookingServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  /**
   * @see HttpServlet#HttpServlet()
   */
  public BookingServlet() {
    super();
    // TODO Auto-generated constructor stub
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // Check if user is logged in and not admin
    if (!SessionManagement.isLoggedIn(request) || SessionManagement.isAdmin(request)) {
      response.sendRedirect(request.getContextPath() + "/");
      return;
    }

    try {
      Integer userId = SessionManagement.getUserId(request);
      System.out.println("DEBUG: Session userId: " + userId);
      System.out.println("DEBUG: Is logged in: " + SessionManagement.isLoggedIn(request));
      System.out.println("DEBUG: Is admin: " + SessionManagement.isAdmin(request));
      if (userId == null) {
        System.out.println("DEBUG: UserId is null, redirecting to login");
        response.sendRedirect(request.getContextPath() + "/auth/login/");
        return;
      }

      // Fetch user's orders and their bookings from database
      List<Map<String, Object>> orders = UserOrderHandler.getUserOrders(userId);
      System.out.println("DEBUG: User ID: " + userId);
      System.out.println("DEBUG: Orders found: " + (orders != null ? orders.size() : "null"));
      
      // Collect all bookings from user's orders
      ArrayList<Booking> bookingList = new ArrayList<>();
      if (orders != null && !orders.isEmpty()) {
        System.out.println("DEBUG: Processing " + orders.size() + " orders");
        for (Map<String, Object> order : orders) {
          Integer orderId = (Integer) order.get("orderId");
          System.out.println("DEBUG: Processing order ID: " + orderId);
          // Get bookings for each order
          Map<String, Object> orderDetails = UserOrderHandler.getOrderDetails(orderId, userId);
          if (orderDetails != null) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> orderBookings = (List<Map<String, Object>>) orderDetails.get("bookings");
            System.out.println("DEBUG: Order " + orderId + " has " + (orderBookings != null ? orderBookings.size() : 0) + " bookings");
            if (orderBookings != null) {
              for (Map<String, Object> booking : orderBookings) {
                // Convert to Booking object for consistency
                int bookingId = (Integer) booking.get("bookingId");
                int productId = booking.get("productId") != null ? (Integer) booking.get("productId") : 0;
                Integer caregiverId = (Integer) booking.get("caregiverId");
                Integer clientId = (Integer) booking.get("clientId");
                String specialRequests = (String) booking.get("specialRequests");
                java.sql.Timestamp bookingTimeslot = (java.sql.Timestamp) booking.get("bookingTimeslot");
                java.sql.Timestamp createdAt = (java.sql.Timestamp) booking.get("createdAt");
                
                Booking b = new Booking(bookingId, orderId, productId, 
                  caregiverId != null ? caregiverId : 0, 
                  clientId != null ? clientId : 0, 
                  specialRequests, false, false, bookingTimeslot, createdAt, createdAt);
                bookingList.add(b);
              }
            }
          }
        }
      }
      
      System.out.println("Fetched " + bookingList.size() + " bookings for user ID: " + userId);
      
      // Set the attributes for the JSP
      request.setAttribute("bookingList", bookingList);
      request.setAttribute("orders", orders);
      request.getRequestDispatcher("/bookings/").forward(request, response);

    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error loading bookings: " + e.getMessage());
      try {
        request.getRequestDispatcher("/bookings/").forward(request, response);
      } catch (Exception e2) {
        response.sendRedirect(request.getContextPath() + "/");
      }
    }
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doGet(request, response);
  }

}
