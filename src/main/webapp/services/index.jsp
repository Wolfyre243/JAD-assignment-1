<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Product" %>
<%@ page import="models.Category" %>
<%@ page import="java.util.ArrayList" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Services</title>

<style>
    body {
        margin: 0;
        background: white;
        font-family: "Georgia", serif;
    }

    .top-controls {
        width: 90%;
        margin: 30px auto 10px auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .dropdown-box {
        display: flex;
        align-items: center;
        border: 2px solid black;
        border-radius: 30px;
        padding: 12px 20px;
        background: white;
        width: 280px;
    }

    .dropdown-box select {
        flex: 1;
        border: none;
        outline: none;
        font-size: 18px;
        font-family: "Georgia";
        background: transparent;
        cursor: pointer;
    }

    .cart-btn {
        background: #ffbfd0;
        text-decoration: none;
        width: 55px;
        height: 55px;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 26px;
        border: 2px solid black;
        cursor: pointer;
    }

    .grid {
        width: 90%;
        margin: 30px auto;
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 35px;
    }

    .card {
        background: #f6f6f6;
        border-radius: 30px;
        padding: 20px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        transition: 0.2s ease;
    }

    .card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 22px rgba(0,0,0,0.18);
    }

	.card-img {
	    width: 100%;
	    aspect-ratio: 1 / 1;    /* Makes the image frame square */
	    object-fit: fill;        /* Fills the entire frame */
	    border-radius: 20px;
	}


    .card-title {
        font-size: 20px;
        font-weight: bold;
        margin-bottom: 5px;
    }

    .card-subtitle {
        font-size: 16px;
        font-style: italic;
        color: #555;
        margin-bottom: 10px;
    }

	.details-btn {
	    background: black;
	    color: white;
	    padding: 8px 16px;
	    border-radius: 20px;
	    text-decoration: none;
	    font-size: 14px;
	    font-weight: bold;
	    display: inline-block; /* required so margin works */
	    margin-top: 12px;      /* <── adds space above the button */
	}
	
</style>

</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<%
    java.util.HashMap<Integer, String> imageMap = new java.util.HashMap<>();

	imageMap.put(1, request.getContextPath() + "/images/personalCare.png");       // Personal Care – 2H
	imageMap.put(2, request.getContextPath() + "/images/personalCare.png");       // Personal Care – 4H
	imageMap.put(3, request.getContextPath() + "/images/medicalMonitoring.png");  // Medical Monitoring – 4H
	imageMap.put(4, request.getContextPath() + "/images/medication.png");         // Medication Management
	imageMap.put(5, request.getContextPath() + "/images/companionship.png");      // Companionship – 2H
	imageMap.put(6, request.getContextPath() + "/images/companionship.png");      // Companionship – 4H
	imageMap.put(7, request.getContextPath() + "/images/housekeeping.png");       // Light Housekeeping
	imageMap.put(8, request.getContextPath() + "/images/mealPrep.png"); 
	imageMap.put(9, request.getContextPath() + "/images/transportMed.png"); 
	imageMap.put(10, request.getContextPath() + "/images/transportShop.png"); 

    String defaultImg = request.getContextPath() + "/images/default.png";
%>

<div class="top-controls">

    <form method="GET" action="<%= request.getContextPath() %>/services/" class="dropdown-box">
        <select name="category" onchange="this.form.submit()">
            <option value="">All Categories</option>

            <%
                ArrayList<Category> categories = Category.getAllCategories();
                for (Category c : categories) {
            %>
                <option value="<%= c.getCategoryId() %>"
                    <%= request.getParameter("category") != null &&
                        request.getParameter("category").equals(String.valueOf(c.getCategoryId()))
                        ? "selected" : "" %>>
                    <%= c.getName() %>
                </option>
            <%
                }
            %>

        </select>
    </form>

    <a href="<%= request.getContextPath() %>/product/viewCart" class="cart-btn">🛒</a>
</div>

<%
    String categoryParam = request.getParameter("category");
    ArrayList<Product> products = null;

    if (categoryParam != null && !categoryParam.isEmpty()) {
        int catId = Integer.parseInt(categoryParam);
        products = Product.getAllProductsByCategory(catId);
    } else {
        products = Product.getAllProducts();
    }
%>

<div class="grid">

<%
    for (Product p : products) {
%>

    <div class="card">

        <img src="<%= imageMap.getOrDefault(p.getProductId(), defaultImg) %>" 
             class="card-img">

        <div class="card-title"><%= p.getName() %></div>
        <div class="card-subtitle"><%= p.getCategory().getName() %></div>

        <a class="details-btn"
           href="<%= request.getContextPath() %>/services/details/viewDetails.jsp?id=<%= p.getProductId() %>">
            View Details
        </a>
    </div>

<%
    }
%>

</div>

</body>
</html>
