<!-- 
Note: If your file uses protected.jsp, the variables are already declared there.
This file only uses request attributes to avoid duplicate variable declarations.
-->
<%
// Only set request attributes if not already set by protected.jsp
if (pageContext.getAttribute("_authVarsSet") == null) {
    request.setAttribute("sessUserId", session.getAttribute("userId"));
    request.setAttribute("sessRoleId", session.getAttribute("userRoleId"));
}
%>