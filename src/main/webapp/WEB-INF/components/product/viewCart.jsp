<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%@ include file="/WEB-INF/components/common/header.jsp" %>

    <h1>Your Shopping Cart</h1>
    <a href="products.jsp">Continue Shopping</a>
    <br><br>

    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String cls = "msg-success";
            switch (msg) {
                case "updated":    text = "Quantity updated successfully!"; break;
                case "removed":    text = "Item removed from cart."; break;
                case "invalid":    text = "Invalid request."; cls = "msg-error"; break;
                case "invalid_quantity": text = "Please enter a quantity between 1 and 99."; cls = "msg-error"; break;
                case "not_found":  text = "Item not found in your cart."; cls = "msg-error"; break;
                case "db_error":   text = "Database error. Please try again."; cls = "msg-error"; break;
                case "checkout_error": text = "Checkout failed. Please try again."; cls = "msg-error"; break;
                default:           text = "Action completed."; break;
            }
    %>
        <p class="<%= cls %>"><%= text %></p>
    <%
        }
    %>

    <% String error = (String) request.getAttribute("error"); %>
    <%= (error != null) ? ("<p class='msg-error'>" + error + "</p>") : "" %>

    <%
        List<Map<String,Object>> items = (List<Map<String,Object>>) request.getAttribute("items");
        Double total = (Double) request.getAttribute("total");
        Integer cartId = (Integer) request.getAttribute("cartId");

        if (items == null || items.isEmpty()) {
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
                        Integer qty = (Integer) item.get("quantity");
                        Double price = (Double) item.get("price");
                        double subtotal = price * (qty != null ? qty : 1);
                %>
                    <tr>
                        <td><%= item.get("name") %></td>
                        <td>$<%= String.format("%.2f", price) %></td>
                        <td>
                            <form action="/product/updateCartQuantity" method="post" style="margin:0; display:inline;">
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
                            <a href="/product/removeFromCart?cartItemId=<%= item.get("cartItemId") %>" onclick="return confirm('Remove this item?');">Remove</a>
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>

            <p><strong>Total: $<%= String.format("%.2f", total != null ? total : 0.0) %></strong></p>

            <a href="/product/checkout?cartId=<%= cartId %>">Proceed to Checkout</a>
    <%
        }
    %>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>