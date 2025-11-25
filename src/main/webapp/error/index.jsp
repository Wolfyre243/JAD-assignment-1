<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isErrorPage="true"%>
<%
if (request.getAttribute("error") == null) {
	response.sendRedirect(request.getContextPath() + "/");
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Error | SilverCare</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/error/index.css">
</head>
<body>
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="error-container">
		<div class="error-card">
			<div class="error-icon">⚠️</div>

			<h1>Oops! Something went wrong</h1>

			<p class="error-message"><%=request.getAttribute("error")%></p>

			<div class="error-actions">
				<a href="${pageContext.request.contextPath}/" class="btn-primary">Back
					to Home</a>
				<button onclick="history.back()" class="btn-secondary">Go
					Back</button>
			</div>
		</div>
	</div>
</body>
</html>