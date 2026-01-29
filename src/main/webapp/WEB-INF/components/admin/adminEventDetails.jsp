<%--
  Admin view: Event signup details
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="models.Event" %>

<h2>Event Signups</h2>
<p><a href="<%= request.getContextPath() %>/admin/events">← Back to Events</a></p>
<hr/>

<%
  Event ev = (Event) request.getAttribute("selectedEvent");
  java.util.List<java.util.Map<String,Object>> bookings = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("bookings");
  if (ev == null) {
%>
<p><em>Event not found.</em></p>
<%
  } else {
%>
  <h3><%= ev.getTitle() %></h3>
  <p><strong>When:</strong> <%= ev.getStartTime() %> - <%= ev.getEndTime() %></p>
  <p><strong>Location:</strong> <%= ev.getLocation() != null ? ev.getLocation() : "TBA" %></p>
  <p><strong>Capacity:</strong> <%= ev.getCapacity() %></p>
  <p><strong>Registered:</strong> <%= bookings != null ? bookings.size() : 0 %></p>

  <h4>Signups</h4>
  <% if (bookings == null || bookings.isEmpty()) { %>
    <p><em>No signups yet.</em></p>
  <% } else { %>
    <table>
      <thead>
        <tr>
          <th>Booking ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Signed up at</th>
        </tr>
      </thead>
      <tbody>
        <% for (Map<String,Object> b : bookings) { %>
          <tr>
            <td><%= b.get("bookingId") %></td>
            <td><%= b.get("name") != null ? b.get("name") : "" %></td>
            <td><%= b.get("email") != null ? b.get("email") : "" %></td>
            <td><%= b.get("createdAt") %></td>
          </tr>
        <% } %>
      </tbody>
    </table>
  <% } %>
<% } %>