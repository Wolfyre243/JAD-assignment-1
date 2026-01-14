<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- NAVBAR (unchanged) -->
<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Lim Song Chern Jayden
  Admin No: P2424093
  Class: DIT-2B-01
  Last Edited: 23/11/2025
  Description: Users can see all feedback 
--%>
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

    /* Page Header Section */
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

    /* Card container for content */
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

    /* Table styles */
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

<!-- GAP BELOW NAVBAR -->
<div style="height: 40px;"></div>

<!-- PAGE HEADER -->
<div class="page-header">
    <h1>All Reviews</h1>
</div>

<!-- MAIN CONTENT -->
<div class="content-box">

    <%-- MESSAGE DISPLAY --%>
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
                case "db_error": text = "Database error. Please try again."; msgClass = "msg-error"; break;
                default: text = "Action completed."; msgClass = "msg-success"; break;
            }
    %>
        <p class="<%= msgClass %>"><%= text %></p>
    <% } %>

    <a href="<%= request.getContextPath() %>/reviews?action=add" class="button">Add New Review</a>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        

        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql =
                    "SELECT f.feedback_id, f.user_id, f.overall_rating, f.caregiver_rating, " +
                    "       f.comments, f.created_at, " +
                    "       CONCAT(c.first_name, ' ', c.last_name) AS caregiver_name, " +
                    "       p.name AS product_name " +
                    "FROM feedback f " +
                    "LEFT JOIN caregiver c ON f.caregiver_id = c.caregiver_id " +
                    "LEFT JOIN product p ON f.product_id = p.product_id " +
                    "ORDER BY f.feedback_id DESC";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
    %>

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
            if (!rs.isBeforeFirst()) {
        %>
            <tr><td colspan="6"><em>No reviews available.</em></td></tr>
        <%
            } else {
                // Declare sessUserId once before the loop
                Integer sessUserId = (Integer) request.getAttribute("sessUserId");
                while (rs.next()) {
                	 int feedbackId = rs.getInt("feedback_id");
                     int ownerId = rs.getInt("user_id");
                     java.sql.Timestamp ts = rs.getTimestamp("created_at");
                     

					String formattedDate = "";
					if (ts != null) {
    					SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy, HH:mm");  
    					formattedDate = sdf.format(ts);
					}
             %>

             <tr>
                 <td><%= feedbackId %></td>
                 <td><%= rs.getString("caregiver_name") %></td>
                 <td><%= rs.getString("product_name") %></td>
                 <td><%= rs.getInt("overall_rating") %>/5</td>
                 <td><%= rs.getInt("caregiver_rating") %>/5</td>
                 <td><%= rs.getString("comments") %></td>
                 <td><%= formattedDate %></td>
                 <td>
                     <% if (sessUserId != null && sessUserId == ownerId) { %>
                         <a href="<%= request.getContextPath() %>/reviews?action=edit&feedbackId=<%= feedbackId %>">Edit</a>
                     <% } else { %>
                         <span style="color:#aaa;">—</span>
                     <% } %>
                 </td>
             </tr>
        <%
                }
            }
        %>

        </tbody>
    </table>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading review: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>

</div>

</body>
</html>