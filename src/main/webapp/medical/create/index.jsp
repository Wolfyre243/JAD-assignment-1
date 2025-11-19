<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/require-login.jsp"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Create Medical Profile | Silver Care</title>
<link rel="stylesheet" href="index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>
	<div class="form-container">
		<div class="form-header">
			<h1>Create Medical Profile</h1>
			<p>This helps caregivers provide the best possible care for you
				or your loved one.</p>
		</div>

		<div class="form-body">
			<form action="${pageContext.request.contextPath}/medical/create?cid=<%=request.getParameter("cid")%>"
				method="post">
				<div class="form-grid">
					<div class="form-group">
						<label>Blood Type</label> <select name="bloodType" required>
							<option value="">-- Select Blood Type --</option>
							<option value="A+">A+</option>
							<option value="A-">A-</option>
							<option value="B+">B+</option>
							<option value="B-">B-</option>
							<option value="AB+">AB+</option>
							<option value="AB-">AB-</option>
							<option value="O+">O+</option>
							<option value="O-">O-</option>
						</select>
					</div>

					<div class="form-group">
						<label>Allergies (if any)</label> <input type="text"
							name="allergies" placeholder="e.g. Penicillin, Peanuts">
					</div>

					<div class="form-group">
						<label>Chronic Conditions</label> <input type="text"
							name="chronicConditions"
							placeholder="e.g. Diabetes, Hypertension">
					</div>

					<div class="form-group">
						<label>Current Medications</label> <input type="text"
							name="medications" placeholder="List medications and dosage">
					</div>

					<div class="form-group">
						<label>Mobility Level</label> <select name="mobilityLevel">
							<option value="Independent">Independent</option>
							<option value="Uses Walking Aid">Uses Walking Aid</option>
							<option value="Wheelchair Bound">Wheelchair Bound</option>
							<option value="Bedridden">Bedridden</option>
						</select>
					</div>

					<div class="form-group">
						<label>Cognitive Status</label> <select name="cognitiveStatus">
							<option value="Fully Alert">Fully Alert</option>
							<option value="Mild Impairment">Mild Cognitive
								Impairment</option>
							<option value="Dementia - Mild">Dementia - Mild</option>
							<option value="Dementia - Moderate">Dementia - Moderate</option>
							<option value="Dementia - Severe">Dementia - Severe</option>
						</select>
					</div>

					<div class="form-group">
						<label>Preferred Hospital</label> <input type="text"
							name="preferredHospital"
							placeholder="e.g. Singapore General Hospital">
					</div>

					<div class="form-group">
						<label>Doctor's Name</label> <input type="text" name="doctorName"
							placeholder="Dr. Tan Mei Ling">
					</div>

					<div class="form-group">
						<label>Doctor's Contact</label> <input type="text"
							name="doctorContact" placeholder="+65 8123 4567">
					</div>

					<div class="form-group full-width">
						<label>Additional Notes / Special Instructions</label>
						<textarea name="notes"
							placeholder="Any other important information caregivers should know..."></textarea>
					</div>

				</div>

				<div style="text-align: center; margin-top: 30px;">
					<button type="submit" class="btn-submit">Save Medical
						Profile</button>
					<a href="${pageContext.request.contextPath}/profile/"
						class="btn-cancel">Cancel</a>
				</div>
			</form>
		</div>
	</div>
</body>
</html>