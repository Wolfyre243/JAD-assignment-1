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
			<a href="adminDashboard.jsp"
				class="<%=request.getRequestURI().endsWith("adminDashboard.jsp") && request.getParameter("page") == null ? "active" : ""%>">Dashboard</a>
			<a href="adminDashboard.jsp?page=users"
				class="<%="users".equals(request.getParameter("page")) ? "active" : ""%>">User
				Management</a> <a href="adminDashboard.jsp?page=orders"
				class="<%="orders".equals(request.getParameter("page")) ? "active" : ""%>">Order
				Management</a> <a href="adminDashboard.jsp?page=services"
				class="<%="services".equals(request.getParameter("page")) ? "active" : ""%>">Services
				Management</a> <a href="adminDashboard.jsp?page=feedback"
				class="<%="feedback".equals(request.getParameter("page")) ? "active" : ""%>">Feedback
				Management</a>
			<div class="logout">
				<a href="${pageContext.request.contextPath}/auth/logout">Logout</a>
			</div>
		</div>

		<!-- Main Content -->
		<div class="content">
			<%
			String pageParam = request.getParameter("page");
			String includeFile = "/WEB-INF/components/admin/adminDashboard.jsp"; // default - FULL PATH

			if ("users".equals(pageParam)) {
			  includeFile = "/WEB-INF/components/admin/adminUsers.jsp";
			} else if ("orders".equals(pageParam)) {
			  includeFile = "/WEB-INF/components/admin/adminOrders.jsp";
			} else if ("services".equals(pageParam)) {
			  includeFile = "/WEB-INF/components/admin/adminServices.jsp";
			} else if ("feedback".equals(pageParam)) {
			  includeFile = "/WEB-INF/components/admin/adminFeedback.jsp";
			} else if ("orderDetails".equals(pageParam)) {
			  String orderId = request.getParameter("orderId");
			  if (orderId != null && orderId.matches("\\d+")) {
			    // Set orderId as request attribute so the included page can access it
			    request.setAttribute("orderId", orderId);
			    includeFile = "/WEB-INF/components/admin/adminOrderDetails.jsp";
			  } else {
			    includeFile = "/WEB-INF/components/admin/adminOrders.jsp";
			  }
			}
			%>

			<jsp:include page="<%=includeFile%>" />
		</div>
	</div>
</body>
</html>