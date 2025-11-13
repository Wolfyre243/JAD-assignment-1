<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
    }

    .nav-left {
        font-size: 32px;
        font-style: italic;
        font-weight: 500;
    }

    .nav-center a, .nav-left a {
        margin: 0 20px;
        text-decoration: none;
        color: black;
        font-size: 18px;
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
    <div class="nav-left">SilverCare</div>

    <div class="nav-left">
        <a href="#">Services</a>
        <a href="#">Feedback</a>
    </div>

    <div class="nav-right">
        <a href="#">Register</a>
        <a href="#" class="login">Login</a>
    </div>
</div>

</body>
</html>