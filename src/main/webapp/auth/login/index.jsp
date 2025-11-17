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
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="flex flex-col w-full h-screen justify-center items-center p-4">
	<div>
		<h1 class="text-3xl font-semibold mb-4">Login Page</h1>
		<form action="${pageContext.request.contextPath}/auth/login"
			method="post" class="flex flex-col gap-2 w-sm">
			<label for="email">Email:</label> <input type="email" id="email"
				name="email" required class="border rounded-md"> <label
				for="password">Password:</label> <input type="password"
				id="password" name="password" class="border rounded-md" required>
			<button type="submit" value="Login" class="px-2 py-1 bg-blue-300 w-fit rounded-md cursor-pointer">Login</button>
		</form>
		<br> <span>No Account? <a href='register.jsp' class="underline">Register</a>
			instead!
		</span>
	</div>

	<%@ include file="/WEB-INF/components/common/footer.jsp"%>
</body>