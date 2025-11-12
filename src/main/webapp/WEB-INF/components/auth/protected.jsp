<%-- /WEB-INF/components/auth/protected.jsp --%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
        out.println(sessRoleId);
        // response.sendRedirect(request.getContextPath() + "/auth/login/?returnUrl=" + 
                              // java.net.URLEncoder.encode(requestedURL, "UTF-8"));
        return;
    }
    
    System.out.println("Protected JSP accessed by userId: " + sessRoleId);
    // Check if user is admin (roleId = 1)
    if (sessRoleId == null || sessRoleId != 1) {
        // Not an admin - redirect to home page
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
%>