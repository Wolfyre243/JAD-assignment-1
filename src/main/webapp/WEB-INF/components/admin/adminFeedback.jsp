<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<h1>Feedback Management</h1>
<a href="<%= request.getContextPath() %>/admin/dashboard">Back to Dashboard</a>
<hr>

<h2>All Feedback</h2>

<%
    java.util.List<java.util.Map<String,Object>> feedbacks = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("feedbacks");
    if (feedbacks == null || feedbacks.isEmpty()) {
%>
    <p><em>No feedback available.</em></p>
<%
    } else {
%>
    <table border="1" cellpadding="8" cellspacing="0">
        <thead>
            <tr>
                <th>ID</th>
                <th>User Email</th>
                <th>Overall Rating</th>
                <th>Caregiver Rating</th>
                <th>Comments</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            for (java.util.Map<String,Object> f : feedbacks) {
                int feedbackId = (Integer) f.get("feedbackId");
                int overallRating = (Integer) f.get("overallRating");
                Integer caregiverRating = (Integer) f.get("caregiverRating");
                String comments = (String) f.get("comments");
                java.sql.Timestamp createdAt = (java.sql.Timestamp) f.get("createdAt");
                String email = (String) f.get("email");
                String formattedDate = createdAt != null ? createdAt.toString().substring(0,19).replace("T"," ") : "";
        %>
            <tr>
                <td><%= feedbackId %></td>
                <td><%= email %></td>
                <td><%= overallRating %> / 5</td>
                <td><%= caregiverRating != null ? caregiverRating + " / 5" : "N/A" %></td>
                <td><%= comments != null && !comments.trim().isEmpty() ? comments : "No comments" %></td>
                <td><%= formattedDate %></td>
                <td>
                    <a href="<%= request.getContextPath() %>/admin/feedback?include=delete&feedbackId=<%= feedbackId %>"
                       style="color:red;">Delete</a>
                </td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
<%
    }
%>

