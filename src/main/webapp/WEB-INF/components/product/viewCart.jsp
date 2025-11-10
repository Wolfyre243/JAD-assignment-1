<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
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
    String message = request.getParameter("msg");
    if (message != null) {
        if (message.equals("updated")) {
    %>
        <p>Quantity updated successfully!</p>
    <% 
        } else if (message.equals("error")) {
    %>
        <p>Error updating quantity. Please try again.</p>
    <% 
        } else if (message.equals("invalid_quantity")) {
    %>
        <p>Invalid quantity. Please enter a number between 1 and 99.</p>
    <% 
        }
    }
    %>
    
    <%
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require",
            "neondb_owner",
            "npg_6dLgQzjR9OEa"
        );
        
        // Get cart items
        String sql = "SELECT ci.cart_item_id, ci.special_requests, ci.quantity, p.product_id, p.name, p.price, " +
                     "ci.caregiver_id, ci.client_id, c.cart_id " +
                     "FROM cart_item ci " +
                     "JOIN cart c ON ci.cart_id = c.cart_id " +
                     "JOIN product p ON ci.product_id = p.product_id " +
                     "WHERE c.user_id = ? AND c.checked_out = false " +
                     "ORDER BY ci.created_at";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        List<Map<String, Object>> items = new ArrayList<>();
        double total = 0;
        int cartId = 0;
        
        while (rs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("cartItemId", rs.getInt("cart_item_id"));
            item.put("productId", rs.getInt("product_id"));
            item.put("name", rs.getString("name"));
            item.put("price", rs.getDouble("price"));
            
            // Get quantity, default to 1 if null (for backwards compatibility)
            Integer quantity = (Integer) rs.getObject("quantity");
            if (quantity == null) {
                quantity = 1;
            }
            item.put("quantity", quantity);
            
            item.put("caregiverId", rs.getObject("caregiver_id"));
            item.put("clientId", rs.getObject("client_id"));
            item.put("specialRequests", rs.getString("special_requests"));
            items.add(item);
            total += rs.getDouble("price") * quantity;
            cartId = rs.getInt("cart_id");
        }
        
        if (items.isEmpty()) {
    %>
        <h2>Your cart is empty</h2>
        <p>Add some items to get started!</p>
    <%
        } else {
    %>
        <table border="1">
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
                Integer quantity = (Integer) item.get("quantity");
                Double price = (Double) item.get("price");
                double subtotal = price * quantity;
            %>
                <tr>
                    <td><%= item.get("name") %></td>
                    <td>$<%= String.format("%.2f", price) %></td>
                    <td>
                        <form action="updateCartQuantity.jsp" method="post" style="margin: 0;">
                            <input type="hidden" name="cartItemId" value="<%= item.get("cartItemId") %>">
                            <input type="number" name="quantity" value="<%= quantity %>" min="1" max="99" style="width: 60px;">
                            <button type="submit">Update</button>
                        </form>
                    </td>
                    <td>$<%= String.format("%.2f", subtotal) %></td>
                    <td><%= item.get("caregiverId") != null ? item.get("caregiverId") : "N/A" %></td>
                    <td><%= item.get("clientId") != null ? item.get("clientId") : "N/A" %></td>
                    <td><%= item.get("specialRequests") != null ? item.get("specialRequests") : "" %></td>
                    <td>
                        <a href="removeFromCart.jsp?cartItemId=<%= item.get("cartItemId") %>" 
                           onclick="return confirm('Remove this item?')">Remove</a>
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
        out.println("<p>Error loading cart: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>