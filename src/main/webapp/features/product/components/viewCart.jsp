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
        String sql = "SELECT ci.cart_item_id, ci.special_requests, p.product_id, p.name, p.price, " +
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
            item.put("caregiverId", rs.getObject("caregiver_id"));
            item.put("clientId", rs.getObject("client_id"));
            item.put("specialRequests", rs.getString("special_requests"));
            items.add(item);
            total += rs.getDouble("price");
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
                    <th>Caregiver ID</th>
                    <th>Client ID</th>
                    <th>Special Requests</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
            for (Map<String, Object> item : items) {
            %>
                <tr>
                    <td><%= item.get("name") %></td>
                    <td>$<%= String.format("%.2f", (Double)item.get("price")) %></td>
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