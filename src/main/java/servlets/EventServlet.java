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
        // Show success message when redirected after booking
        if ("1".equals(request.getParameter("booked"))) {
          request.setAttribute("successMessage", "Successfully signed up for this event. A confirmation email has been sent.");
          String bookingId = request.getParameter("bookingId");
          request.setAttribute("bookingId", bookingId);
        }
        // Show duplicate message when user already signed up
        if ("1".equals(request.getParameter("duplicate"))) {
          request.setAttribute("errorMessage", "You have already signed up for this event.");
        }
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

      // Read submitted guest fields unconditionally (logged-in users will see email prefilled)
      guestName = request.getParameter("guestName");
      guestEmail = request.getParameter("guestEmail");

      // If logged-in and guestEmail is empty, attempt to populate from client/user records
      if ((guestEmail == null || guestEmail.trim().isEmpty())) {
        if (clientId != null) {
          try {
            Client c = Client.getClientById(clientId);
            if (c != null) guestEmail = c.getEmail();
          } catch (Exception ignored) {
          }
        } else if (userId != null) {
          try {
            models.User u = models.User.getUserById(userId);
            if (u != null) guestEmail = u.getEmail();
          } catch (Exception ignored) {
          }
        }
      }

      // Basic validation: guests need both name and email; logged-in users must provide name
      if (!SessionManagement.isLoggedIn(request)) {
        if (guestEmail == null || guestEmail.trim().isEmpty() || guestName == null || guestName.trim().isEmpty()) {
          final Event ev = Event.getEventById(eventId);
          request.setAttribute("event", ev);
          request.setAttribute("errorMessage", "Please provide your full name and email to sign up.");
          request.getRequestDispatcher("/events/details.jsp").forward(request, response);
          return;
        }
      } else {
        if (guestName == null || guestName.trim().isEmpty()) {
          final Event ev = Event.getEventById(eventId);
          request.setAttribute("event", ev);
          request.setAttribute("errorMessage", "Please enter your full name to sign up.");
          request.getRequestDispatcher("/events/details.jsp").forward(request, response);
          return;
        }
      }

      // Check event active and capacity before booking
      Event ev = Event.getEventById(eventId);
      if (ev == null) {
        request.setAttribute("errorMessage", "Event not found.");
        request.setAttribute("event", Event.getEventById(eventId));
        request.getRequestDispatcher("/events/details.jsp").forward(request, response);
        return;
      }

      if (!ev.isActive()) {
        request.setAttribute("errorMessage", "This event is no longer active.");
        request.setAttribute("event", ev);
        request.getRequestDispatcher("/events/details.jsp").forward(request, response);
        return;
      }

      int currentCount = EventBooking.getBookingCount(eventId);
      if (currentCount >= ev.getCapacity()) {
        // auto-deactivate just in case
        Event.setActive(eventId, false);
        request.setAttribute("errorMessage", "This event is full.");
        request.setAttribute("event", ev);
        request.getRequestDispatcher("/events/details.jsp").forward(request, response);
        return;
      }

      // Prevent duplicate sign-ups
      if (EventBooking.hasBooking(eventId, clientId, userId, guestEmail)) {
        response.sendRedirect(request.getContextPath() + "/events?id=" + eventId + "&duplicate=1");
        return;
      }

      int bookingId = EventBooking.createBooking(eventId, clientId, userId, guestName, guestEmail);

      // Send confirmation email (if an email is available) asynchronously
      try {
        final String recipient;
        final String recipientName;
        if (guestEmail != null && !guestEmail.trim().isEmpty()) {
          recipient = guestEmail;
          recipientName = guestName;
        } else if (clientId != null) {
          Client c = Client.getClientById(clientId);
          recipient = (c != null) ? c.getEmail() : null;
          recipientName = (c != null) ? ((c.getFirstName() != null ? c.getFirstName() : "") + (c.getLastName() != null ? (" " + c.getLastName()) : "")) : null;
        } else if (userId != null) {
          models.User u = models.User.getUserById(userId);
          recipient = (u != null) ? u.getEmail() : null;
          recipientName = null;
        } else {
          recipient = null;
          recipientName = null;
        }

        if (recipient != null && !recipient.trim().isEmpty()) {
          final String to = recipient;
          final String subject = "Confirmation - " + ev.getTitle() + " sign-up";
          final String body = "Hello " + (recipientName != null ? recipientName : "") + ",\n\n" +
              "You have successfully signed up for the event: " + ev.getTitle() + "\n" +
              "When: " + ev.getStartTime() + " - " + ev.getEndTime() + "\n" +
              "Where: " + (ev.getLocation() != null ? ev.getLocation() : "TBA") + "\n\n" +
              "Booking ID: " + bookingId + "\n\n" +
              "Thank you,\nSilverCare Team";

          new Thread(() -> {
            try {
              lib.EmailUtil.sendEmail(getServletContext(), to, subject, body);
            } catch (Exception e) {
              e.printStackTrace();
            }
          }).start();
        }
      } catch (Exception e) {
        e.printStackTrace();
      }

      response.sendRedirect(request.getContextPath() + "/events?id=" + eventId + "&booked=1&bookingId=" + bookingId);
    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error booking event: " + e.getMessage());
      doGet(request, response);
    }
  }
}
