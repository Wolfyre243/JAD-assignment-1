<%@page import="models.Client"%>
<%@page import="models.Family"%>
<%@page import="models.FamilyMember"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/protected-guardian.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Family | SilverCare</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/family/index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="dashboard-container">
		<%
		String success = (String) request.getAttribute("success");
		String error = (String) request.getAttribute("error");
		if (success != null) {
		%>
		<div class="alert alert-success"><%=success%></div>
		<%
		} else if (error != null) {
		%>
		<div class="alert alert-error"><%=error%></div>
		<%
		}
		%>

		<h1>Your Family</h1>
		<hr>

		<%
		final Family userFamily = Family.getUserFamily(sessUserId);
		if (userFamily == null || userFamily.getMembers().isEmpty()) {
		%>
		<p class="no-family">No family members added yet. Add your loved
			ones below.</p>
		<%
		} else {
		ArrayList<FamilyMember> familyList = userFamily.getMembers();
		%>
		<table>
			<thead>
				<tr>
					<th>Name</th>
					<th>Relationship</th>
					<th>Age</th>
					<th>NRIC</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>
				<%
				for (FamilyMember member : familyList) {
					Client clientData = Client.getClientById(member.getClientId());
					if (clientData != null) {
				%>
				<tr>
					<td><%=clientData.getFullName()%></td>
					<td><%=member.getRelationship()%></td>
					<td><%=clientData.getAge()%></td>
					<td><%=clientData.getNric()%></td>
					<td class="action-buttons"><a
						href="${pageContext.request.contextPath}/family/member?cid=<%= clientData.getClientId() %>"
						class="btn btn-view">View</a>

						<form action="${pageContext.request.contextPath}/family/remove"
							method="post" style="display: inline;"
							onsubmit="return confirm('Remove <%= clientData.getFullName() %> from your family? This cannot be undone.');">
							<input type="hidden" name="cid"
								value="<%=clientData.getClientId()%>">
							<button type="submit" class="btn btn-danger">Delete</button>
						</form></td>
				</tr>
				<%
				}
				}
				%>
			</tbody>
		</table>
		<%
		}
		%>
	</div>

	<div class="add-member-section">
		<h2>Add Family Member</h2>
		<hr>

		<form action="${pageContext.request.contextPath}/family/add"
			method="post">
			<div class="form-grid">
				<div class="form-group">
					<label>First Name <span class="required">*</span></label> <input
						type="text" name="firstName" required placeholder="e.g. Mei Ling">
				</div>
				<div class="form-group">
					<label>Last Name <span class="required">*</span></label> <input
						type="text" name="lastName" required placeholder="e.g. Tan">
				</div>
				<div class="form-group">
					<label>Date of Birth <span class="required">*</span></label> <input
						type="date" name="dob" required>
				</div>
				<div class="form-group">
					<label>NRIC / Passport <span class="required">*</span></label> <input
						type="text" name="nric" required placeholder="e.g. S1234567A"
						maxlength="20">
				</div>

				<div class="form-group full-width">
					<label>Gender <span class="required">*</span></label>
					<div class="gender-group">
						<label><input type="radio" name="gender" value="M"
							required> Male</label> <label><input type="radio"
							name="gender" value="F"> Female</label>
					</div>
				</div>

				<div class="form-group">
					<label>Phone Number <span class="required">*</span></label> <input
						type="tel" name="phone" required placeholder="e.g. 9123 4567">
				</div>
				<div class="form-group">
					<label>Email Address</label> <input type="email" name="email"
						placeholder="e.g. meiling@example.com">
				</div>
				<div class="form-group full-width">
					<label>Relationship to You <span class="required">*</span></label>
					<input type="text" name="relationship" required
						placeholder="e.g. Mother, Grandfather">
				</div>
			</div>

			<button type="submit" class="submit-btn">Add Family Member</button>
		</form>
	</div>
</body>
</html>