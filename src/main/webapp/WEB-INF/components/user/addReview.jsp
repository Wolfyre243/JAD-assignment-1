<%--
 - Name: Lim Song Chern Jayden
 - Admin No: P2424093
 - Class: DIT/FT/2B/01
 - Last Edited: 9/2/2026
 --%>


<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.ArrayList" %>
<%@ page import="models.Reviews" %>

<%
    ArrayList<Reviews.Option> caregivers = (ArrayList<Reviews.Option>) request.getAttribute("caregivers");
    ArrayList<Reviews.Option> products = (ArrayList<Reviews.Option>) request.getAttribute("products");
    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add New Review</title>

<style>
    body { margin: 0; font-family: "Georgia", serif; background: #ffdce4; }

    .page-container { display: flex; height: calc(100vh - 80px); }

    .left-image {
        width: 45%;
        background-image: url('https://img.freepik.com/premium-vector/feedback-illustration-senior-woman-fills-out-questionnaire-gives-positive-feedback-completes-checklist-smartphone-user-experience-concept-vector-illustration_697837-685.jpg?w=360');
        background-size: cover;
        background-position: center;
        filter: brightness(0.95);
        transform: scaleX(-1);
    }

    .right-panel {
        width: 55%;
        background: #ffd0d6;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 40px;
    }

    .form-box {
        width: 80%;
        background: #e6e6e6;
        border-radius: 35px;
        padding: 35px;
        border: 2px solid #bbbbbb;
    }

    h2 { margin-top: 0; text-align: center; font-size: 28px; font-weight: 600; }

    label { font-size: 18px; font-weight: 600; }

    select, textarea {
        width: 100%;
        padding: 10px;
        border-radius: 12px;
        border: 1px solid #aaa;
        font-size: 16px;
        margin-top: 5px;
        margin-bottom: 15px;
        font-family: Georgia;
    }

    textarea { resize: none; height: 120px; }

    .btn-submit {
        width: 100%;
        background: #ffbfd0;
        padding: 12px;
        border-radius: 20px;
        font-weight: bold;
        font-size: 18px;
        border: none;
        cursor: pointer;
        margin-top: 10px;
    }

    .btn-submit:hover { background: #ff9fb7; }

    .back-link {
        display: block;
        margin-bottom: 20px;
        color: black;
        text-decoration: none;
        font-weight: bold;
        font-size: 16px;
    }

    .msg {
        font-weight: bold;
        padding: 10px;
        border-radius: 10px;
        margin-bottom: 15px;
        text-align: center;
        background: #ffb3b3;
        color: #7a0000;
    }
</style>
</head>

<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<div class="page-container">
    <div class="left-image"></div>

    <div class="right-panel">
        <div class="form-box">

            <a class="back-link" href="<%= request.getContextPath() %>/reviews">Back to Reviews</a>

            <h2>Add Your Review</h2>

            <% if ("invalid".equals(msg)) { %>
                <div class="msg">Invalid input. Please check your fields.</div>
            <% } else if ("db_error".equals(msg)) { %>
                <div class="msg">Database error. Please try again.</div>
            <% } %>

            <form action="<%= request.getContextPath() %>/reviews" method="post">
                <input type="hidden" name="action" value="add">

                <label>Caregiver Name:</label>
                <select name="caregiver_id" required>
                    <option value="">Please choose...</option>
                    <%
                        if (caregivers != null) {
                            for (Reviews.Option c : caregivers) {
                    %>
                        <option value="<%= c.getId() %>"><%= c.getName() %></option>
                    <%
                            }
                        }
                    %>
                </select>

                <label>Service Name:</label>
                <select name="product_id" required>
                    <option value="">Please choose...</option>
                    <%
                        if (products != null) {
                            for (Reviews.Option p : products) {
                    %>
                        <option value="<%= p.getId() %>"><%= p.getName() %></option>
                    <%
                            }
                        }
                    %>
                </select>

                <label>Overall Rating (1–5):</label>
                <select name="overall_rating" required>
                    <option value="">Choose rating</option>
                    <option value="1">1 - Poor</option>
                    <option value="2">2 - Fair</option>
                    <option value="3">3 - Good</option>
                    <option value="4">4 - Very Good</option>
                    <option value="5">5 - Excellent</option>
                </select>

                <label>Caregiver Rating (1–5):</label>
                <select name="caregiver_rating" required>
                    <option value="">Choose rating</option>
                    <option value="1">1 - Poor</option>
                    <option value="2">2 - Fair</option>
                    <option value="3">3 - Good</option>
                    <option value="4">4 - Very Good</option>
                    <option value="5">5 - Excellent</option>
                </select>

                <label>Comments (Optional):</label>
                <textarea name="comments" placeholder="Write your review here..."></textarea>

                <button type="submit" class="btn-submit">Submit Review</button>
            </form>

        </div>
    </div>
</div>

</body>
</html>
