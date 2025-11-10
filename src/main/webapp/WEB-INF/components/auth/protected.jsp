<%
Integer sessUserId = (Integer) session.getAttribute("userId");
Integer sessRoleId = (Integer) session.getAttribute("roleId");

if (sessUserId == null) {
  response.sendRedirect(request.getContextPath() + "/auth/login");
  return;
}
%>