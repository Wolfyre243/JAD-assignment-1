<%--
 - Name: Goh Yi Xin Karys
 - Admin No: P2424431
 - Class: DIT/FT/2B/01
 - Description: User order details page showing bookings, service details, and order information
 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Order Details | SilverCare</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .order-details-container {
        width: 90%;
        max-width: 1200px;
        margin: 40px auto;
        padding: 40px;
        background: #ffdce4;
        border-radius: 30px;
        box-shadow: 0 6px 24px rgba(0,0,0,0.15);
    }

    h1 {
        font-size: 36px;
        font-weight: bold;
        margin-top: 0;
        margin-bottom: 10px;
        color: #222;
    }

    .back-link {
        display: inline-block;
        color: #b3003b;
        text-decoration: none;
        font-weight: 600;
        margin-bottom: 25px;
        font-size: 18px;
    }

    .back-link:hover {
        text-decoration: underline;
    }

    /* Order info card */
    .order-info {
        background: white;
        padding: 25px;
        border-radius: 15px;
        margin: 20px 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .order-info h2 {
        margin-top: 0;
        color: #b3003b;
        font-size: 24px;
    }

    .order-info p {
        font-size: 18px;
        margin: 10px 0;
        color: #333;
    }

    /* Bookings table */
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
        background: white;
        border-radius: 12px;
        overflow: hidden;
    }

    table th {
        background: #ffbfd0;
        padding: 14px 16px;
        font-weight: bold;
        text-align: left;
        font-size: 17px;
        border-bottom: 2px solid #333;
    }

    table td {
        padding: 12px 16px;
        border-bottom: 1px solid #f0f0f0;
        font-size: 16px;
    }

    table tr:last-child td {
        border-bottom: none;
    }

    table tr:hover {
        background: #fff8f9;
    }

    /* Total section */
    .order-total {
        background: white;
        padding: 25px;
        border-radius: 15px;
        margin: 20px 0;
        text-align: right;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .order-total .total-label {
        font-size: 24px;
        font-weight: bold;
        color: #222;
    }

    .order-total .total-amount {
        font-size: 32px;
        font-weight: bold;
        color: #b3003b;
        margin-top: 10px;
    }

    /* Action buttons */
    .action-buttons {
        margin-top: 30px;
        display: flex;
        gap: 15px;
    }

    .btn {
        font-family: "Georgia", serif;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        display: inline-block;
        padding: 12px 24px;
        border-radius: 20px;
        font-weight: bold;
        font-size: 16px;
        border: 2px solid transparent;
    }

    .btn-primary {
        background: #ffbfd0;
        color: #000;
    }

    .btn-primary:hover {
        background: #ff9fb7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }

    .btn-secondary {
        background: #4CAF50;
        color: white;
        border: 2px solid #388E3C;
    }

    .btn-secondary:hover {
        background: #45a049;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="order-details-container">
    <%
        Map<String, Object> orderDetails = (Map<String, Object>) request.getAttribute("orderDetails");
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm a");

        if (orderDetails != null) {
            int orderId = (Integer) orderDetails.get("orderId");
            Timestamp createdAt = (Timestamp) orderDetails.get("createdAt");
            List<Map<String, Object>> bookings = (List<Map<String, Object>>) orderDetails.get("bookings");
            double totalAmount = (Double) orderDetails.get("totalAmount");
    %>
            <h1>Order #<%= orderId %></h1>
            <a href="<%= request.getContextPath() %>/user/orders" class="back-link">← Back to My Orders</a>

            <div class="order-info">
                <h2>Order Information</h2>
                <p><strong>Order Date:</strong> <%= dateFormat.format(createdAt) %></p>
                <p><strong>Number of Services:</strong> <%= bookings.size() %></p>
            </div>

            <h2 style="margin-top: 30px; margin-bottom: 15px; color: #222;">Booked Services</h2>
            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Service</th>
                        <th>Price</th>
                        <th>Caregiver ID</th>
                        <th>Client ID</th>
                        <th>Special Requests</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> booking : bookings) {
                        int bookingId = (Integer) booking.get("bookingId");
                        String productName = (String) booking.get("productName");
                        double price = (Double) booking.get("price");
                        Object caregiverId = booking.get("caregiverId");
                        Object clientId = booking.get("clientId");
                        String specialRequests = (String) booking.get("specialRequests");
                %>
                    <tr>
                        <td>#<%= bookingId %></td>
                        <td><strong><%= productName %></strong></td>
                        <td>$<%= String.format("%.2f", price) %></td>
                        <td><%= caregiverId != null ? caregiverId : "N/A" %></td>
                        <td><%= clientId != null ? clientId : "N/A" %></td>
                        <td><%= specialRequests != null && !specialRequests.isEmpty() ? specialRequests : "None" %></td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>

            <div class="order-total">
                <div class="total-label">Total Amount:</div>
                <div class="total-amount">$<%= String.format("%.2f", totalAmount) %></div>
            </div>

            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/user/orders" class="btn btn-primary">Back to Orders</a>
                <a href="<%= request.getContextPath() %>/services/" class="btn btn-secondary">Continue Shopping</a>
            </div>
    <%
        } else {
    %>
            <h1>Order Not Found</h1>
            <p style="font-size: 18px; color: #a94442;">The order you're looking for doesn't exist or you don't have permission to view it.</p>
            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/user/orders" class="btn btn-primary">Back to My Orders</a>
            </div>
    <%
        }
    %>
</div>

</body>
</html>
