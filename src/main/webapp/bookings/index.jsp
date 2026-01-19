<%@page import="models.Booking"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!--
  Author: Zhang Junkai, Goh Yi Xin Karys
  Admin No: P2429634, P2424431
  Class: DIT-2B-01
  Last Edited: 19/01/2026
  Description: Unified bookings and orders page showing all user bookings with order context
-->

<%
ArrayList<Booking> bookingList = (ArrayList<Booking>) request.getAttribute("bookingList");
List<Map<String, Object>> orders = (List<Map<String, Object>>) request.getAttribute("orders");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Bookings & Orders | SilverCare</title>
<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: "Georgia", serif;
  background-color: #f5f5f5;
}

.bookings-container {
  width: 90%;
  max-width: 1200px;
  margin: 40px auto;
  padding: 40px;
  background: #ffdce4;
  border-radius: 30px;
  box-shadow: 0 6px 24px rgba(0,0,0,0.15);
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 40px;
  color: #222;
  margin-bottom: 10px;
}

.page-header p {
  font-size: 18px;
  color: #666;
}

.page-header hr {
  width: 200px;
  margin: 20px auto;
  border: none;
  border-top: 2px solid #333;
}

/* Tab Navigation */
.tabs-container {
  display: flex;
  gap: 15px;
  margin-bottom: 30px;
  border-bottom: 2px solid #ffb3cc;
  flex-wrap: wrap;
}

.tab-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: bold;
  color: #666;
  border-bottom: 3px solid transparent;
  transition: all 0.3s;
  font-family: "Georgia", serif;
}

.tab-btn:hover {
  color: #b3003b;
}

.tab-btn.active {
  color: #b3003b;
  border-bottom-color: #b3003b;
}

/* Tab Content */
.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
  animation: fadeIn 0.3s;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Bookings List */
.bookings-list {
  display: grid;
  gap: 20px;
}

.booking-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: all 0.3s;
  border-left: 5px solid #ffb3cc;
}

.booking-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}

.booking-card-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 15px;
}

.booking-card-title {
  font-size: 22px;
  font-weight: bold;
  color: #222;
}

.booking-status {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: bold;
}

.status-upcoming {
  background: #e3f2fd;
  color: #1976d2;
}

.status-in-progress {
  background: #fff3e0;
  color: #f57c00;
}

.status-completed {
  background: #e8f5e9;
  color: #388e3c;
}

.booking-details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
}

.detail-item {
  font-size: 16px;
  color: #555;
}

.detail-label {
  font-weight: bold;
  color: #333;
  margin-right: 8px;
}

.detail-value {
  color: #666;
}

@media (max-width: 768px) {
  .booking-details {
    grid-template-columns: 1fr;
  }
}

/* Orders Table */
.orders-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.orders-table thead {
  background: #ffbfd0;
}

.orders-table th {
  padding: 16px;
  font-weight: bold;
  text-align: left;
  color: #222;
  border-bottom: 2px solid #ff9fb7;
}

.orders-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #f0f0f0;
  color: #555;
}

.orders-table tbody tr:hover {
  background: #fff8f9;
}

.orders-table tbody tr:last-child td {
  border-bottom: none;
}

.order-link {
  color: #b3003b;
  text-decoration: none;
  font-weight: 600;
}

