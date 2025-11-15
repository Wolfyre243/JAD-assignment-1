<!--
Page: /auth/login
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%
// If user is logged in, redirect to landing page
if (sessUserId != null) {
	response.sendRedirect(request.getContextPath() + "/");
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login Page</title>
</head>
<body>
	<h1>Login Page</h1>
	<form action="${pageContext.request.contextPath}/user/dashboard/index.jsp"
		method="post">
		<label for="email">Email:</label> <input type="email" id="email"
			name="email" required> <br> <label for="password">Password:</label>
		<input type="password" id="password" name="password" required>
		<br>
		<button type="submit" value="Login">Login</button>
	</form>
	<br>
	<span>No Account? <a href='register.jsp'>Register</a> instead!</span>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>