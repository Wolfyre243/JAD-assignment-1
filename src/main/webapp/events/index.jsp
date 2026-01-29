<!--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
-->
  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="models.Event" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Events | SilverCare</title>

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

    .events-container {
        max-width: 1200px;
        margin: 40px auto;
        padding: 0 20px;
    }

    .events-header {
        text-align: center;
        margin-bottom: 40px;
    }

    .events-header h1 {
        font-size: 36px;
        font-weight: bold;
        color: #222;
        margin-bottom: 10px;
    }

    .grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 30px;
        margin-bottom: 40px;
    }

    .card {
        background: #ffdce4;
        border-radius: 30px;
        padding: 28px;
        box-shadow: 0px 4px 18px rgba(0, 0, 0, 0.25);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        min-height: 200px;
        display: flex;
        flex-direction: column;
    }

    .card-image {
        width: 100%;
        height: 160px;
        object-fit: cover;
        border-radius: 18px;
        margin-bottom: 12px;
    }

    .card:hover {
        transform: translateY(-4px);
        box-shadow: 0px 6px 24px rgba(0, 0, 0, 0.3);
    }

    /* hide the large background photo for events pages so pages are white */
    .bg-photo { display: none !important; }

    .card-title {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 8px;
        color: #222;
    }

    .card-subtitle {
        font-size: 16px;
        font-style: italic;
        color: #666;
        margin-bottom: 12px;
    }

    .card-description {
        font-size: 15px;
        color: #444;
        line-height: 1.5;
        margin-bottom: 12px;
        flex-grow: 1;
    }

    .card-meta {
        margin-top: 12px;
        color: #555;
        font-size: 14px;
    }

    .details-btn {
        background: #ffbfd0;
        color: #000;
        padding: 10px 20px;
        border-radius: 25px;
        text-decoration: none;
        font-size: 16px;
        font-weight: bold;
        display: inline-block;
        margin-top: 16px;
        text-align: center;
        border: none;
        cursor: pointer;
        transition: background 0.2s;
    }

    .details-btn:hover {
        background: #ff9fb7;
        text-decoration: none;
    }

    .no-events {
        background: #ffdce4;
        border-radius: 30px;
        padding: 40px;
        text-align: center;
        box-shadow: 0px 4px 18px rgba(0, 0, 0, 0.25);
        font-size: 18px;
        color: #666;
    }

    @media (max-width: 900px) {
        .grid { 
            grid-template-columns: repeat(2, 1fr); 
            gap: 24px;
        }
    }
    
    @media (max-width: 600px) {
        .grid { 
            grid-template-columns: 1fr;
        }
        .events-header h1 {
            font-size: 28px;
        }
    }
</style>

</head>
<body>

    <div class="bg-photo"></div>

    <%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

    <div class="events-container">
        <div class="events-header">
            <h1>Upcoming Events</h1>
        </div>

        <div class="grid">
        <%
            ArrayList<Event> events = Event.getAllEvents();
            if (events == null || events.isEmpty()) {
        %>
            <div class="no-events">
                <em>No events available at this time.</em>
            </div>
        <%
            } else {
                for (Event e : events) {
        %>
            <div class="card">
                <%
                    String imagePath = e.getImagePath();
                    String imageUrl = (imagePath != null && !imagePath.trim().isEmpty()) ? request.getContextPath() + "/images/events/" + imagePath : "https://koala.sh/api/image/v2-5ssqc-kzclq.jpg?width=600&height=400&dream";
                %>
                <img src="<%= imageUrl %>" class="card-image" alt="<%= e.getTitle() %> image" />
                <div class="card-title"><%= e.getTitle() %></div>
                <div class="card-subtitle"><%= e.getLocation() != null ? e.getLocation() : "TBA" %></div>
                <div class="card-description"><%= e.getDescription() != null && !e.getDescription().trim().isEmpty() ? e.getDescription() : "Join us for this exciting event!" %></div>
                <div class="card-meta"><strong>When:</strong> <%= e.getStartTime() %> – <%= e.getEndTime() %></div>
                <a class="details-btn" href="<%= request.getContextPath() %>/events?id=<%= e.getEventId() %>">View / Sign up</a>
            </div>
        <%
                }
            }
        %>
        </div>
    </div>

</body>
</html>
