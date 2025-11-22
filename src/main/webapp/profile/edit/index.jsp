<%@page import="models.Client"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="models.User"%>
<%@ include file="/WEB-INF/components/auth/require-login.jsp"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Profile | SilverCare</title>
<link rel="stylesheet"
	href="index.css">
 <style>

</style>
</head>
<body>

	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<%
	Client client = Client.getClientByUserId(sessUserId);
	if (client == null) {
	  response.sendRedirect(request.getContextPath() + "/profile/create");
	  return;
	}
	%>

	<div class="container">
		<div class="form-wrapper">
			<h2>Edit Your Profile</h2>
			<p class="subtitle">Update your personal details below.</p>

			<form action="<%=request.getContextPath()%>/profile/edit"
				method="post" class="profile-form">

				<input type="hidden" name="clientId"
					value="<%=client.getClientId()%>">

				<div class="form-group">
					<label for="firstName">First Name <span class="required">*</span></label>
					<input type="text" id="firstName" name="firstName" required
						value="<%=client.getFirstName() != null ? client.getFirstName() : ""%>"
						placeholder="John">
				</div>

				<div class="form-group">
					<label for="lastName">Last Name <span class="required">*</span></label>
					<input type="text" id="lastName" name="lastName" required
						value="<%=client.getLastName() != null ? client.getLastName() : ""%>"
						placeholder="Doe">
				</div>

				<div class="form-group">
					<label for="dob">Date of Birth <span class="required">*</span></label>
					<input type="date" id="dob" name="dob" required
						value="<%=client.getDob() != null ? client.getDob().toString() : ""%>"
						max="<%=java.time.LocalDate.now()%>">
				</div>

				<div class="form-group">
					<label for="gender">Gender <span class="required">*</span></label>
					<select id="gender" name="gender" required>
						<option value="" disabled>Select gender</option>
						<option value="M"
							<%="M".equals(client.getGender()) ? "selected" : ""%>>Male</option>
						<option value="F"
							<%="F".equals(client.getGender()) ? "selected" : ""%>>Female</option>
					</select>
				</div>

				<div class="form-group">
					<label for="nric">NRIC / FIN <span class="required">*</span></label>
					<input type="text" id="nric" name="nric" required
						pattern="[STFGstfg]\d{7}[A-Za-z]" title="e.g. S1234567A"
						value="<%=client.getNric() != null ? client.getNric() : ""%>"
						placeholder="S1234567A" maxlength="9">
				</div>

				<div class="form-group">
					<label for="phone">Phone Number <span class="required">*</span></label>
					<input type="tel" id="phone" name="phone" required
						pattern="[0-9]{8}" maxlength="8"
						value="<%=client.getPhone() != null ? client.getPhone() : ""%>"
						placeholder="91234567">
				</div>

				<div class="form-group">
					<label for="email">Email Address <span class="required">*</span></label>
					<input type="email" id="email" name="email" required
						value="<%=client.getEmail() != null ? client.getEmail() : ""%>"
						placeholder="john@example.com">
				</div>

				<div class="form-actions">
					<button type="submit" class="btn-primary">Update Profile</button>
					<a href="<%=request.getContextPath()%>/profile/" class="btn-cancel">Cancel</a>
				</div>
			</form>
		</div>
	</div>
</body>
</html>