<!-- 
This is the logout button
Yes I made it hide itself so yall two don't have to
- JK

Note: Use jsp:include to include this component where needed, 
else you'll get compile error
-->

<div>
	<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
	<%
	if (sessUserId != null) {
	%>
	<form action="${pageContext.request.contextPath}/auth/logout"
		method="post">
		<button type="submit" name="logout" value="logout"
			class="bg-red-300 rounded-md px-2 py-1">Logout</button>
	</form>
	<%
	}
	%>
</div>