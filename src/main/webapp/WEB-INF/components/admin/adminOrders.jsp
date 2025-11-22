<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Admin order management page displaying all orders with booking counts
--%>
    <h1>Order Management</h1>
    <p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
    <hr>

    <h2>All Orders</h2>

    <%
        java.util.List<java.util.Map<String,Object>> orders = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("orders");
        if (orders == null || orders.isEmpty()) {
    %>
        <p><em>No orders found.</em></p>
    <%
        } else {
    %>
        <table>
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
                for (java.util.Map<String,Object> o : orders) {
                    Integer orderId = (Integer) o.get("orderId");
                    java.sql.Timestamp createdAt = (java.sql.Timestamp) o.get("createdAt");
                    String email = (String) o.get("email");
                    Integer bookingCount = (Integer) o.get("bookingCount");
                    String formattedDate = createdAt != null ? createdAt.toString().substring(0,19).replace("T"," ") : "";
            %>
                <tr>
                    <td><%= orderId %></td>
                    <td><%= email %></td>
                    <td><%= bookingCount != null ? bookingCount : 0 %></td>
                    <td><%= formattedDate %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/admin/orders?include=details&orderId=<%= orderId %>">View Details</a>
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

