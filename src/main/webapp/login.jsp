<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Login Page</h1>
	<form action="/auth/login" method="post">
		<label for="email">Email:</label> 
		<input type="email" id="email"
			name="email" required> <br> 
		<label for="password">Password:</label>
		<input type="password" id="password" name="password" required>
		<br> 
		<button type="submit" value="Login">Login</button>
	</form>
	<br>
	<span>No Account? <a href='register.jsp'>Register</a> instead!</span>
</body>
</html>