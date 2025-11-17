<!-- 
Page: /
 -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Landing Page</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
	<%@ page language="java" contentType="text/html; charset=UTF-8"
		pageEncoding="UTF-8"%>
	<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
	<%@ include file="/WEB-INF/components/common/header.jsp"%>

	<h1 class="text-2xl font-semibold">This is the landing page!</h1>
	<p class="muted">
		User ID
		<%=sessUserId%>
		&middot; Role
		<%=sessRoleId%></p>

	<%@ include file="/WEB-INF/components/common/footer.jsp"%>
</body>