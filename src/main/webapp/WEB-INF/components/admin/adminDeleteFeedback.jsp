<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String feedbackId = request.getParameter("feedbackId");
    if (feedbackId == null || feedbackId.trim().isEmpty()) {
%>
    <p style="color:red;">No feedback selected for deletion.</p>
    <a href="<%= request.getContextPath() %>/admin/feedback">Back to Feedback</a>
<%
    } else {
%>
    <h1>Delete Feedback</h1>
    <p>Are you sure you want to delete feedback ID <strong><%= feedbackId %></strong>?</p>
    <form method="post" action="<%= request.getContextPath() %>/admin/feedback/delete">
        <input type="hidden" name="feedbackId" value="<%= feedbackId %>">
        <button type="submit" onclick="return confirm('Delete this feedback?');">Delete</button>
        <a href="<%= request.getContextPath() %>/admin/feedback">Cancel</a>
    </form>
<%
    }
%>