<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="models.Cart" %>

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
        // Get cart items from session (via ViewCartServlet)
        List<Cart.CartItem> items = (List<Cart.CartItem>) request.getAttribute("items");
        Double total = (Double) request.getAttribute("total");

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
                    int index = 0; // Use index instead of cartItemId
                    for (Cart.CartItem item : items) {
                %>
                    <tr>
                        <td><%= item.getServiceName() %></td>
                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/product/updateCartQuantity" method="post" style="margin:0; display:inline;">
                                <input type="hidden" name="itemIndex" value="<%= index %>">
                                <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" max="99" style="width:60px;">
                                <button type="submit">Update</button>
                            </form>
                        </td>
                        <td>$<%= String.format("%.2f", item.getSubtotal()) %></td>
                        <td><%= item.getCaregiverId() != null ? item.getCaregiverId() : "N/A" %></td>
                        <td><%= item.getClientId() != null ? item.getClientId() : "N/A" %></td>
                        <td><%= item.getSpecialRequests() != null ? item.getSpecialRequests() : "" %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/product/removeFromCart" method="post" style="margin:0; display:inline;">
                                <input type="hidden" name="itemIndex" value="<%= index %>">
                                <button type="submit" onclick="return confirm('Remove this item?');">Remove</button>
                            </form>
                        </td>
                    </tr>
                <%
                        index++; // Increment index for next item
                    }
                %>
                </tbody>
            </table>

            <p><strong>Total: $<%= String.format("%.2f", total != null ? total : 0.0) %></strong></p>

            <form action="<%= request.getContextPath() %>/product/checkout" method="post" style="display:inline;">
                <button type="submit" style="padding: 10px 20px; font-size: 16px; background: #4CAF50; color: white; border: none; cursor: pointer;">
                    Proceed to Checkout
                </button>
            </form>
    <%
        }
    %>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>