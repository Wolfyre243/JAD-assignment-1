<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  Name: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Description: Admin feedback deletion confirmation page
--%>
<%
    String feedbackId = request.getParameter("feedbackId");
    if (feedbackId == null || feedbackId.trim().isEmpty()) {
%>
    <p class="msg-error">No feedback selected for deletion.</p>
    <p><a href="<%= request.getContextPath() %>/admin/feedback">← Back to Feedback</a></p>
<%
    } else {
%>
    <h1>Delete Feedback</h1>
    <p><a href="<%= request.getContextPath() %>/admin/feedback">← Back to Feedback</a></p>
    <hr>
    
    <p style="font-size: 18px; margin: 30px 0;">
        Are you sure you want to delete feedback ID <strong><%= feedbackId %></strong>?
        <br><br>
        <em style="color: #666;">This action cannot be undone.</em>
    </p>
    
    <form method="post" action="<%= request.getContextPath() %>/admin/feedback/delete">
        <input type="hidden" name="feedbackId" value="<%= feedbackId %>">
        <button type="submit" class="btn" style="background: #dc3545;" onclick="return confirm('Delete this feedback?');">Confirm Delete</button>
        <a href="<%= request.getContextPath() %>/admin/feedback" class="btn btn-secondary">Cancel</a>
    </form>
<%
    }
%>