<%@page import="models.Booking"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!--
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 16/01/2025
  Description: Dynamic bookings page that adapts to the role of the user
-->

<%
ArrayList<Booking> bookingList = (ArrayList<Booking>) request.getAttribute("bookingList");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Bookings</title>
<style>
body {
  margin: 0;
  font-family: "Georgia", serif;
  background-color: #f5f5f5;
}

.bookings-container {
  width: 80%;
  max-width: 800px;
  margin: 40px auto;
  padding: 20px;
  background: #ffdce4; /* Matching about-section background from index.jsp */
  border-radius: 25px;
  text-align: center;
}

.bookings-container h2 {
  font-size: 32px;
  margin-bottom: 10px;
  letter-spacing: 2px;
}

.bookings-container hr {
  width: 180px;
  margin: 10px auto 20px auto;
  border: none;
  border-top: 2px solid black;
}

.bookings-list {
  max-height: 600px; /* Adjustable max height for scrolling if many bookings */
  overflow-y: auto; /* Makes it scrollable */
  padding: 10px;
}

.booking-box {
  background: rgba(255, 255, 255, 0.9); /* Semi-transparent white like hero-overlay */
  border-radius: 20px;
  padding: 20px;
  margin: 15px 0;
  text-align: left;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.booking-box h3 {
  font-size: 22px;
  margin-bottom: 10px;
  font-weight: 600;
}

.booking-box p {
  font-size: 16px;
  margin: 5px 0;
}

.booking-box .status {
  font-weight: bold;
  color: #333;
}

.no-bookings {
  font-size: 18px;
  color: #666;
  margin: 20px 0;
}
</style>
</head>
<body>
  <!-- INCLUDE NAVBAR -->
  <%@ include file="/WEB-INF/components/user/userNavBar.jsp"%>

  <!-- BOOKINGS SECTION -->
  <div class="bookings-container">
    <h2>My Bookings</h2>
    <hr>
    <div class="bookings-list">
      <%
      if (bookingList != null && !bookingList.isEmpty()) {
        for (Booking booking : bookingList) {
      %>
      <div class="booking-box">
        <div class="booking-header">
          <h3><%= booking.getProduct().getName() %></h3>
          <p>Date and Time: <%= booking.getCreatedAtFormatted() %></p>
        </div>
        <p>Caregiver: <%= booking.getCaregiver().getFullName() %></p>
        <p>Special Requests: <%= booking.getSpecialRequests() != null ? booking.getSpecialRequests() : "None" %></p>
        <p class="status">Status: 
          <%= booking.isCheckedOut() ? "Completed" : (booking.isCheckedIn() ? "In Progress" : "Upcoming") %>
        </p>
        <p>Booking Made On: <%= booking.getCreatedAtFormatted() %></p>
        <p>Booking ID <%= booking.getBookingId() %></p>
      </div>
      <%
        }
      } else {
      %>
      <p class="no-bookings">You have no bookings yet.</p>
      <%
      }
      %>
    </div>
  </div>
</body>
</html>