<%@page import="models.Client"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="models.MedicalProfile"%>
<%@ page import="java.sql.SQLException"%>
<%@ include file="/WEB-INF/components/auth/require-login.jsp"%>
<%
Integer clientId = null;
MedicalProfile profile = null;

if (request.getParameter("cid") != null) {
	clientId = Integer.parseInt(request.getParameter("cid"));

	profile = MedicalProfile.getMedicalProfileByClientId(clientId);
} else {
	Client client = Client.getClientByUserId(sessUserId);
	profile = MedicalProfile.getMedicalProfileByClientId(client.getClientId());
}

if (profile == null) {
	response.sendRedirect(request.getContextPath() + "/medical/create/");
	return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Edit Medical Profile | Silver Care</title>
<link rel="stylesheet" href="index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="form-container">
		<div class="form-header">
			<h1>Edit Medical Profile</h1>
			<p>Keep your health information up-to-date for better care</p>
		</div>

		<div class="form-body">
			<form
				action="${pageContext.request.contextPath}/medical/edit<%= clientId != null ? "?cid=" + request.getParameter("cid") : "" %>"
				method="post">

				<div class="form-grid">

					<div class="form-group">
						<label>Blood Type <span class="required">*</span></label> <select
							name="bloodType" required>
							<option value="">-- Select Blood Type --</option>
							<option value="A+"
								<%="A+".equals(profile.getBloodType()) ? "selected" : ""%>>A+</option>
							<option value="A-"
								<%="A-".equals(profile.getBloodType()) ? "selected" : ""%>>A-</option>
							<option value="B+"
								<%="B+".equals(profile.getBloodType()) ? "selected" : ""%>>B+</option>
							<option value="B-"
								<%="B-".equals(profile.getBloodType()) ? "selected" : ""%>>B-</option>
							<option value="AB+"
								<%="AB+".equals(profile.getBloodType()) ? "selected" : ""%>>AB+</option>
							<option value="AB-"
								<%="AB-".equals(profile.getBloodType()) ? "selected" : ""%>>AB-</option>
							<option value="O+"
								<%="O+".equals(profile.getBloodType()) ? "selected" : ""%>>O+</option>
							<option value="O-"
								<%="O-".equals(profile.getBloodType()) ? "selected" : ""%>>O-</option>
						</select>
					</div>

					<div class="form-group">
						<label>Allergies (if any)</label> <input type="text"
							name="allergies"
							value="<%=profile.getAllergies() != null ? profile.getAllergies() : ""%>"
							placeholder="e.g. Penicillin, Peanuts">
					</div>

					<div class="form-group">
						<label>Chronic Conditions</label> <input type="text"
							name="chronicConditions"
							value="<%=profile.getChronicConditions() != null ? profile.getChronicConditions() : ""%>"
							placeholder="e.g. Diabetes, Hypertension">
					</div>

					<div class="form-group">
						<label>Current Medications</label> <input type="text"
							name="medications"
							value="<%=profile.getMedications() != null ? profile.getMedications() : ""%>"
							placeholder="List medications and dosage">
					</div>

					<div class="form-group">
						<label>Mobility Level</label> <select name="mobilityLevel">
							<option value="Independent"
								<%="Independent".equals(profile.getMobilityLevel()) ? "selected" : ""%>>Independent</option>
							<option value="Uses Walking Aid"
								<%="Uses Walking Aid".equals(profile.getMobilityLevel()) ? "selected" : ""%>>Uses
								Walking Aid</option>
							<option value="Wheelchair Bound"
								<%="Wheelchair Bound".equals(profile.getMobilityLevel()) ? "selected" : ""%>>Wheelchair
								Bound</option>
							<option value="Bedridden"
								<%="Bedridden".equals(profile.getMobilityLevel()) ? "selected" : ""%>>Bedridden</option>
						</select>
					</div>

					<div class="form-group">
						<label>Cognitive Status</label> <select name="cognitiveStatus">
							<option value="Fully Alert"
								<%="Fully Alert".equals(profile.getCognitiveStatus()) ? "selected" : ""%>>Fully
								Alert</option>
							<option value="Mild Impairment"
								<%="Mild Impairment".equals(profile.getCognitiveStatus()) ? "selected" : ""%>>Mild
								Cognitive Impairment</option>
							<option value="Dementia - Mild"
								<%="Dementia - Mild".equals(profile.getCognitiveStatus()) ? "selected" : ""%>>Dementia
								- Mild</option>
							<option value="Dementia - Moderate"
								<%="Dementia - Moderate".equals(profile.getCognitiveStatus()) ? "selected" : ""%>>Dementia
								- Moderate</option>
							<option value="Dementia - Severe"
								<%="Dementia - Severe".equals(profile.getCognitiveStatus()) ? "selected" : ""%>>Dementia
								- Severe</option>
						</select>
					</div>

					<div class="form-group">
						<label>Preferred Hospital</label> <input type="text"
							name="preferredHospital"
							value="<%=profile.getPreferredHospital() != null ? profile.getPreferredHospital() : ""%>"
							placeholder="e.g. Singapore General Hospital">
					</div>

					<div class="form-group">
						<label>Doctor's Name</label> <input type="text" name="doctorName"
							value="<%=profile.getDoctorName() != null ? profile.getDoctorName() : ""%>"
							placeholder="Dr. Tan Mei Ling">
					</div>

					<div class="form-group">
						<label>Doctor's Contact</label> <input type="text"
							name="doctorContact"
							value="<%=profile.getDoctorContact() != null ? profile.getDoctorContact() : ""%>"
							placeholder="+65 8123 4567">
					</div>

					<div class="form-group full-width">
						<label>Additional Notes / Special Instructions</label>
						<textarea name="notes"><%=profile.getNotes() != null ? profile.getNotes() : ""%></textarea>
					</div>

				</div>

				<div style="text-align: center; margin-top: 30px;">
					<button type="submit" class="btn-submit">Update Medical
						Profile</button>
					<a href="${pageContext.request.contextPath}/profile/"
						class="btn-cancel">Cancel</a>
				</div>
			</form>
		</div>
	</div>
</body>
</html>