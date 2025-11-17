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
<style>
.logout-btn {
  padding: 8px 20px;
  margin-left: 10px;
  text-decoration: none;
  color: black;
  background: #ffbfd0; /* same as login */
  border-radius: 20px;
  font-size: 17px;
  font-weight: 600;
  display: inline-block;
  border: none;
  cursor: pointer;
}
</style>
<div>
	<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
	<%
	if (sessUserId != null) {
	%>
	<form action="${pageContext.request.contextPath}/auth/logout"
		method="post">
		<button type="submit" name="logout" value="logout"
			class="logout-btn">Logout</button>
	</form>
	<%
	}
	%>
</div>