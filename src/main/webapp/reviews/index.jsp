<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="models.Reviews" %>

<jsp:include page="/WEB-INF/components/user/userNavBar.jsp" />

<%
    /*
      Author: Lim Song Chern Jayden
      Admin No: P2424093
      Class: DIT-2B-01
      Last Edited: 30/01/2026
      Description: Users can view all feedback (MVC-compliant)
    */

    ArrayList<Reviews> reviews = (ArrayList<Reviews>) request.getAttribute("reviews");
    Integer sessUserId = (Integer) request.getAttribute("sessUserId");

    SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy, HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>All Reviews</title>

<style>
    body {
        margin: 0;
        background: #f5f5f5;
        font-family: "Georgia", serif;
    }

    .page-header {
        padding: 20px 10px;
        text-align: center;
        margin-top: 0;
    }

    .page-header h1 {
        margin: 0;
        font-size: 36px;
        font-weight: 600;
        letter-spacing: 1px;
    }

    .content-box {
        max-width: 900px;
        margin: 40px auto;
        background: white;
        padding: 30px 40px;
        border-radius: 15px;
        box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
    }

    .content-box a.button {
        display: inline-block;
        padding: 10px 18px;
        background: #ffbfd0;
        color: black;
        border-radius: 20px;
        text-decoration: none;
        font-weight: bold;
        margin-bottom: 20px;
    }

    .content-box a.button:hover {
        background: #ffaec5;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }

    table th {
        background: #ffdce4;
        padding: 10px;
        font-weight: bold;
        border-bottom: 2px solid #000000;
    }

    table td {
        padding: 10px;
        border-bottom: 1px solid #ddd;
        vertical-align: top;
    }

    table tr:hover {
        background: #fff3f7;
    }

    .msg-success {
        color: green;
        font-weight: bold;
        padding: 12px;
        background: #d4edda;
        border: 1px solid #28a745;
        border-radius: 5px;
        margin-bottom: 20px;
    }

    .msg-error {
        color: red;
        font-weight: bold;
        padding: 12px;
        background: #f8d7da;
        border: 1px solid #f5c6cb;
        border-radius: 5px;
        margin-bottom: 20px;
    }
</style>

</head>
<body>

<div style="height: 40px;"></div>

<div class="page-header">
    <h1>All Reviews</h1>
</div>

<div class="content-box">

    <!-- MESSAGE DISPLAY -->
    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String msgClass = "";
            switch (msg) {
                case "added": text = "Review added successfully!"; msgClass = "msg-success"; break;
                case "updated": text = "Review updated successfully!"; msgClass = "msg-success"; break;
                case "invalid": text = "Invalid request."; msgClass = "msg-error"; break;
                case "not_found": text = "Review not found."; msgClass = "msg-error"; break;
                case "forbidden": text = "You are not allowed to edit this review."; msgClass = "msg-error"; break;
                case "db_error": text = "Database error. Please try again."; msgClass = "msg-error"; break;
                default: text = "Action completed."; msgClass = "msg-success"; break;
            }
    %>
        <p class="<%= msgClass %>"><%= text %></p>
    <%
        }
    %>

    <a href="<%= request.getContextPath() %>/reviews?action=add" class="button">
        Add New Review
    </a>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Caregiver</th>
                <th>Service</th>
                <th>Overall Rating</th>
                <th>Caregiver Rating</th>
                <th>Comments</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>

        <tbody>
        <%
            if (reviews == null || reviews.isEmpty()) {
        %>
            <tr>
                <td colspan="8"><em>No reviews available.</em></td>
            </tr>
        <%
            } else {
                for (Reviews f : reviews) {
                    String formattedDate =
                        (f.getCreatedAt() != null) ? sdf.format(f.getCreatedAt()) : "";
        %>
            <tr>
                <td><%= f.getFeedbackId() %></td>
                <td><%= f.getCaregiverName() != null ? f.getCaregiverName() : "—" %></td>
                <td><%= f.getProductName() != null ? f.getProductName() : "—" %></td>
                <td><%= f.getOverallRating() %>/5</td>
                <td><%= f.getCaregiverRating() %>/5</td>
                <td><%= f.getComments() %></td>
                <td><%= formattedDate %></td>
                <td>
                    <%
                        if (sessUserId != null && sessUserId == f.getUserId()) {
                    %>
                        <a href="<%= request.getContextPath() %>/reviews?action=edit&feedbackId=<%= f.getFeedbackId() %>">
                            Edit
                        </a>
                    <%
                        } else {
                    %>
                        <span style="color:#aaa;">—</span>
                    <%
                        }
                    %>
                </td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

</div>

</body>
</html>
