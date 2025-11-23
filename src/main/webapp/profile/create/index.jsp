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
<title>Complete Your Profile | SilverCare</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/profile/create/index.css">
</head>
<body>
	<%
	// Verify if user already has a client profile
	Client client = Client.getClientByUserId(sessUserId);
	if (client != null) {
	  response.sendRedirect(request.getContextPath() + "/profile/");
	  return;
	}
	%>

	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="container">
		<div class="form-wrapper">
			<h2>Complete Your Profile</h2>
			<p class="subtitle">Please fill in your personal details to
				continue using our services.</p>

			<form
				action="<%=request.getContextPath()%>/profile/create"
				method="post" class="profile-form">

				<div class="form-group">
					<label for="firstName">First Name <span class="required">*</span></label>
					<input type="text" id="firstName" name="firstName" required
						placeholder="John">
				</div>

				<div class="form-group">
					<label for="lastName">Last Name <span class="required">*</span></label>
					<input type="text" id="lastName" name="lastName" required
						placeholder="Doe">
				</div>

				<div class="form-group">
					<label for="dob">Date of Birth <span class="required">*</span></label>
					<input type="date" id="dob" name="dob" required
						max="<%=java.time.LocalDate.now()%>">
				</div>

				<div class="form-group">
					<label for="gender">Gender <span class="required">*</span></label>
					<select id="gender" name="gender" required>
						<option value="" disabled selected>Select gender</option>
						<option value="M">Male</option>
						<option value="F">Female</option>
					</select>
				</div>

				<div class="form-group">
					<label for="nric">NRIC / FIN <span class="required">*</span></label>
					<input type="text" id="nric" name="nric" required
						pattern="[STFG]\d{7}[A-Z]" title="e.g. S1234567A"
						placeholder="S1234567A" maxlength="9">
				</div>

				<div class="form-group">
					<label for="phone">Phone Number <span class="required">*</span></label>
					<input type="tel" id="phone" name="phone" required
						pattern="[0-9]{8}" placeholder="91234567" maxlength="8">
				</div>

				<div class="form-group">
					<label for="email">Email Address <span class="required">*</span></label>
					<input type="email" id="email" name="email" required
						placeholder="john@example.com">
				</div>

				<div class="form-actions">
					<button type="submit" class="btn-primary">Save Profile &
						Continue</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>