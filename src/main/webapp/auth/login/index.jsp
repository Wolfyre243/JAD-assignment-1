<%--
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Login Page
--%>

<!--
Page: /auth/login
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login | SilverCare</title>

<style>
body {
	margin: 0;
	font-family: "Georgia", serif;
	background: #ffffff;
}

/* Background image (no dark overlay) */
.bg-photo {
	width: 100%;
	height: 100vh;
	background-image:
		url("https://koala.sh/api/image/v2-5ssqc-kzclq.jpg?width=1344&height=768&dream");
	background-size: cover;
	object-fit: fill;
	background-position: center;
	position: fixed;
	z-index: -1;
	filter: brightness(0.92); /* brighter, happier */
}

/* Center login card */
.login-card {
	width: 550px;
	margin: 120px auto;
	background: #ffdce4;
	padding: 40px 50px;
	border-radius: 40px;
	text-align: center;
	box-shadow: 0px 4px 18px rgba(0, 0, 0, 0.25);
}

.login-card h1 {
	font-size: 36px;
	margin-bottom: 30px;
	font-weight: bold;
}

label {
	display: block;
	font-size: 20px;
	font-weight: 600;
	margin-bottom: 6px;
	text-align: left;
}

input {
	width: 100%;
	padding: 12px;
	font-size: 18px;
	font-family: Georgia;
	margin-bottom: 25px;
	border-radius: 20px;
	border: 1px solid #999;
	background: #f6f6f6;
}

.login-btn {
	background: #ffbfd0;
	padding: 12px 30px;
	border-radius: 25px;
	font-size: 20px;
	font-weight: bold;
	border: none;
	cursor: pointer;
	margin-top: 10px;
}

.login-btn:hover {
	background: #ff9fb7;
}

.register-line {
	margin-top: 20px;
	font-size: 18px;
}

.register-line a {
	font-weight: bold;
	color: #b3003b;
	text-decoration: none;
}
</style>
</head>

<body>

	<div class="bg-photo"></div>

	<%@ include file="/WEB-INF/components/user/userNavBar.jsp"%>

	<%
	// Redirect logged-in users
	if (request.getAttribute("sessUserId") != null) {
	  response.sendRedirect(request.getContextPath() + "/");
	  return;
	}
	%>

	<div class="login-card">
		<h1>Login</h1>

		<form action="<%=request.getContextPath()%>/auth/login"
			method="post">

			<label>Email</label> <input type="email" name="email" required>

			<label>Password</label> <input type="password" name="password"
				required>

			<button type="submit" class="login-btn">Login</button>
		</form>

		<div class="register-line">
			No account? <a href="<%=request.getContextPath()%>/auth/register/">Register</a>
		</div>
	</div>

</body>
</html>
