<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin order management with order list and booking count using JDBC utility and AuthServlet
--%>
    <h1>Order Management</h1>
    <a href="adminDashboard.jsp">Back to Dashboard</a>
    <hr>

    <h2>All Orders</h2>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Get connection via utility ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = 
                "SELECT o.order_id, o.created_at, u.email, " +
                "       COUNT(b.booking_id) AS booking_count " +
                "FROM \"order\" o " +
                "JOIN \"user\" u ON o.user_id = u.user_id " +
                "LEFT JOIN booking b ON o.order_id = b.order_id " +
                "GROUP BY o.order_id, o.created_at, u.email " +
                "ORDER BY o.created_at DESC";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p><em>No orders found.</em></p>
    <%
            } else {
    %>
                <table border="1" cellpadding="8" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User Email</th>
                            <th>Bookings</th>
                            <th>Created At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        while (rs.next()) {
                            int orderId = rs.getInt("order_id");
                            Timestamp createdAt = rs.getTimestamp("created_at");
                            String email = rs.getString("email");
                            int bookingCount = rs.getInt("booking_count");
                            String formattedDate = createdAt.toString().substring(0, 19).replace("T", " ");
                    %>
                        <tr>
                            <td><%= orderId %></td>
                            <td><%= email %></td>
                            <td><%= bookingCount %></td>
                            <td><%= formattedDate %></td>
                            <td>
                                <a href="adminOrderDetails.jsp?orderId=<%= orderId %>">View Details</a>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading orders: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>

