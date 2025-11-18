<%@page import="models.User"%>
<%@page import="models.MedicalProfile"%>
<%@page import="org.apache.openejb.client.ClientDataSource"%>
<%@page import="models.EmergencyContact"%>
<%@page import="java.util.ArrayList"%>
<%@page import="models.Client"%>
<%@page import="java.text.SimpleDateFormat"%>
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
			<h1>Your Profile</h1>
		</div>

		<!-- Body -->
		<div class="profile-body">

			<!-- Personal Information -->
			<div class="profile-section">
				<h2>Personal Information</h2>
				<dl class="info-grid">
					<%
					if (sessRoleId == 2) {
						Client client = Client.getClientByUserId(sessUserId);
					%>
					<dt>Full Name</dt>
					<dd><%=client.getFullName()%></dd>
					<dt>Email</dt>
					<dd><%=client.getEmail()%></dd>
					<dt>Phone</dt>
					<dd><%=client.getPhone()%></dd>
					<%--
					<dt>Address</dt>
					<dd><%=client.getAddress() != null ? client.getAddress() : "Not set"%></dd>
					 --%>
					<dt>NRIC</dt>
					<dd><%=client.getNric()%></dd>
					<dt>Date of Birth</dt>
					<dd><%=client.getDob()%></dd>
					<dt>Gender</dt>
					<dd><%=client.getGender()%></dd>
					<dt>Member Since</dt>
					<dd><%=client.getCreatedAt()%></dd>
					<%
					} else {
					final User userData = User.getUserById(sessUserId);
					%>
					<dt>Email</dt>
					<dd><%=userData.getEmail()%></dd>
					<dt>Account Created</dt>
					<dd><%=userData.getCreatedAt()%></dd>
					<%
					}
					%>
				</dl>

				<div style="text-align: center; margin-top: 25px;">
					<a href="./edit/" class="btn-edit">Edit Profile</a>
				</div>
			</div>

			<%
			if (sessRoleId == 2) {
				Client client = Client.getClientByUserId(sessUserId);
			%>
			<div class="profile-grid">
				<!-- Emergency Contacts -->
				<div class="profile-section emergency-contact">
					<h3>Emergency Contacts</h3>

					<%
					final ArrayList<EmergencyContact> contacts = client.getEmergencyContacts();
					if (contacts != null && !contacts.isEmpty()) {
						for (EmergencyContact contact : contacts) {
					%>
					<div class="contact-item">
						<strong><%=contact.getName()%></strong>
						<%
						if (contact.getRelationship() != null && !contact.getRelationship().isEmpty()) {
						%>
						(<%=contact.getRelationship()%>)
						<%
						}
						%>
						<br>
						<%=contact.getPhone()%>

					</div>
					<%
					}
					%>
					<%
					} else {
					%>
					<p class="no-contacts">No emergency contacts added yet.</p>
					<%
					}
					%>

					<!-- Add Contact Button -->
					<button type="button" id="toggleAddContact" class="btn-add-contact">
						<strong>+ Add Emergency Contact</strong>
					</button>

					<!-- Add Form -->
					<div id="addContactForm" class="add-contact-form">
						<h4>Add New Emergency Contact</h4>
						<form
							action="${pageContext.request.contextPath}/AddEmergencyContactServlet"
							method="post">
							<table>
								<tr>
									<td><label for="name">Name</label></td>
									<td><input type="text" name="name" id="name" required /></td>
								</tr>
								<tr>
									<td><label for="relationship">Relationship</label></td>
									<td><input type="text" name="relationship"
										id="relationship" required /></td>
								</tr>
								<tr>
									<td><label for="phone">Phone</label></td>
									<td><input type="tel" name="phone" id="phone" required
										placeholder="91234567" /></td>
								</tr>
							</table>

							<div class="form-buttons">
								<button type="submit" class="btn-save">Save Contact</button>
								<button type="button" id="cancelAdd" class="btn-cancel">Cancel</button>
							</div>
						</form>
					</div>

					<script>
					  const toggleBtn = document.getElementById('toggleAddContact');
		        const form = document.getElementById('addContactForm');
		        const cancelBtn = document.getElementById('cancelAdd');
		
		        toggleBtn.onclick = () => {
		            const isVisible = form.classList.toggle('show');
		            toggleBtn.innerHTML = isVisible 
		                ? '<strong>− Cancel Adding</strong>' 
		                : '<strong>+ Add Emergency Contact</strong>';
		        };
		
		        cancelBtn.onclick = () => {
		            form.classList.remove('show');
		            toggleBtn.innerHTML = '<strong>+ Add Emergency Contact</strong>';
		            form.querySelector('form').reset();
		        };
		      </script>
				</div>

				<!-- Medical Profile -->
				<div class="profile-section medical-profile">
					<h3>Medical Profile</h3>
					<%
					final MedicalProfile medicalProfile = client.getMedicalProfile();
					if (medicalProfile != null) {
					%>
					<!-- If user has a medical profile already -->
					<div class="medical-item">
						<strong>Blood Type:</strong>
						<%=medicalProfile.getBloodType()%>
					</div>
					<div class="medical-item">
						<strong>Allergies:</strong>
						<%=medicalProfile.getAllergies()%>
					</div>
					<div class="medical-item">
						<strong>Chronic Conditions:</strong>
						<%=medicalProfile.getChronicConditions()%>
					</div>
					<div class="medical-item">
						<strong>Medications:</strong>
						<%=medicalProfile.getMedications()%>
					</div>
					<div class="medical-item">
						<strong>Mobility Level:</strong>
						<%=medicalProfile.getMobilityLevel()%>
					</div>
					<div class="medical-item">
						<strong>Cognitive Status:</strong>
						<%=medicalProfile.getCognitiveStatus()%>
					</div>
					<div class="medical-item">
						<strong>Doctor:</strong>
						<%=medicalProfile.getDoctorName()%>
					</div>
					<div class="medical-item">
						<strong>Doctor Contact:</strong>
						<%=medicalProfile.getDoctorContact()%>
					</div>
					<div class="medical-item">
						<strong>Preferred Hospital:</strong>
						<%=medicalProfile.getPreferredHospital()%>
					</div>
					<div class="medical-item">
						<strong>Additional Notes:</strong>
						<%=medicalProfile.getNotes()%>
					</div>
					<a href="${pageContext.request.contextPath}/profile/"
						class="btn-edit"> <strong>Edit Medical Profile</strong>
					</a>
					<%
					}
					%>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</div>

</body>
</html>