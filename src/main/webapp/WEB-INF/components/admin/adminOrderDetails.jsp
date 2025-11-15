<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin view for order details with user info and bookings using JDBC utility and AuthServlet
--%>

    <%
        // === INPUT VALIDATION ===
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect("adminOrders.jsp?msg=invalid");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("adminOrders.jsp?msg=invalid");
            return;
        }
    %>

    <h1>Order Details</h1>
    <a href="adminOrders.jsp">Back to Orders</a>
    <hr>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Get connection via utility ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            // === FETCH ORDER HEADER ===
            String orderSql = 
                "SELECT o.order_id, o.created_at, u.email " +
                "FROM \"order\" o " +
                "JOIN \"user\" u ON o.user_id = u.user_id " +
                "WHERE o.order_id = ?";

            pstmt = conn.prepareStatement(orderSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
    %>
                <p style="color:red;">Order not found.</p>
                <a href="adminOrders.jsp">Back to Orders</a>
    <%
                return;
            }

            Timestamp createdAt = rs.getTimestamp("created_at");
            String email = rs.getString("email");
            String formattedOrderDate = createdAt.toString().substring(0, 19).replace("T", " ");
    %>

    <h2>Order #<%= orderId %></h2>
    <p><strong>User:</strong> <%= email %></p>
    <p><strong>Order Date:</strong> <%= formattedOrderDate %></p>

    <h3>Bookings</h3>

    <%
            rs.close();
            pstmt.close();

            // === FETCH BOOKINGS ===
            String bookingSql = 
                "SELECT b.booking_id, p.name AS product_name, " +
                "       b.special_requests, b.created_at " +
                "FROM booking b " +
                "LEFT JOIN product p ON b.product_id = p.product_id " +
                "WHERE b.order_id = ? " +
                "ORDER BY b.created_at";

            pstmt = conn.prepareStatement(bookingSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p><em>No bookings in this order.</em></p>
    <%
            } else {
    %>
                <table border="1" cellpadding="8" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>Product/Service</th>
                            <th>Special Requests</th>
                            <th>Created At</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        while (rs.next()) {
                            int bookingId = rs.getInt("booking_id");
                            String productName = rs.getString("product_name");
                            String specialRequests = rs.getString("special_requests");
                            Timestamp bookingCreatedAt = rs.getTimestamp("created_at");
                            String formattedBookingDate = bookingCreatedAt.toString().substring(0, 19).replace("T", " ");
                    %>
                        <tr>
                            <td><%= bookingId %></td>
                            <td><%= productName != null ? productName : "N/A" %></td>
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

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading order details: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>
