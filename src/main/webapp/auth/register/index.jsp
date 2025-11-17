<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register | SilverCare</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: #ffffff;
    }

    /* Background image (bright, cheerful) */
    .bg-photo {
        width: 100%;
        height: 100vh;
        background-image: url("https://www.thebestsingapore.com/wp-content/uploads/2023/04/Best-Elderly-Care-Singapore-Review.jpg");
        background-size: cover;
        background-position: center;
        position: fixed;
        z-index: -1;
        filter: brightness(0.92);
    }

    /* Pink rounded center card (same as login) */
    .register-card {
        width: 550px;
        margin: 120px auto;
        background: #ffdce4;
        padding: 40px 50px;
        border-radius: 40px;
        text-align: center;
        box-shadow: 0px 4px 18px rgba(0,0,0,0.25);
    }

    .register-card h1 {
        font-size: 36px;
        margin-bottom: 30px;
        font-weight: bold;
    }

    label {
        display: block;
        font-size: 20px;
        font-weight: 600;
        text-align: left;
        margin-bottom: 8px;
    }

    input, select {
        width: 100%;
        padding: 12px 15px;
        border-radius: 20px;
        border: 1px solid #999;
        background: #f6f6f6;
        margin-bottom: 25px;
        font-size: 18px;
        font-family: Georgia;
    }

    .checkbox-row {
        display: flex;
        align-items: center;
        font-size: 17px;
        margin-top: -10px;
        margin-bottom: 20px;
    }

    .checkbox-row input {
        width: auto;
        margin-right: 10px;
        transform: scale(1.2);
    }

    .register-btn {
        background: #ffbfd0;
        padding: 12px 30px;
        border-radius: 25px;
        font-size: 20px;
        font-weight: bold;
        border: none;
        cursor: pointer;
    }

    .register-btn:hover {
        background: #ff9fb7;
    }

    .login-line {
        margin-top: 20px;
        font-size: 18px;
    }

    .login-line a {
        font-weight: bold;
        color: #b3003b;
        text-decoration: none;
    }
</style>

</head>

<body>

<div class="bg-photo"></div>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<%
    // Redirect logged-in users
    if (sessUserId != null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
%>

<div class="register-card">

    <h1>Create Account</h1>

    <form action="<%= request.getContextPath() %>/auth/register" method="post">

        <label>Email</label>
        <input type="email" name="email" required maxlength="255">

        <label>Password</label>
        <input type="password" name="password" required>

        <label>I am:</label>
        <select name="roleId" required>
            <option value="">-- Select --</option>
            <option value="2">A client</option>
            <option value="3">A guardian</option>
        </select>

        <div class="checkbox-row">
            <label><input type="checkbox" name="terms" required>I agree to the Terms and Conditions</label>
        </div>

        <button type="submit" class="register-btn">Register</button>
    </form>

    <div class="login-line">
        Already have an account?
        <a href="<%= request.getContextPath() %>/auth/login/">Login</a>
    </div>

</div>

</body>
</html>
