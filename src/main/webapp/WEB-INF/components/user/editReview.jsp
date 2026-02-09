<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.ArrayList" %>
<%@ page import="models.Reviews" %>

<%
    Reviews feedback = (Reviews) request.getAttribute("feedback");
    ArrayList<Reviews.Option> caregivers = (ArrayList<Reviews.Option>) request.getAttribute("caregivers");
    ArrayList<Reviews.Option> products = (ArrayList<Reviews.Option>) request.getAttribute("products");

    String msg = request.getParameter("msg");

    if (feedback == null) {
        out.println("<p style='color:red;'>Invalid review request.</p>");
        return;
    }

    int feedbackId = feedback.getFeedbackId();
    int caregiverId = (feedback.getCaregiverId() != null) ? feedback.getCaregiverId() : 0;
    int productId = (feedback.getProductId() != null) ? feedback.getProductId() : 0;

    int overallRating = feedback.getOverallRating();
    int caregiverRating = feedback.getCaregiverRating();
    String comments = feedback.getComments();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Review</title>

<style>
    body { margin: 0; font-family: "Georgia", serif; background: #ffdce4; }

    .page-container { display: flex; justify-content: center; padding: 50px 0; }

    .form-box {
        width: 60%;
        background: #e6e6e6;
        border-radius: 35px;
        padding: 35px 45px;
        border: 2px solid #bbbbbb;
        box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
    }

    h2 { margin-top: 0; text-align: center; font-size: 30px; font-weight: 600; }

    .back-link {
        display: inline-block;
        margin-bottom: 20px;
        padding: 10px 18px;
        background: #ffe1ea;
        color: black;
        text-decoration: none;
        font-weight: bold;
        font-size: 16px;
        border-radius: 15px;
        box-shadow: 0px 2px 6px rgba(0,0,0,0.15);
    }
    .back-link:hover { background: #ffc7d6; }

    label { font-size: 18px; font-weight: 600; }

    select, textarea {
        width: 100%;
        padding: 10px;
        border-radius: 12px;
        border: 1px solid #aaa;
        font-size: 16px;
        margin-top: 5px;
        margin-bottom: 15px;
        font-family: "Georgia";
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

    .msg { font-weight: bold; padding: 10px; border-radius: 10px; margin-bottom: 15px; text-align: center; }
    .error { background: #ffb3b3; color: #7a0000; }
    .success { background: #b3ffb5; color: #004d00; }
</style>
</head>

<body>

<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

<div class="page-container">
    <div class="form-box">

        <a class="back-link" href="<%= request.getContextPath() %>/reviews">Back to Reviews</a>

        <h2>Edit Your Review</h2>

        <% if (msg != null) {
            String css = "error";
            String text = "";
            switch (msg) {
                case "invalid": text = "Invalid input. Please check your fields."; break;
                case "db_error": text = "A database error occurred. Please try again."; break;
                case "forbidden": text = "You cannot edit this review."; break;
                case "updated": text = "Your review was updated successfully!"; css = "success"; break;
            }
        %>
            <div class="msg <%= css %>"><%= text %></div>
        <% } %>

        <form action="<%=request.getContextPath()%>/reviews" method="post">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="feedbackId" value="<%= feedbackId %>">

            <label>Caregiver Name:</label>
            <select name="caregiver_id" required>
                <option value="">Please choose...</option>
                <%
                    if (caregivers != null) {
                        for (Reviews.Option c : caregivers) {
                %>
                    <option value="<%= c.getId() %>" <%= (c.getId() == caregiverId ? "selected" : "") %>>
                        <%= c.getName() %>
                    </option>
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
                    <option value="<%= p.getId() %>" <%= (p.getId() == productId ? "selected" : "") %>>
                        <%= p.getName() %>
                    </option>
                <%
                        }
                    }
                %>
            </select>

            <label>Overall Rating (1–5):</label>
            <select name="overall_rating" required>
                <option value="1" <%= overallRating==1?"selected":"" %>>1 - Poor</option>
                <option value="2" <%= overallRating==2?"selected":"" %>>2 - Fair</option>
                <option value="3" <%= overallRating==3?"selected":"" %>>3 - Good</option>
                <option value="4" <%= overallRating==4?"selected":"" %>>4 - Very Good</option>
                <option value="5" <%= overallRating==5?"selected":"" %>>5 - Excellent</option>
            </select>

            <label>Caregiver Rating (1–5):</label>
            <select name="caregiver_rating" required>
                <option value="1" <%= caregiverRating==1?"selected":"" %>>1 - Poor</option>
                <option value="2" <%= caregiverRating==2?"selected":"" %>>2 - Fair</option>
                <option value="3" <%= caregiverRating==3?"selected":"" %>>3 - Good</option>
                <option value="4" <%= caregiverRating==4?"selected":"" %>>4 - Very Good</option>
                <option value="5" <%= caregiverRating==5?"selected":"" %>>5 - Excellent</option>
            </select>

            <label>Comments (Optional):</label>
            <textarea name="comments"><%= comments != null ? comments : "" %></textarea>

            <button type="submit" class="btn-submit">Save Changes</button>
        </form>

    </div>
</div>

</body>
</html>
