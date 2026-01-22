<!--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
-->
  
<%@page import="models.Booking"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Caregiver bookings view: lists bookings assigned to the logged-in caregiver --%>

<%
ArrayList<Booking> bookingList = (ArrayList<Booking>) request.getAttribute("bookingList");
String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Assigned Bookings | SilverCare</title>
<style>
  /* =============== BASE LAYOUT =============== */
  body {
      margin: 0;
      font-family: "Georgia", serif;
      background-color: #f5f5f5;
      min-height: 100vh;
  }

  .bookings-container {
      max-width: 900px;
      margin: 40px auto;
      background: #ffffff;
      border-radius: 25px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
      overflow: hidden;
  }

  .page-header {
      background: linear-gradient(135deg, #ffdce4, #ffbfd0);
      padding: 40px 20px;
      text-align: center;
      color: #333;
  }

  .page-header h1 { margin: 0; font-size: 36px; letter-spacing: 1px; }

  .booking-list { padding: 40px; }

  /* =============== BOOKING CARDS =============== */
  .booking-card {
      background: #fff5f8;
      border-radius: 15px;
      padding: 25px;
      margin-bottom: 25px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05);
      display: flex;
      flex-direction: column;
  }

  .card-inner { display: flex; gap: 20px; align-items: center; }
  .avatar {
      width: 70px;
      height: 70px;
      border-radius: 50%;
      background: linear-gradient(135deg, #ffbfd0, #ffb3c1);
      color: #600018;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 900;
      font-size: 24px;
      flex: 0 0 70px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  }

  .main-info { flex: 1; }
  .title-and-status { display: flex; align-items: center; gap: 15px; margin-bottom: 10px; }
  .title-and-status h3 { margin: 0; font-size: 20px; color: #222; font-weight: bold; }
  .booking-status {
      padding: 8px 14px;
      border-radius: 20px;
      font-weight: 700;
      font-size: 14px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
  }
  .status-upcoming { background: linear-gradient(135deg, #fff0f4, #ffe6ee); color: #b3003b; }
  .status-in-progress { background: linear-gradient(135deg, #fff7e6, #fff0d6); color: #f57c00; }
  .status-completed { background: linear-gradient(135deg, #eef9f0, #e8f5e8); color: #388e3c; }

  .meta { margin-top: 10px; display: flex; gap: 20px; flex-wrap: wrap; color: #555; font-size: 15px; }
  .meta .meta-item { display: flex; gap: 8px; align-items: center; }
  .meta .meta-item strong { color: #333; }

  .contact-area { width: 280px; text-align: right; display: flex; flex-direction: column; gap: 10px; align-items: flex-end; }
  .contact-name { font-weight: 700; color: #222; font-size: 16px; }
  .contact-actions a {
      margin-left: 10px;
      text-decoration: none;
      padding: 10px 16px;
      border-radius: 12px;
      background: #ffbfd0;
      color: #000;
      font-weight: 700;
      transition: background 0.3s ease;
  }
  .contact-actions a:hover { background: #ffa8c0; }

  .card-actions { margin-top: 20px; display: flex; gap: 15px; justify-content: center; flex-wrap: wrap; }
  .btn-primary {
      padding: 14px 20px;
      border-radius: 12px;
      border: none;
      cursor: pointer;
      font-weight: 700;
      text-decoration: none;
      font-size: 15px;
      transition: all 0.3s ease;
      min-width: 120px;
      text-align: center;
  }
  .btn-checkin { background: #ffbfd0; color: #000; }
  .btn-checkin:hover { background: #ffa8c0; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
  .btn-checkout { background: #d81b60; color: white; }
  .btn-checkout:hover { background: #c2185b; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
  .status-badge { padding: 12px 18px; border-radius: 12px; font-weight: 700; font-size: 15px; min-width: 120px; text-align: center; }

  @media (max-width: 868px) {
      .card-inner { flex-direction: column; text-align: center; }
      .contact-area { width: 100%; text-align: center; align-items: center; }
      .bookings-container { margin: 20px; }
      .booking-list { padding: 20px; }
      .avatar { width: 60px; height: 60px; font-size: 20px; }
      .title-and-status { flex-direction: column; gap: 8px; }
      .meta { justify-content: center; }
      .card-actions { justify-content: center; }
  }
</style>
</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="bookings-container">
  <div class="page-header">
    <h1>Assigned Bookings</h1>
    <div class="small">View all bookings assigned to you</div>
  </div>

  <% if (error != null) { %>
    <div style="color:red; margin-bottom:12px;"><%= error %></div>
  <% } %>

  <% java.util.List<java.util.Map<String,Object>> bookingViews = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("bookingViews");
  if (bookingViews != null && !bookingViews.isEmpty()) { %>
    <div class="booking-list">
      <% for (java.util.Map<String,Object> v : bookingViews) {
           Booking b = (Booking) v.get("booking");
           String statusClass = b.isCheckedOut() ? "status-completed" : (b.isCheckedIn() ? "status-in-progress" : "status-upcoming");
           String statusText = b.isCheckedOut() ? "Completed" : (b.isCheckedIn() ? "In Progress" : "Upcoming");
           String contactName = (String) v.get("contactName");
           String contactEmail = (String) v.get("contactEmail");
      %>
        <div class="booking-card">
          <div class="card-inner">
            <% String avatarInitial = "?";
               if (b.getProduct() != null && b.getProduct().getName() != null && !b.getProduct().getName().isEmpty()) {
                   avatarInitial = b.getProduct().getName().substring(0,1).toUpperCase();
               } else if (contactName != null && !contactName.isEmpty()) {
                   avatarInitial = contactName.substring(0,1).toUpperCase();
               }
            %>
            <div class="avatar"><%= avatarInitial %></div>
            <div class="main-info">
              <div class="title-and-status">
                <h3><%= b.getProduct() != null ? b.getProduct().getName() : "Unknown Service" %></h3>
                <span class="booking-status <%= statusClass %>"><%= statusText %></span>
              </div>
              <div class="meta">
                <div class="meta-item"><strong>Date:</strong>&nbsp;<span><%= b.getBookingTimeslotFormatted() %></span></div>
                <div class="meta-item"><strong>Notes:</strong>&nbsp;<span><%= b.getSpecialRequests() != null && !b.getSpecialRequests().isEmpty() ? b.getSpecialRequests() : "None" %></span></div>
                <div class="meta-item"><strong>Booking #</strong>&nbsp;<span>#<%= b.getBookingId() %></span></div>
              </div>
            </div>
            <div class="contact-area">
              <div class="contact-name"><%= contactName != null ? contactName : (contactEmail != null ? contactEmail : "N/A") %></div>
              <div class="contact-actions">
                <% if (contactEmail != null) { %>
                  <a href="mailto:<%= contactEmail %>">Contact</a>
                <% } %>
                <a href="<%= request.getContextPath() %>/caregiver/orderView?orderId=<%= b.getOrderId() %>">View Order</a>
              </div>
            </div>
          </div>
          <div class="card-actions">
            <form action="<%= request.getContextPath() %>/caregiver/bookings/action" method="post" style="display:inline;">
              <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
              <% if (!b.isCheckedIn()) { %>
                <input type="hidden" name="action" value="checkin">
                <button type="submit" class="btn-primary btn-checkin">Check-in</button>
              <% } else { %>
                <span class="status-badge" style="background:#fff7e6; color:#f57c00;">Checked-in</span>
              <% } %>
            </form>
            <form action="<%= request.getContextPath() %>/caregiver/bookings/action" method="post" style="display:inline;">
              <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
              <% if (!b.isCheckedOut()) { %>
                <input type="hidden" name="action" value="checkout">
                <button type="submit" class="btn-primary btn-checkout">Complete</button>
              <% } else { %>
                <span class="status-badge" style="background:#eef9f0; color:#388e3c;">Completed</span>
              <% } %>
            </form>
          </div>
        </div>
      <% } %>
    </div>
  <% } else { %>
    <div class="empty">
      <h3>No assigned bookings</h3>
      <p>You have no bookings assigned at the moment.</p>
    </div>
  <% } %>

</div>

</body>
</html>
