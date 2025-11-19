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
<link rel="stylesheet" href="index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="dashboard-container">
		<h1>Your Family</h1>
		<hr>

		<!-- Family Members List -->
		<%
		final Family userFamily = Family.getUserFamily(sessUserId);
		if (userFamily == null) {
		%>
		<p class="no-family">No family members added yet. Add your loved
			ones below.</p>
		<%
		} else {
		  final ArrayList<FamilyMember> familyList = userFamily.getMembers();
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
					final Client clientData = Client.getClientById(member.getClientId());
				%>
				<tr>
					<td><%=clientData.getFullName()%></td>
					<td><%=member.getRelationship()%></td>
					<td><%=clientData.getAge()%></td>
					<td><%=clientData.getNric()%></td>
					<td><a href="<%=request.getContextPath()%>/family/member?cid=<%=clientData.getClientId() %>" class="btn"
						style="padding: 8px 15px; margin-right: 4px; font-size: 14px;">View</a><a
						href="EditFamilyMemberServlet?id=1" class="btn"
						style="padding: 8px 15px; font-size: 14px;">Edit</a> <a
						href="DeleteFamilyMemberServlet?id=1" class="btn btn-danger"
						style="padding: 8px 15px; font-size: 14px;"
						onclick="return confirm('Are you sure you want to remove <%=clientData.getFullName()%>?')">Delete</a>
					</td>
				</tr>
				<%
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

		<form action="AddFamilyMemberServlet" method="post">
			<div class="form-grid">
				<div class="form-group">
					<label>First Name</label> <input type="text" name="firstName"
						required placeholder="e.g. Mei Ling">
				</div>

				<div class="form-group">
					<label>Last Name</label> <input type="text" name="lastName"
						required placeholder="e.g. Tan">
				</div>

				<div class="form-group">
					<label>Date of Birth</label> <input type="date" name="dob" required>
				</div>

				<div class="form-group">
					<label>NRIC / Passport</label> <input type="text" name="nric"
						required placeholder="e.g. S1234567A">
				</div>

				<div class="form-group full-width">
					<label>Gender</label>
					<div class="gender-group">
						<label><input type="radio" name="gender" value="M"
							required> Male</label> <label><input type="radio"
							name="gender" value="F"> Female</label>
					</div>
				</div>

				<div class="form-group">
					<label>Phone Number</label> <input type="tel" name="phone" required
						placeholder="e.g. 9123 4567">
				</div>

				<div class="form-group">
					<label>Email Address</label> <input type="email" name="email"
						required placeholder="e.g. meiling@example.com">
				</div>

				<div class="form-group full-width">
					<label>Relationship to You</label> <input type="text"
						name="relationship" required
						placeholder="e.g. Mother, Grandfather, Spouse">
				</div>

			</div>

			<button type="submit" class="submit-btn">Add Family Member</button>
		</form>
	</div>
</body>
</html>