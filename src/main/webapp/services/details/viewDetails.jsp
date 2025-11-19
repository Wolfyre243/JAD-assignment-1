<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%@ page import="models.Product" %>
<%@ page import="java.util.ArrayList" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Service Details</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .container {
        width: 90%;
        margin: 40px auto;
        display: flex;
        gap: 50px;
        align-items: flex-start;
    }
    
	.error {
	    margin: 20px auto;
	    width: fit-content;
	    padding: 14px 22px;
	    color: #555;                
	    font-size: 16px;
	    font-family: "Georgia", serif;
	    text-align: center;
	}


    .image-box {
        width: 50%;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 4px 18px rgba(0,0,0,0.1);
        border: 2px solid black;
    }

    .image-box img {
        width: 100%;
        height: 500px;
        object-fit: fill;
    }

    .info-box {
        width: 50%;
        padding-right: 20px;
    }

    .category {
        font-size: 20px;
        color: #666;
        font-style: italic;
        margin-bottom: 10px;
    }

    .title {
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .price {
        font-size: 28px;
        font-weight: bold;
        margin-bottom: 25px;
    }

    .section-title {
        font-size: 22px;
        margin-bottom: 10px;
    }

    .description {
        font-size: 18px;
        line-height: 1.5;
        margin-bottom: 35px;
        max-width: 600px;
    }

    .login-warning {
        padding: 15px;
        border: 2px solid red;
        background: #ffe5e5;
        color: red;
        width: fit-content;
        border-radius: 10px;
        margin-top: 20px;
        font-weight: bold;
    }

    .add-btn {
        background: #ff8aa1;
        padding: 14px 32px;
        border-radius: 25px;
        text-decoration: none;
        color: black;
        font-weight: bold;
        border: 2px solid black;
        font-size: 18px;
        display: inline-block;
        transition: 0.2s ease;
    }

    .add-btn:hover {
        transform: translateY(-2px);
    }
    
    .view-cart-btn {
        background: white;
        padding: 12px 28px;
        border-radius: 25px;
        text-decoration: none;
        color: black;
        font-weight: bold;
        border: 2px solid black;
        font-size: 16px;
        display: inline-block;
        margin-left: 15px;
        transition: 0.2s ease;
    }
    
    .view-cart-btn:hover {
        background: #f0f0f0;
        transform: translateY(-2px);
    }
</style>

</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<%
    // Image map
    java.util.HashMap<Integer, String> imageMap = new java.util.HashMap<>();

	imageMap.put(1, request.getContextPath() + "/images/personalCare.png");
	imageMap.put(2, request.getContextPath() + "/images/personalCare.png");
	imageMap.put(3, request.getContextPath() + "/images/medicalMonitoring.png");
	imageMap.put(4, request.getContextPath() + "/images/medication.png");
	imageMap.put(5, request.getContextPath() + "/images/companionship.png");
	imageMap.put(6, request.getContextPath() + "/images/companionship.png");
	imageMap.put(7, request.getContextPath() + "/images/housekeeping.png");
	imageMap.put(8, request.getContextPath() + "/images/mealPrep.png");
	imageMap.put(9, request.getContextPath() + "/images/transportMed.png");
	imageMap.put(10, request.getContextPath() + "/images/transportShop.png");

    String defaultImg = request.getContextPath() + "/images/default.png";

    // Load product from DB
    String idParam = request.getParameter("id");
    if (idParam == null) {
    %>
        <div class="error">No services available...</div>
   <%
        return;
    }

    int productId = Integer.parseInt(idParam);

    Product product = null;
    try { product = Product.getProductById(productId); }
    catch (Exception e) { e.printStackTrace(); }

    if (product == null) {
  	%>
        <div class="error">Service not found...</div>
   <%
        return;
    }
%>

<div class="container">

    <!-- LEFT: IMAGE -->
    <div class="image-box">
        <img src="<%= imageMap.getOrDefault(product.getProductId(), defaultImg) %>">
    </div>

    <!-- RIGHT: DETAILS -->
    <div class="info-box">
        <div class="title"><%= product.getName() %></div>
        <div class="price">$<%= product.getPrice() %></div>

        <div class="section-title">Description</div>
        <div class="description"><%= product.getDescription() %></div>

        <%
        // Check if user is logged in (access request attribute directly)
        Integer currentUserId = (Integer) request.getAttribute("sessUserId");
        Integer currentRoleId = (Integer) request.getAttribute("sessRoleId");
        
        if (currentUserId != null && currentRoleId != null && currentRoleId == 2) { 
        %>
            <!-- USER LOGGED IN & IS CLIENT → SHOW "ADD TO CART" -->
            <form action="<%=request.getContextPath()%>/product/addToCart" method="post">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px;">Caregiver ID (Optional):</label>
                    <input type="number" name="caregiverId" placeholder="Enter caregiver ID" 
                           style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 200px;">
                </div>
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px;">Client ID (Optional):</label>
                    <input type="number" name="clientId" placeholder="Enter client ID" 
                           style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 200px;">
                </div>
                
                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px;">Special Requests (Optional):</label>
                    <textarea name="specialRequests" placeholder="Any special requirements..." 
                              style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 100%; max-width: 500px; min-height: 80px; font-family: 'Georgia', serif;"></textarea>
                </div>
                
                <button type="submit" class="add-btn">Add To Cart</button>
                <a href="<%=request.getContextPath()%>/product/viewCart" class="view-cart-btn">View Cart</a>
            </form>
        
        <% } else { %>
        
            <!-- NOT LOGGED IN OR WRONG ROLE -->
            <div class="login-warning">
                <% if (currentUserId == null) { %>
                    Login as a client to add this service to your cart.
                <% } else if (currentRoleId != 2) { %>
                    Only clients can add services to cart.
                <% } %>
            </div>
        
        <% } %>


    </div>

</div>

</body>
</html>
