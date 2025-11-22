<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Shopping cart page displaying session-based cart items with update/remove functionality
--%>
<%@ page import="java.util.List" %>
<%@ page import="models.Cart" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Shopping Cart | SilverCare</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .cart-container {
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

    .continue-shopping {
        display: inline-block;
        color: #b3003b;
        text-decoration: none;
        font-weight: 600;
        margin-bottom: 25px;
        font-size: 18px;
    }

    .continue-shopping:hover {
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

    /* Empty cart */
    .empty-cart {
        text-align: center;
        padding: 60px 20px;
    }

    .empty-cart h2 {
        font-size: 28px;
        color: #555;
        margin-bottom: 15px;
    }

    .empty-cart p {
        font-size: 18px;
        color: #777;
    }

    /* Cart table */
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

    /* Form inputs */
    input[type="number"] {
        padding: 8px;
        font-size: 16px;
        font-family: "Georgia", serif;
        border-radius: 8px;
        border: 1px solid #999;
        background: #f6f6f6;
        width: 70px;
        text-align: center;
    }

    /* Buttons */
    button {
        font-family: "Georgia", serif;
        cursor: pointer;
        transition: all 0.2s;
    }

    button[type="submit"] {
        background: #ffbfd0;
        color: #000;
        padding: 8px 16px;
        border-radius: 15px;
        font-weight: bold;
        font-size: 15px;
        border: 2px solid transparent;
    }

    button[type="submit"]:hover {
        background: #ff9fb7;
    }

    .remove-btn {
        background: #ff6b6b !important;
        color: white !important;
        padding: 8px 16px;
        border-radius: 15px;
        font-weight: bold;
        font-size: 15px;
        border: 2px solid transparent;
    }

    .remove-btn:hover {
        background: #ff5252 !important;
    }

    /* Total and checkout section */
    .cart-footer {
        margin-top: 30px;
        padding-top: 20px;
        border-top: 2px solid #333;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .total-price {
        font-size: 28px;
        font-weight: bold;
        color: #222;
    }

    .checkout-btn {
        background: #4CAF50 !important;
        color: white !important;
        padding: 14px 32px !important;
        border-radius: 25px !important;
        font-weight: bold !important;
        font-size: 18px !important;
        border: 2px solid #388E3C !important;
    }

    .checkout-btn:hover {
        background: #45a049 !important;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="cart-container">
    <h1>Your Shopping Cart</h1>
    <a href="<%= request.getContextPath() %>/services/" class="continue-shopping">← Continue Shopping</a>

    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String cls = "msg-success";
            switch (msg) {
                case "added":      text = "Item added to cart successfully!"; break;
                case "updated":    text = "Quantity updated successfully!"; break;
                case "removed":    text = "Item removed from cart."; break;
                case "invalid":    text = "Invalid request."; cls = "msg-error"; break;
                case "invalid_product": text = "Invalid product selected."; cls = "msg-error"; break;
                case "invalid_input": text = "Invalid input provided."; cls = "msg-error"; break;
                case "invalid_quantity": text = "Please enter a quantity between 1 and 99."; cls = "msg-error"; break;
                case "not_found":  text = "Item not found in your cart."; cls = "msg-error"; break;
                case "product_not_found": text = "Product not found or unavailable."; cls = "msg-error"; break;
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
            <div class="empty-cart">
                <h2>Your cart is empty</h2>
                <p>Add some items to get started!</p>
            </div>
    <%
        } else {
    %>
            <table>
                <thead>
                    <tr>
                        <th>Service</th>
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
                    int index = 0;
                    for (Cart.CartItem item : items) {
                %>
                    <tr>
                        <td><strong><%= item.getServiceName() %></strong></td>
                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/product/updateCartQuantity" method="post" style="margin:0; display:inline;">
                                <input type="hidden" name="itemIndex" value="<%= index %>">
                                <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" max="99">
                                <button type="submit">Update</button>
                            </form>
                        </td>
                        <td><strong>$<%= String.format("%.2f", item.getSubtotal()) %></strong></td>
                        <td><%= item.getCaregiverId() != null ? item.getCaregiverId() : "N/A" %></td>
                        <td><%= item.getClientId() != null ? item.getClientId() : "N/A" %></td>
                        <td><%= item.getSpecialRequests() != null && !item.getSpecialRequests().isEmpty() ? item.getSpecialRequests() : "None" %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/product/removeFromCart" method="post" style="margin:0; display:inline;">
                                <input type="hidden" name="itemIndex" value="<%= index %>">
                                <button type="submit" class="remove-btn" onclick="return confirm('Remove this item from cart?');">Remove</button>
                            </form>
                        </td>
                    </tr>
                <%
                        index++;
                    }
                %>
                </tbody>
            </table>

            <div class="cart-footer">
                <div class="total-price">
                    Total: $<%= String.format("%.2f", total != null ? total : 0.0) %>
                </div>
                <form action="<%= request.getContextPath() %>/product/checkout" method="post" style="margin:0;">
                    <button type="submit" class="checkout-btn">
                        Proceed to Checkout
                    </button>
                </form>
            </div>
    <%
        }
    %>
</div>

</body>
</html>