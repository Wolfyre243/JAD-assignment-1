<%--
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: A logout button that hides itself depending on whether the user is logged in or not.
--%>

<!-- 
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
			class="bg-red-300 rounded-md px-2 py-1 cursor-pointer">Logout</button>
	</form>
	<%
	}
	%>
</div>