<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/protected.jsp"%>
<%@ include file="/WEB-INF/components/common/header.jsp" %>
	<%
		String inc = (String) request.getAttribute("includeFile");
		if (inc != null && !inc.isEmpty()) {
	%>
		<jsp:include page="<%= inc %>" />
	<%
		} else {
	%>
		<jsp:include page="/WEB-INF/components/admin/adminDashboard.jsp" />
	<%
		}
	%>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>