.order-link:hover {
  text-decoration: underline;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.empty-state-icon {
  font-size: 60px;
  margin-bottom: 20px;
}

.empty-state h3 {
  font-size: 24px;
  color: #333;
  margin-bottom: 10px;
}

.empty-state p {
  font-size: 16px;
  color: #666;
  margin-bottom: 20px;
}

.btn-primary {
  display: inline-block;
  background: #ffbfd0;
  color: #000;
  padding: 12px 24px;
  border-radius: 20px;
  text-decoration: none;
  font-weight: bold;
  transition: all 0.2s;
}

.btn-primary:hover {
  background: #ff9fb7;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}
</style>
</head>
<body>
  <!-- INCLUDE NAVBAR -->
  <%@ include file="/WEB-INF/components/user/userNavBar.jsp"%>

  <!-- MAIN CONTAINER -->
  <div class="bookings-container">
    <!-- PAGE HEADER -->
    <div class="page-header">
      <h1>My Bookings & Orders</h1>
      <p>View all your service bookings and order details in one place</p>
      <hr>
    </div>

    <!-- TAB NAVIGATION -->
    <div class="tabs-container">
      <button class="tab-btn active" onclick="switchTab('bookings-tab')">
        📅 All Bookings
      </button>
      <button class="tab-btn" onclick="switchTab('orders-tab')">
        🛒 Order History
      </button>
    </div>

    <!-- BOOKINGS TAB -->
    <div id="bookings-tab" class="tab-content active">
      <%
      if (bookingList != null && !bookingList.isEmpty()) {
      %>
        <div class="bookings-list">
          <%
          for (Booking booking : bookingList) {
            String statusClass = booking.isCheckedOut() ? "status-completed" : 
                                (booking.isCheckedIn() ? "status-in-progress" : "status-upcoming");
            String statusText = booking.isCheckedOut() ? "Completed" : 
                               (booking.isCheckedIn() ? "In Progress" : "Upcoming");
          %>
            <div class="booking-card">
              <div class="booking-card-header">
                <div>
                  <div class="booking-card-title"><%= booking.getProduct() != null ? booking.getProduct().getName() : "Unknown Service" %></div>
                </div>
                <span class="booking-status <%= statusClass %>"><%= statusText %></span>
              </div>
              
              <div class="booking-details">
                <div class="detail-item">
                  <span class="detail-label">📅 Service Date:</span>
                  <span class="detail-value"><%= booking.getBookingTimeslotFormatted() %></span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">💼 Caregiver:</span>
                  <span class="detail-value"><%= booking.getCaregiver() != null ? booking.getCaregiver().getFullName() : "Not assigned" %></span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">📝 Special Requests:</span>
                  <span class="detail-value"><%= booking.getSpecialRequests() != null && !booking.getSpecialRequests().isEmpty() ? booking.getSpecialRequests() : "None" %></span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">🎫 Booking ID:</span>
                  <span class="detail-value">#<%= booking.getBookingId() %></span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">📆 Booked On:</span>
                  <span class="detail-value"><%= booking.getCreatedAtFormatted() %></span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">🔔 Order ID:</span>
                  <span class="detail-value">#<%= booking.getOrderId() %></span>
                </div>
              </div>
            </div>
          <%
          }
          %>
        </div>
      <%
      } else {
      %>
        <div class="empty-state">
          <div class="empty-state-icon">📋</div>
          <h3>No Bookings Yet</h3>
          <p>You haven't made any service bookings yet. Start exploring our services today!</p>
          <a href="<%= request.getContextPath() %>/services/" class="btn-primary">Browse Services</a>
        </div>
      <%
      }
      %>
    </div>

    <!-- ORDERS TAB -->
    <div id="orders-tab" class="tab-content">
      <%
      if (orders != null && !orders.isEmpty()) {
      %>
        <table class="orders-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Date</th>
              <th>Bookings</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <%
            for (Map<String, Object> order : orders) {
              Integer orderId = (Integer) order.get("orderId");
              java.sql.Timestamp createdAt = (java.sql.Timestamp) order.get("createdAt");
              Integer bookingCount = (Integer) order.get("bookingCount");
              String formattedDate = createdAt != null ? createdAt.toString().substring(0, 10) : "";
            %>
              <tr>
                <td><strong>#<%= orderId %></strong></td>
                <td><%= formattedDate %></td>
                <td><span class="booking-status status-upcoming"><%= bookingCount %> booking(s)</span></td>
                <td>
                  <a href="<%= request.getContextPath() %>/user/orders?view=details&orderId=<%= orderId %>" class="order-link">View Details →</a>
                </td>
              </tr>
            <%
            }
            %>
          </tbody>
        </table>
      <%
      } else {
      %>
        <div class="empty-state">
          <div class="empty-state-icon">🛒</div>
          <h3>No Orders Yet</h3>
          <p>You haven't placed any orders yet. Browse our services and place your first booking!</p>
          <a href="<%= request.getContextPath() %>/services/" class="btn-primary">Browse Services</a>
        </div>
      <%
      }
      %>
    </div>
  </div>

  <script>
    function switchTab(tabId) {
      // Hide all tabs
      var tabs = document.querySelectorAll('.tab-content');
      tabs.forEach(function(tab) {
        tab.classList.remove('active');
      });
      
      // Show selected tab
      document.getElementById(tabId).classList.add('active');
      
      // Update button states
      var buttons = document.querySelectorAll('.tab-btn');
      buttons.forEach(function(btn) {
        btn.classList.remove('active');
      });
      event.target.classList.add('active');
    }
  </script>
</body>
</html>