<!-- 
Page: /
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%@ include file="/WEB-INF/components/common/header.jsp" %>

    <h1>This is the landing page!</h1>
    <p class="muted">User ID <%= sessUserId %> &middot; Role <%= sessRoleId %></p>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>