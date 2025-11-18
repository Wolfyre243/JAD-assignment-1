<%@page import="models.Client"%>
<%@page import="models.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/require-login.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Profile | Silver Care</title>
<link rel="stylesheet" href="index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>
	<div class="profile-container">
		<!-- Header -->
		<div class="profile-header">
			<h1>Welcome back, ${sessionScope.client.name}!</h1>
			<p>Your personal profile</p>
		</div>

		<!-- Body -->
		<div class="profile-body">

			<!-- Personal Information -->
			<div class="profile-section">
				<h2>Personal Information</h2>
				<dl class="info-grid">
					<%-- CLIENT Only for clients --%>
					<%
					if (sessRoleId == 2) {
						final Client clientData = Client.getClientByUserId(sessUserId);
					%>
					<dt>Full Name</dt>
					<dd>
						<%=clientData.getFullName()%>
					</dd>

					<dt>Email</dt>
					<dd>
						<%=clientData.getEmail()%>
					</dd>

					<dt>Phone</dt>
					<dd>
						<%=clientData.getPhone()%>
					</dd>

					<dt>Address</dt>
					<dd>${sessionScope.client.address}
						<%-- PLACEHOLDER: Replace with actual address --%>
					</dd>

					<dt>NRIC</dt>
					<dd>
						<%=clientData.getNric()%>
					</dd>

					<dt>Date of Birth</dt>
					<dd>
						<%-- TODO: Format --%>
						<%=clientData.getDob()%>
					</dd>

					<dt>Gender</dt>
					<dd>
						<%=clientData.getGender()%>
					</dd>

					<dt>Member Since</dt>
					<dd>
						<%=clientData.getCreatedAt()%>
					</dd>
					<%
					} else {
					final User userData = User.getUserById(sessUserId);
					%>
					<dt>Email</dt>
					<dd>
						<%=userData.getEmail()%>
					</dd>
					<%
					}
					%>
				</dl>

				<div style="text-align: center; margin-top: 25px;">
					<a href="./edit/" class="btn-edit">Edit Profile</a>
				</div>
			</div>

			<!-- Optional: Future sections (e.g., Upcoming Bookings, Past Feedback) -->
			<!-- You can add more .profile-section blocks here later -->
		</div>
	</div>
</body>
</html>