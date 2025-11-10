<!-- 
Note: If your file uses protected, just use the sessUserId in protected.
Both files include the same code to get the userId and roleId from the session.
-->
<%
Integer sessUserId = (Integer) session.getAttribute("userId");
Integer sessRoleId = (Integer) session.getAttribute("roleId");
%>