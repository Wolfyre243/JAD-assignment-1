<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Orders | SilverCare</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .orders-container {
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

    /* Messages */
    .msg-success {
        color: #2d7a2d;
        font-weight: bold;
        background: #d4edda;
        padding: 12px 18px;
        border-radius: 8px;
        margin: 15px 0;
    }

    .msg-error {
        color: #a94442;
        font-weight: bold;
        background: #f2dede;
        padding: 12px 18px;
        border-radius: 8px;
        margin: 15px 0;
    }

    /* Empty state */
    .empty-orders {
        text-align: center;
        padding: 60px 20px;
    }

    .empty-orders h2 {
        font-size: 28px;
        color: #555;
        margin-bottom: 15px;
    }

    .empty-orders p {
        font-size: 18px;
        color: #777;
        margin-bottom: 30px;
    }

    /* Orders table */
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

    /* Buttons */
    .btn {
        font-family: "Georgia", serif;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        display: inline-block;
        padding: 8px 16px;
        border-radius: 15px;
        font-weight: bold;
        font-size: 15px;
        border: 2px solid transparent;
    }

    .btn-primary {
        background: #ffbfd0;
        color: #000;
    }

    .btn-primary:hover {
        background: #ff9fb7;
    }

    .btn-secondary {
        background: #4CAF50;
        color: white;
    }

    .btn-secondary:hover {
        background: #45a049;
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="orders-container">
    <h1>My Orders</h1>
    <a href="<%= request.getContextPath() %>/services/" class="back-link">← Continue Shopping</a>

    <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
    %>
        <p class="msg-error"><%= error %></p>
    <%
        }

        List<Map<String, Object>> orders = (List<Map<String, Object>>) request.getAttribute("orders");
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");

        if (orders == null || orders.isEmpty()) {
    %>
            <div class="empty-orders">
                <h2>No orders yet</h2>
                <p>You haven't placed any orders. Start shopping to create your first order!</p>
                <a href="<%= request.getContextPath() %>/services/" class="btn btn-secondary">Browse Services</a>
            </div>
    <%
        } else {
    %>
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Order Date</th>
                        <th>Items</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> order : orders) {
                        int orderId = (Integer) order.get("orderId");
                        Timestamp createdAt = (Timestamp) order.get("createdAt");
                        int bookingCount = (Integer) order.get("bookingCount");
                %>
                    <tr>
                        <td><strong>#<%= orderId %></strong></td>
                        <td><%= dateFormat.format(createdAt) %></td>
                        <td><%= bookingCount %> <%= bookingCount == 1 ? "item" : "items" %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/user/orders?view=details&orderId=<%= orderId %>" 
                               class="btn btn-primary">View Details</a>
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
    <%
        }
    %>
</div>

</body>
</html>
