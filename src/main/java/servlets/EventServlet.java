/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 28/01/2026
*/
package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lib.SessionManagement;
import models.Event;
import models.EventBooking;
import models.Client;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet("/events")
public class EventServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String idParam = request.getParameter("id");
    try {
      if (idParam != null) {
        int id = Integer.parseInt(idParam);
        Event ev = Event.getEventById(id);
        request.setAttribute("event", ev);
        request.getRequestDispatcher("/events/details.jsp").forward(request, response);
        return;
      }

      ArrayList<Event> events = Event.getAllEvents();
      request.setAttribute("events", events);
      request.getRequestDispatcher("/events/index.jsp").forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error loading events: " + e.getMessage());
      request.getRequestDispatcher("/events/index.jsp").forward(request, response);
    }
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    try {
      int eventId = Integer.parseInt(request.getParameter("eventId"));
      Integer clientId = null;
      Integer userId = null;
      String guestName = null;
      String guestEmail = null;

      if (SessionManagement.isLoggedIn(request)) {
        userId = SessionManagement.getUserId(request);
        if (userId != null) {
          try {
            Client c = Client.getClientByUserId(userId);
            if (c != null) clientId = c.getClientId();
          } catch (SQLException ex) {
            // ignore and fallback to userId (recorded as user booking)
          }
        }
      }

      // If there is neither client nor user recorded, accept guest details
      if (clientId == null && userId == null) {
        guestName = request.getParameter("guestName");
        guestEmail = request.getParameter("guestEmail");
      }

      int bookingId = EventBooking.createBooking(eventId, clientId, userId, guestName, guestEmail);
      response.sendRedirect(request.getContextPath() + "/events?booked=1&bookingId=" + bookingId);
    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error booking event: " + e.getMessage());
      doGet(request, response);
    }
  }
}
