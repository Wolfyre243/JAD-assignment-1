<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Navigation Bar</title>
</head>
<body>

<style>
    .navbar {
        width: 100%;
        background: #ffdce4;
        padding: 18px 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-sizing: border-box;
        font-family: "Georgia", serif;
        border-bottom: 2px solid #000000;
    }

    /* Logo + Links Group */
    .nav-left {
        display: flex;
        align-items: center;
        gap: 25px; /* controls spacing between SilverCare and links */
    }

    .nav-left .brand {
        font-size: 32px;
        font-style: italic;
        font-weight: 500;
    }

    .nav-left a {
        text-decoration: none;
        color: black;
        font-size: 18px;
        margin: 0;
    }

    .nav-right a {
        padding: 8px 20px;
        margin-left: 10px;
        text-decoration: none;
        color: black;
        background: #ffe0e8;
        border-radius: 20px;
        font-size: 17px;
        font-weight: 600;
    }

    .nav-right a.login {
        background: #ffbfd0;
    }
</style>

<div class="navbar">

    <!-- LEFT SIDE: SilverCare + Services + Feedback (all together now) -->
    <div class="nav-left">
        <a href="<%= request.getContextPath() %>/" class="brand">SilverCare</a>
        <a href="#">Services</a>
        <a href="<%= request.getContextPath() %>/user/reviews">Feedback</a>
    </div>

    <div class="nav-right">
        <% if (sessUserId == null) { %>

            <!-- NOT LOGGED IN -->
            <a href="<%= request.getContextPath() %>/auth/register/" class="register">Register</a>
            <a href="<%= request.getContextPath() %>/auth/login/" class="login">Login</a>

        <% } else { %>

            <!-- LOGGED IN -->
            <jsp:include page="/WEB-INF/components/auth/logout-button.jsp" />

        <% } %>
    </div>
</div>

</body>
</html>