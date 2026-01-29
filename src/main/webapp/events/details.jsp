<!--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
-->
  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Event" %>
<%@ page import="lib.SessionManagement" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Event Details | SilverCare</title>
  <style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: #ffffff;
    }

    /* Background image (same as login page) */
    .bg-photo {
        width: 100%;
        height: 100vh;
        background-image: url("https://koala.sh/api/image/v2-5ssqc-kzclq.jpg?width=1344&height=768&dream");
        background-size: cover;
        object-fit: fill;
        background-position: center;
        position: fixed;
        z-index: -1;
        filter: brightness(0.92);
    }

    .container {
        max-width: 1000px;
        margin: 40px auto;
        padding: 0 20px;
    }

    .card {
        background: #ffdce4;
        padding: 40px 50px;
        border-radius: 40px;
        box-shadow: 0px 4px 18px rgba(0, 0, 0, 0.25);
        display: flex;
        gap: 40px;
    }

    .content {
        flex: 2;
    }

    .content h1 {
        font-size: 36px;
        font-weight: bold;
        margin-top: 0;
        margin-bottom: 20px;
        color: #222;
    }

    .meta {
        color: #555;
        margin: 12px 0;
        font-size: 18px;
    }

    .meta strong {
        color: #333;
    }

    .description {
        line-height: 1.6;
        color: #444;
        font-size: 17px;
        margin-top: 20px;
    }

    .signup-card {
        flex: 1;
        background: #ffffff;
        padding: 30px;
        border-radius: 30px;
        box-shadow: 0px 2px 12px rgba(0, 0, 0, 0.1);
    }

    .signup-card h2 {
        font-size: 24px;
        font-weight: bold;
        margin-top: 0;
        margin-bottom: 15px;
        color: #222;
    }

    label {
        display: block;
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 8px;
        margin-top: 15px;
        text-align: left;
    }

    input[type="text"],
    input[type="email"] {
        width: 100%;
        padding: 12px;
        font-size: 18px;
        font-family: "Georgia", serif;
        margin-bottom: 20px;
        border-radius: 20px;
        border: 1px solid #999;
        background: #f6f6f6;
        box-sizing: border-box;
    }

    .login-btn {
        background: #ffbfd0;
        padding: 12px 30px;
        border-radius: 25px;
        font-size: 18px;
        font-weight: bold;
        border: none;
        cursor: pointer;
        width: 100%;
        margin-top: 10px;
        transition: background 0.2s;
    }

    .login-btn:hover {
        background: #ff9fb7;
    }

    .muted {
        color: #666;
        font-size: 15px;
        margin-top: 15px;
    }

    .capacity-info {
        color: #555;
        font-size: 16px;
        margin-bottom: 20px;
    }

    @media (max-width: 800px) {
        .card {
            flex-direction: column;
        }
        .content h1 {
            font-size: 28px;
        }
    }
  </style>
</head>
<body>

    <div class="bg-photo"></div>

    <%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

    <div class="container">
      <%
        Event e = (Event) request.getAttribute("event");
        if (e == null) {
      %>
        <div class="card" style="text-align: center;">
            <p style="font-size: 18px; color: #666;">Event not found.</p>
        </div>
      <%
        } else {
      %>
        <div class="card">
          <div class="content">
            <h1><%= e.getTitle() %></h1>
            <p class="meta"><strong>When:</strong> <%= e.getStartTime() %> - <%= e.getEndTime() %></p>
            <p class="meta"><strong>Where:</strong> <%= e.getLocation() != null ? e.getLocation() : "TBA" %></p>
            <div class="description">
                <%= e.getDescription() != null && !e.getDescription().trim().isEmpty() ? e.getDescription() : "No description provided." %>
            </div>
          </div>
          <div class="signup-card">
            <h2>Sign Up</h2>
            <p class="capacity-info"><strong>Seats available:</strong> <%= e.getCapacity() %></p>
            <form method="POST" action="<%= request.getContextPath() %>/events">
              <input type="hidden" name="eventId" value="<%= e.getEventId() %>" />
              <%
                boolean loggedIn = SessionManagement.isLoggedIn(request);
                if (!loggedIn) {
              %>
                <label>Email</label>
                <input type="email" name="guestEmail" required />
                <label>Full name</label>
                <input type="text" name="guestName" required />
              <%
                }
              %>
              <button class="login-btn" type="submit">Sign up</button>
            </form>
            <p class="muted">You will receive a confirmation email after signing up.</p>
          </div>
        </div>
      <%
        }
      %>
    </div>

</body>
</html>
