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
<%@ include file="/WEB-INF/components/common/header.jsp" %>
    <%
        String orderIdStr = request.getParameter("orderId");
        Integer userId = (Integer) session.getAttribute("userId");
        String message = "Your order has been successfully placed.";
        String status = "";

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
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
                    message = "Order #" + orderId + " placed on " + createdAt.substring(0, 19).replace("T", " at ") + ".";
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

    <h1>Order Confirmed!</h1>
    <p <%= status.equals("error") ? "style='color:red;'" : "" %>><%= message %></p>
    <p>Thank you for your purchase!</p>
    <br>
    <a href="products.jsp">Continue Shopping</a>
    <a href="viewOrders.jsp">View My Orders</a>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>