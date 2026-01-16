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

import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;

import db.JDBC;

class BookingController {
  public static void getAllClientBookings(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request) || SessionManagement.isAdmin(request)) {
      System.out.println("User not logged in or is admin. Redirecting to home page.");
      response.sendRedirect(request.getContextPath() + "/");
      return;
    }

    try {
      Integer userId = SessionManagement.getUserId(request);
      Client client = Client.getClientByUserId(userId);
      System.out.println("Fetching bookings for client ID: " + client.getClientId());

      if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login/");
        return;
      }

      ArrayList<Booking> bookingList = Booking.getAllClientBookings(client.getClientId());
      
      request.setAttribute("bookingList", bookingList);
      RequestDispatcher dispatcher = request.getRequestDispatcher("/bookings/");
      dispatcher.forward(request, response);

    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error loading profile: " + e.getMessage());
    }

  }
}

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
    BookingController.getAllClientBookings(request, response);
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // TODO Auto-generated method stub
    doGet(request, response);
  }

}
