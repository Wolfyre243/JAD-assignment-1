<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/protected.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<style>
body {
	font-family: 'Segoe UI', sans-serif;
	margin: 0;
	background: #f5f6fa;
}

.container {
	display: flex;
	min-height: 100vh;
}

.sidebar {
	width: 260px;
	background: #2c3e50;
	color: white;
	padding: 25px 20px;
	box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
}

.sidebar h2 {
	margin: 0 0 30px 0;
	font-size: 24px;
	color: #1abc9c;
}

.sidebar a {
	display: block;
	padding: 14px 20px;
	color: #ecf0f1;
	text-decoration: none;
	border-radius: 8px;
	margin: 6px 0;
	transition: all 0.3s;
	font-weight: 500;
}

.sidebar a:hover {
	background: #34495e;
	transform: translateX(5px);
}

.sidebar a.active {
	background: #1abc9c;
	font-weight: bold;
}

.content {
	flex: 1;
	padding: 30px;
	background: white;
}

.logout {
	margin-top: 60px;
	border-top: 1px solid #34495e;
	padding-top: 20px;
}

.logout a {
	background: #e74c3c !important;
}

.logout a:hover {
	background: #c0392b !important;
}

h1 {
	color: #2c3e50;
	margin-top: 0;
}
</style>
</head>
<body>
	<div class="container">
		<!-- Sidebar -->
		<div class="sidebar">
			<h2>Admin Panel</h2>
			<a href="${pageContext.request.contextPath}/admin/dashboard"
				class="${requestScope.activePage == 'dashboard' ? 'active' : ''}">Dashboard</a>
			<a href="${pageContext.request.contextPath}/admin/users"
				class="${requestScope.activePage == 'users' ? 'active' : ''}">User Management</a>
			<a href="${pageContext.request.contextPath}/admin/orders"
				class="${requestScope.activePage == 'orders' ? 'active' : ''}">Order Management</a>
			<a href="${pageContext.request.contextPath}/admin/services"
				class="${requestScope.activePage == 'services' ? 'active' : ''}">Services Management</a>
			<a href="${pageContext.request.contextPath}/admin/feedback"
				class="${requestScope.activePage == 'feedback' ? 'active' : ''}">Feedback Management</a>

			<div class="logout">
				<a href="${pageContext.request.contextPath}/auth/logout">Logout</a>
			</div>
		</div>

		<!-- Main Content -->
		<div class="content">
			<jsp:include page="${requestScope.includeFile}" />
		</div>
	</div>
</body>
</html>
