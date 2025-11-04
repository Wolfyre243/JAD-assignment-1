<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation</title>
</head>
<body>
    <h1>Order Confirmed!</h1>
    <p>Your order #<%= request.getParameter("orderId") %> has been successfully placed.</p>
    <p>Thank you for your purchase!</p>
    <br>
    <a href="products.jsp">Continue Shopping</a>
</body>
</html>