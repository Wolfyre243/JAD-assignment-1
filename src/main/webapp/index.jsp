<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Landing Page</title>
</head>
<body>

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

<!-- INCLUDE NAVBAR -->
<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<!-- HERO SECTION -->
<div class="hero"></div>

<div class="hero-overlay">
    <h2>Where compassion<br>meets care.</h2>
    <hr>
    <a class="btn" href="#">Explore our services</a>
</div>

<!-- ABOUT US SECTION -->
<div class="about-section">
    <h2>About Us</h2>
    <hr>
    <p>
        We are a local care provider dedicated to enriching the lives of the elderly through personalized, reliable, and heartfelt support.
    </p>
    
    <h2>Our Misson</h2>
    <hr>
    <p>
        To bring comfort, independence, and peace of mind to every senior and family we serve
    </p>
    
    <h2>Why choose us?</h2>
    <hr>
		<ul>
		  <li>Trusted local caregivers with professional training and a personal touch</li>
		  <li>Flexible care options that adapt to changing needs</li>
		  <li>Transparent communication between caregivers, clients, and families</li>
		</ul>
</div>


</body>
</html>