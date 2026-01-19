<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Order Confirmation Page with Order details
--%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Order Confirmed | SilverCare</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .confirmation-container {
        width: 90%;
        max-width: 800px;
        margin: 60px auto;
        padding: 50px;
        background: #ffdce4;
        border-radius: 30px;
        box-shadow: 0 6px 24px rgba(0,0,0,0.15);
        text-align: center;
    }

    .success-icon {
        font-size: 72px;
        color: #4CAF50;
        margin-bottom: 20px;
    }

    .error-icon {
        font-size: 72px;
        color: #ff6b6b;
        margin-bottom: 20px;
    }

    h1 {
        font-size: 38px;
        font-weight: bold;
        margin: 20px 0;
        color: #222;
    }

    .message {
        font-size: 20px;
        color: #333;
        margin: 20px 0;
        line-height: 1.6;
    }

    .message.error {
        color: #c82333;
        font-weight: 600;
    }

    .thank-you {
        font-size: 22px;
        color: #555;
        margin: 25px 0 40px;
        font-style: italic;
    }

    .order-details {
        background: white;
        padding: 25px;
        border-radius: 15px;
        margin: 30px 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .order-details p {
        font-size: 18px;
        margin: 10px 0;
        color: #333;
    }

    .order-id {
        font-weight: bold;
        color: #b3003b;
        font-size: 24px;
    }

    .action-buttons {
        margin-top: 40px;
        display: flex;
        gap: 20px;
        justify-content: center;
        flex-wrap: wrap;
    }

    .btn {
        display: inline-block;
        padding: 14px 32px;
        font-size: 18px;
        font-weight: bold;
        font-family: "Georgia", serif;
        text-decoration: none;
        border-radius: 25px;
        transition: all 0.3s;
        cursor: pointer;
    }

    .btn-primary {
        background: #4CAF50;
        color: white;
        border: 2px solid #388E3C;
    }

    .btn-primary:hover {
        background: #45a049;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }

    .btn-secondary {
        background: #ffbfd0;
        color: #000;
        border: 2px solid #ff9fb7;
    }

    .btn-secondary:hover {
        background: #ff9fb7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="confirmation-container">
    <%
        String orderIdStr = request.getParameter("orderId");
        Integer userId = (Integer) session.getAttribute("userId");
        String message = "Your order has been successfully placed.";
        String status = "";
        String orderDetails = "";

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            message = "Invalid order reference.";
            status = "error";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                int orderId = Integer.parseInt(orderIdStr);
                conn = JDBC.connect();
                if (conn == null) throw new SQLException("DB connection failed");

                pstmt = conn.prepareStatement(
                    "SELECT o.order_id, o.created_at FROM \"order\" o WHERE o.order_id = ? AND o.user_id = ?"
                );
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, userId);
                rs = pstmt.executeQuery();

                if (!rs.next()) {
                    message = "Order not found or access denied.";
                    status = "error";
                } else {
                    String createdAt = rs.getTimestamp("created_at").toString();
                    orderDetails = "Order #" + orderId + " placed on " + createdAt.substring(0, 19).replace("T", " at ");
                }
            } catch (Exception e) {
                e.printStackTrace();
                message = "Failed to load order details.";
                status = "error";
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    %>

    <% if (status.equals("error")) { %>
        <div class="error-icon">✖</div>
        <h1>Order Error</h1>
        <p class="message error"><%= message %></p>
    <% } else { %>
        <div class="success-icon">✓</div>
        <h1>Order Confirmed!</h1>
        <p class="message"><%= message %></p>
        
        <% if (!orderDetails.isEmpty()) { %>
            <div class="order-details">
                <p class="order-id"><%= orderDetails %></p>
            </div>
        <% } %>
        
        <p class="thank-you">Thank you for your purchase!</p>
    <% } %>

    <div class="action-buttons">
        <a href="<%= request.getContextPath() %>/services/" class="btn btn-secondary">Continue Shopping</a>
        <a href="<%= request.getContextPath() %>/bookings" class="btn btn-primary">View My Bookings</a>
    </div>
</div>

</body>
</html>