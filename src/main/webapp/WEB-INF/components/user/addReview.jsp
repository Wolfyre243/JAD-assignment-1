<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Lim Song Chern Jayden
  Admin No: P2424093
  Class: DIT-2B-01
  Last Edited: 12/11/2025
  Description: Users can give feedback 
--%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add New Review </title>
</head>
<body>

<style>
    body { margin: 0; background: #f5f5f5; font-family: "Georgia", serif; }

    .page-header {
        background: #ffdce4;
        padding: 40px 20px;
        text-align: center;
        border-bottom: 4px solid #0090ff;
    }

    .page-header h1 {
        margin: 0;
        font-size: 34px;
        font-weight: 600;
        letter-spacing: 1px;
    }

    .content-box {
        max-width: 700px;
        margin: 40px auto;
        background: white;
        padding: 30px 40px;
        border-radius: 15px;
        box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
    }

    label { font-weight: bold; }

    input[type="number"], textarea {
        width: 100%;
        padding: 10px;
        margin: 8px 0 15px 0;
        border: 1px solid #ccc;
        border-radius: 8px;
        font-family: "Georgia", serif;
    }

    .button {
        display: inline-block;
        padding: 10px 20px;
        background: #ffbfd0;
        color: black;
        border-radius: 20px;
        text-decoration: none;
        font-weight: bold;
        margin-right: 10px;
    }
</style>
</head>

<body>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: #ffdce4;
    }

    /* Layout */
    .page-container {
        display: flex;
        height: calc(100vh - 80px); /* minus navbar height */
    }

    /* LEFT image */
    .left-image {
        width: 45%;
        background-image: url('https://img.freepik.com/premium-vector/feedback-illustration-senior-woman-fills-out-questionnaire-gives-positive-feedback-completes-checklist-smartphone-user-experience-concept-vector-illustration_697837-685.jpg?w=360');
        background-size: cover;
        background-position: center;
        filter: brightness(0.95);
        transform: scaleX(-1);
    }

    /* RIGHT panel */
    .right-panel {
        width: 55%;
        background: #ffd0d6;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 40px;
    }

    /* Rounded Form Box */
    .form-box {
        width: 80%;
        background: #e6e6e6;
        border-radius: 35px;
        padding: 35px;
        border: 2px solid #bbbbbb;
    }

    h2 {
        margin-top: 0;
        text-align: center;
        font-size: 28px;
        font-weight: 600;
    }

    label {
        font-size: 18px;
        font-weight: 600;
    }

    select, textarea, input[type="number"] {
        width: 100%;
        padding: 10px;
        border-radius: 12px;
        border: 1px solid #aaa;
        font-size: 16px;
        margin-top: 5px;
        margin-bottom: 15px;
        font-family: Georgia;
    }

    textarea {
        resize: none;
        height: 120px;
    }

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

    .btn-submit:hover {
        background: #ff9fb7;
    }

    .back-link {
        display: block;
        margin-bottom: 20px;
        color: black;
        text-decoration: none;
        font-weight: bold;
        font-size: 16px;
    }
</style>
</head>

<body>

<!-- NAVBAR -->
<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<!-- MAIN CONTENT -->
<div class="page-container">

    <!-- Left image -->
    <div class="left-image"></div>

    <!-- Right Form Panel -->
    <div class="right-panel">
        <div class="form-box">

            <a class="back-link" href="<%= request.getContextPath() %>/user/reviews">Back to Reviews</a>

            <h2>Add Your Review</h2>

            <form action="<%= request.getContextPath() %>/user/reviews" method="post">
    			<input type="hidden" name="action" value="add">


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