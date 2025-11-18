<%--
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 18/11/2025
  Description: A protection guard to redirect the user if they are not logged in
--%>

<%-- /WEB-INF/components/auth/protected.jsp --%>
<%@ page import="jakarta.servlet.http.HttpSession"%>
<%
HttpSession sess = request.getSession(false);
Integer sessUserId = (sess != null) ? (Integer) sess.getAttribute("userId") : null;
Integer sessRoleId = (sess != null) ? (Integer) sess.getAttribute("userRoleId") : null;

// Check if user is logged in
if (sessUserId == null) {
  // Store the current URL they were trying to access
  String requestedURL = request.getRequestURI();
  String queryString = request.getQueryString();

  if (queryString != null) {
    requestedURL += "?" + queryString;
  }

  // Remove context path to get relative URL
  String contextPath = request.getContextPath();
  if (requestedURL.startsWith(contextPath)) {
    requestedURL = requestedURL.substring(contextPath.length());
  }

  // Redirect to login with return URL
  response.sendRedirect(
      request.getContextPath() + "/auth/login/?returnUrl=" + java.net.URLEncoder.encode(requestedURL, "UTF-8"));
  return;
}
%>