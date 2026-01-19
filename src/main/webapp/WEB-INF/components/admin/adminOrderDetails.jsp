<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Admin order details page showing bookings and order information
--%>

    <%
        java.util.Map<String,Object> order = (java.util.Map<String,Object>) request.getAttribute("order");
        String orderError = (String) request.getAttribute("orderError");
        if (orderError != null) {
    %>
        <p class="msg-error"><%= orderError %></p>
        <p><a href="<%= request.getContextPath() %>/admin/orders">← Back to Orders</a></p>
    <%
        } else if (order == null) {
    %>
        <p class="msg-error">Order data not available.</p>
        <p><a href="<%= request.getContextPath() %>/admin/orders">← Back to Orders</a></p>
    <%
        } else {
            int orderId = (Integer) order.get("orderId");
            java.sql.Timestamp createdAt = (java.sql.Timestamp) order.get("createdAt");
            String email = (String) order.get("email");
            String formattedOrderDate = createdAt != null ? createdAt.toString().substring(0,19).replace("T"," ") : "";
    %>
    <h1>Order Details</h1>
    <p><a href="<%= request.getContextPath() %>/admin/orders">← Back to Orders</a></p>
    <hr>

    <h2>Order #<%= orderId %></h2>
    <p><strong>User:</strong> <%= email %></p>
    <p><strong>Order Date:</strong> <%= formattedOrderDate %></p>

    <h3>Bookings</h3>

    <%
            java.util.List<java.util.Map<String,Object>> bookings = (java.util.List<java.util.Map<String,Object>>) order.get("bookings");
            if (bookings == null || bookings.isEmpty()) {
    %>
        <p><em>No bookings in this order.</em></p>
    <%
            } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Product/Service</th>
                    <th>Booking Time</th>
                    <th>Special Requests</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (java.util.Map<String,Object> b : bookings) {
                    int bookingId = (Integer) b.get("bookingId");
                    String productName = (String) b.get("productName");
                    String specialRequests = (String) b.get("specialRequests");
                    java.sql.Timestamp bookingCreatedAt = (java.sql.Timestamp) b.get("createdAt");
                    java.sql.Timestamp bookingTimeslot = (java.sql.Timestamp) b.get("bookingTimeslot");
                    String formattedBookingDate = bookingCreatedAt != null ? bookingCreatedAt.toString().substring(0,19).replace("T"," ") : "";
                    String formattedTimeslot = bookingTimeslot != null ? bookingTimeslot.toString().substring(0,19).replace("T"," ") : "Not specified";
            %>
                <tr>
                    <td><%= bookingId %></td>
                    <td><%= productName != null ? productName : "N/A" %></td>
                    <td><%= formattedTimeslot %></td>
                    <td><%= specialRequests != null && !specialRequests.trim().isEmpty() ? specialRequests : "None" %></td>
                    <td><%= formattedBookingDate %></td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
            }
        }
    %>
