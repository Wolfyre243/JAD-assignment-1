<!-- 
Page: /
 -->
 <%@ page language="java" contentType="text/html; charset=UTF-8"
		pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Landing Page</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background-color: #f5f5f5;
    }

    .hero {
        position: relative;
        width: 100%;
        height: 700px;
        background-image: url("https://www.thebestsingapore.com/wp-content/uploads/2023/04/Best-Elderly-Care-Singapore-Review.jpg");
        background-size: cover;
        background-position: center;
        filter: brightness(0.8);
        object-fit: cover;
    }

    .hero-overlay {
        position: absolute;
        top: 35%;
        left: 5%;
        background: rgba(255,255,255,0.7);
        padding: 40px;
        width: 300px;
        border-radius: 25px;
        text-align: left;
    }

    .hero-overlay h2 {
        font-size: 30px;
        font-weight: 600;
        margin-bottom: 15px;
    }

    .hero-overlay hr {
        border: none;
        border-top: 2px solid black;
        margin: 15px 0;
        width: 80%;
    }

    .hero-overlay .btn {
        display: inline-block;
        padding: 12px 25px;
        background: #ffbfd0;
        color: black;
        border-radius: 20px;
        text-decoration: none;
        font-size: 17px;
        font-weight: bold;
    }

    .about-section {
        background: #ffdce4;
        margin: 0;
        padding: 40px 20px;
        text-align: center;
        border-left: none;
        border-right: none;
    }

    .about-section h2 {
        font-size: 32px;
        margin-bottom: 10px;
        letter-spacing: 2px;
    }

    .about-section hr {
        width: 180px;
        margin: 10px auto 20px auto;
        border: none;
        border-top: 2px solid black;
    }

    .about-section p {
        font-size: 18px;
        width: 70%;
        margin: auto;
    }
    
    .about-section li {
        font-size: 18px;
        width: 70%;
        margin: auto;
        padding: auto; 
        text-align: left;
    }
</style>
</head>
<body>
	
	<%@ include file="/WEB-INF/components/common/header.jsp"%>

<!-- INCLUDE NAVBAR -->
<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>
<div>
    <h1>This is the landing page!</h1>
    <p class="muted">User ID <%= sessUserId %> &middot; Role <%= sessRoleId %></p>
</div>
<%@ include file="/WEB-INF/components/common/footer.jsp" %>
</body>



