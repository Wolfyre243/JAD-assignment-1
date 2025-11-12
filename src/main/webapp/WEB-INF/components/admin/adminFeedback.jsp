<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Admin feedback management with secure display and delete using JDBC utility and AuthServlet
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feedback Management</title>
</head>
<body>
    <h1>Feedback Management</h1>
    <a href="adminDashboard.jsp">Back to Dashboard</a>
    <hr>

    <h2>All Feedback</h2>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // === JDBC: Fetch feedback using utility class ===
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = 
                "SELECT f.feedback_id, f.overall_rating, f.caregiver_rating, f.comments, " +
                "       f.created_at, u.email " +
                "FROM feedback f " +
                "JOIN \"user\" u ON f.user_id = u.user_id " +
                "ORDER BY f.created_at DESC";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
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
                        while (rs.next()) {
                            int feedbackId = rs.getInt("feedback_id");
                            int overallRating = rs.getInt("overall_rating");
                            Integer caregiverRating = (Integer) rs.getObject("caregiver_rating");
                            String comments = rs.getString("comments");
                            Timestamp createdAt = rs.getTimestamp("created_at");
                            String email = rs.getString("email");
                            String formattedDate = createdAt.toString().substring(0, 19).replace("T", " ");
                    %>
                        <tr>
                            <td><%= feedbackId %></td>
                            <td><%= email %></td>
                            <td><%= overallRating %> / 5</td>
                            <td><%= caregiverRating != null ? caregiverRating + " / 5" : "N/A" %></td>
                            <td><%= comments != null && !comments.trim().isEmpty() ? comments : "No comments" %></td>
                            <td><%= formattedDate %></td>
                            <td>
                                <a href="adminDeleteFeedback.jsp?feedbackId=<%= feedbackId %>"
                                   onclick="return confirm('Delete this feedback?');"
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
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading feedback: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // === RESOURCE CLEANUP ===
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>
</body>
</html>