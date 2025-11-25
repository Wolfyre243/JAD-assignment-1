<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%--
  Author: Lim Song Chern Jayden
  Admin No: P2424093
  Class: DIT-2B-01
  Last Edited: 23/11/2025
  Description: Client side NavBar on all client pages
--%>
<%
final Integer sessUserId = (Integer) session.getAttribute("userId");
final Integer sessRoleId = (Integer) session.getAttribute("userRoleId");
%>
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

.nav-right div {
	display: flex;
	flex-direction: row;
	align-items: center;
	gap: 12px;
}
</style>
  
	<div class="navbar">
		<!-- LEFT SIDE -->
		<div class="nav-left">
			<a href="<%= request.getContextPath() %>/" class="brand">SilverCare</a>
			<a href="<%= request.getContextPath() %>/services/">Services</a> 
			<a href="<%= request.getContextPath() %>/reviews">Feedback</a>
			<% if (sessUserId != null) { %>
				<a href="<%= request.getContextPath() %>/user/orders">Orders</a>
			<% } %>
			<% if (sessUserId != null && sessRoleId != null) { %>
				<% if (sessRoleId == 1) { %>
					<a href="<%=request.getContextPath()%>/admin/dashboard">Admin Dashboard</a>
				<% } else if (sessRoleId == 3) { %>
					<a href="<%=request.getContextPath()%>/family/">Family</a>
				<% } %>
			<% } %>
		</div>

		<div class="nav-right">
			<%
			// Access request attribute directly to avoid duplicate variable declaration
			if (request.getAttribute("sessUserId") == null) {
			%>

			<!-- NOT LOGGED IN -->
			<a href="<%=request.getContextPath()%>/auth/register/"
				class="register">Register</a> <a
				href="<%=request.getContextPath()%>/auth/login/" class="login">Login</a>

			<%
			} else {
			%>

			<!-- LOGGED IN -->
			<div>
				<jsp:include page="/WEB-INF/components/auth/logout-button.jsp" />
				<jsp:include page="/WEB-INF/components/user/profile-dropdown.jsp" />
			</div>
			<%
			}
			%>
		</div>
	</div>

</body>
</html>