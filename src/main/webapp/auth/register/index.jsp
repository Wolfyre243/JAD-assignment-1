<!-- 
Page: /auth/register
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%
// If user is logged in, redirect to landing page
if (sessUserId != null) {
	response.sendRedirect(request.getContextPath() + "/");
}
%>

<%@ include file="/WEB-INF/components/common/header.jsp" %>

	<h1>Create your account</h1>

	<form action="${pageContext.request.contextPath}/auth/register" method="post">
		<label>Email: <input type="email" name="email" required maxlength="255"></label>
		<br>
		<label>Password: <input type="password" name="password" required></label>
		<br>
		<label>I am: 
			<select name="roleId" required>
				<option value="">-- Select --</option>
				<option value="2">A client</option>
				<option value="3">A guardian</option>
			</select>
		</label>
		<br>
		<label><input type="checkbox" name="terms" required> I agree to the Terms and Conditions</label>
		<br>
		<button type="submit">Register</button>
	</form>

	<p>Already have an account? <a href="${pageContext.request.contextPath}/auth/login/">Log in</a></p>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>
