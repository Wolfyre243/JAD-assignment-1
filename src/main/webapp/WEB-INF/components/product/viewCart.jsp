<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure cart display with quantity update, remove, and checkout links
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Shopping Cart</title>
</head>
<body>
    <h1>Your Shopping Cart</h1>
    <a href="products.jsp">Continue Shopping</a>
    <br><br>

    <%
        // === DISPLAY FEEDBACK MESSAGES ===
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String color = "";
            switch (msg) {
                case "updated":    text = "Quantity updated successfully!"; color = "green"; break;
                case "removed":    text = "Item removed from cart."; color = "green"; break;
                case "invalid":    text = "Invalid request."; color = "red"; break;
                case "invalid_quantity": text = "Please enter a quantity between 1 and 99."; color = "red"; break;
                case "not_found":  text = "Item not found in your cart."; color = "red"; break;
                case "db_error":   text = "Database error. Please try again."; color = "red"; break;
                case "checkout_error": text = "Checkout failed. Please try again."; color = "red"; break;
                default:           text = "Action completed."; color = "green";
            }
    %>
        <p style="color: <%= color %>; font-weight: bold;"><%= text %></p>
    <%
        }
    %>

    <%
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> items = new ArrayList<>();
        double total = 0.0;
        int cartId = 0;

        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            // Fixed: Replaced Java 15+ text block with concatenated string (Java 8/11 compatible)
            String sql = 
                "SELECT ci.cart_item_id, ci.quantity, ci.caregiver_id, ci.client_id, ci.special_requests, " +
                "       p.product_id, p.name, p.price, c.cart_id " +
                "FROM cart_item ci " +
                "JOIN cart c ON ci.cart_id = c.cart_id " +
                "JOIN product p ON ci.product_id = p.product_id " +
                "WHERE c.user_id = ? AND c.checked_out = false " +
                "ORDER BY ci.created_at";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("cartItemId", rs.getInt("cart_item_id"));
                item.put("productId", rs.getInt("product_id"));
                item.put("name", rs.getString("name"));
                item.put("price", rs.getDouble("price"));

                Integer qty = (Integer) rs.getObject("quantity");
                item.put("quantity", qty != null ? qty : 1);

                item.put("caregiverId", rs.getObject("caregiver_id"));
                item.put("clientId", rs.getObject("client_id"));
                item.put("specialRequests", rs.getString("special_requests"));

                items.add(item);
                total += rs.getDouble("price") * (qty != null ? qty : 1);
                cartId = rs.getInt("cart_id");
            }

            if (items.isEmpty()) {
    %>
                <h2>Your cart is empty</h2>
                <p>Add some items to get started!</p>
    <%
            } else {
    %>
                <table border="1" cellpadding="8" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Subtotal</th>
                            <th>Caregiver ID</th>
                            <th>Client ID</th>
                            <th>Special Requests</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (Map<String, Object> item : items) {
                            int qty = (Integer) item.get("quantity");
                            double price = (Double) item.get("price");
                            double subtotal = price * qty;
                    %>
                        <tr>
                            <td><%= item.get("name") %></td>
                            <td>$<%= String.format("%.2f", price) %></td>
                            <td>
                                <form action="updateCartQuantity.jsp" method="post" style="margin:0; display:inline;">
                                    <input type="hidden" name="cartItemId" value="<%= item.get("cartItemId") %>">
                                    <input type="number" name="quantity" value="<%= qty %>" min="1" max="99" style="width:60px;">
                                    <button type="submit">Update</button>
                                </form>
                            </td>
                            <td>$<%= String.format("%.2f", subtotal) %></td>
                            <td><%= item.get("caregiverId") != null ? item.get("caregiverId") : "N/A" %></td>
                            <td><%= item.get("clientId") != null ? item.get("clientId") : "N/A" %></td>
                            <td><%= item.get("specialRequests") != null ? item.get("specialRequests") : "" %></td>
                            <td>
                                <a href="removeFromCart.jsp?cartItemId=<%= item.get("cartItemId") %>"
                                   onclick="return confirm('Remove this item?');">Remove</a>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>

                <p><strong>Total: $<%= String.format("%.2f", total) %></strong></p>

                <a href="checkout.jsp?cartId=<%= cartId %>">Proceed to Checkout</a>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading cart: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>
</body>
</html>