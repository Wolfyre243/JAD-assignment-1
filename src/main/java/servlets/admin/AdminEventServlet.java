/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 28/01/2026
*/

package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lib.SessionManagement;
import models.Event;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet("/admin/events/action")
public class AdminEventServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
      response.sendRedirect(request.getContextPath() + "/");
      return;
    }

    // Redirect to the admin panel route which renders the admin layout
    response.sendRedirect(request.getContextPath() + "/admin/events");
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
      response.sendRedirect(request.getContextPath() + "/");
      return;
    }

    String action = request.getParameter("action");
    try {
      if ("create".equals(action)) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String start = request.getParameter("start_time");
        String end = request.getParameter("end_time");
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        boolean isActive = "on".equals(request.getParameter("is_active"));

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Timestamp startTs = new Timestamp(sdf.parse(start).getTime());
        Timestamp endTs = new Timestamp(sdf.parse(end).getTime());

        Integer createdBy = SessionManagement.getUserId(request);
        Event.createEvent(title, description, location, startTs, endTs, capacity, isActive, createdBy != null ? createdBy : 0);
      } else if ("update".equals(action)) {
        int eventId = Integer.parseInt(request.getParameter("event_id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String start = request.getParameter("start_time");
        String end = request.getParameter("end_time");
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        boolean isActive = "on".equals(request.getParameter("is_active"));

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Timestamp startTs = new Timestamp(sdf.parse(start).getTime());
        Timestamp endTs = new Timestamp(sdf.parse(end).getTime());

        Event.updateEvent(eventId, title, description, location, startTs, endTs, capacity, isActive);
      } else if ("delete".equals(action)) {
        int eventId = Integer.parseInt(request.getParameter("event_id"));
        Event.deleteEvent(eventId);
      }
    } catch (ParseException pe) {
      request.setAttribute("error", "Invalid date format: " + pe.getMessage());
    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Error saving event: " + e.getMessage());
    }

    response.sendRedirect(request.getContextPath() + "/admin/events");
  }
}
