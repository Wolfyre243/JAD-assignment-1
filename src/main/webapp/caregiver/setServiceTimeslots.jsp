<!--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/require-login.jsp"%>
<%@ page import="models.Product" %>
<%@ page import="models.CaregiverService" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Set My Schedule</title>
<style>
    body { margin: 0; font-family: "Georgia", serif; background: #f5f5f5; }
    .container { max-width: 820px; margin: 40px auto; background: #ffffff; border-radius: 18px; padding: 28px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
    .section-title { font-size: 26px; font-weight: 700; margin-bottom: 16px; color: #ff8aa1; }
    .lead { color: #666; margin-bottom: 20px; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px; }
    label { display: block; font-weight: 600; margin-bottom: 6px; }
    select, input[type="date"], input[type="time"], input[type="text"] {
        width: 100%;
        padding: 10px 12px;
        font-size: 15px;
        border-radius: 10px;
        border: 1px solid #ddd;
        background: #fbfbfb;
        box-sizing: border-box;
    }
    .full { grid-column: 1 / -1; }
    .add-btn {
        background: linear-gradient(180deg,#ffbfd0,#ff8aa1);
        color: black;
        width: 100%;
        padding: 12px 0;
        font-size: 18px;
        border-radius: 10px;
        border: none;
        font-weight: 700;
        cursor: pointer;
        transition: transform .12s ease, box-shadow .12s ease;
    }
    .add-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255,138,161,0.12); color: white; }
    .msg-success { background: #fff1f4; border: 1px solid #ffd0d9; color: #9b2d48; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-weight: 600; }
    .note { font-size: 13px; color: #777; margin-top: 6px; }
</style>
</head>
<body>
<jsp:include page="/WEB-INF/components/user/userNavBar.jsp" />
<div class="container">
    <div class="section-title">Set Your Available Timeslots for Services</div>
    <div class="lead">Pick one of your assigned services, choose a date and a time window, then save your availability. Clients will see these slots when they pick the same date.</div>
    <%
        String error = request.getParameter("error");
        String prevServiceId = request.getParameter("serviceId");
        String prevDate = request.getParameter("availabilityDate");
        String prevStart = request.getParameter("startTime");
        String prevEnd = request.getParameter("endTime");
        if ("1".equals(request.getParameter("success"))) { %>
        <div class="msg-success">Availability saved successfully.</div>
    <% } else if (error != null) {
           String msg = "An error occurred.";
           if ("end_before_start".equals(error)) msg = "End time must be after start time.";
    %>
        <div style="background:#ffefef;border:1px solid #ffd0d9;color:#9b2d48;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-weight:700;"><%= msg %></div>
    <% } %>
    <form action="<%=request.getContextPath()%>/caregiver/setServiceTimeslots" method="post">
        <input type="hidden" name="action" id="formAction" value="create" />
        <input type="hidden" name="availabilityId" id="availabilityId" value="" />
        <div class="form-grid">
            <div class="full">
                <label for="serviceId">Select Service</label>
                <select name="serviceId" id="serviceId" required>
                    <option value="">-- Select a Service --</option>
                <% 
                Integer caregiverUserId = (Integer) session.getAttribute("userId");
                try {
                    if (caregiverUserId == null) {
                        throw new Exception("Not logged in");
                    }
                    models.Caregiver cg = models.Caregiver.getCaregiverByUserId(caregiverUserId);
                    if (cg == null) { %>
                        <option disabled>No assigned services found</option>
                    <% } else {
                        int caregiverId = cg.getCaregiverId();
                        ArrayList<Product> services = CaregiverService.getAssignedServices(caregiverId);
                        if (services == null || services.isEmpty()) { %>
                            <option disabled>No assigned services found</option>
                        <% } else {
                            for (Product service : services) {
                                String sid = String.valueOf(service.getProductId());
                                String selected = "";
                                if (prevServiceId != null && prevServiceId.equals(sid)) selected = " selected";
                        %>
                                <option value="<%= service.getProductId() %>"<%= selected %>><%= service.getName() %></option>
                            <% }
                        }
                    }
                } catch (Exception e) { %>
                    <option disabled>Error loading services</option>
                <% } %>
            </select>
        </div>
            <div>
                <label for="availabilityDate">Select Date</label>
                <input type="date" id="availabilityDate" name="availabilityDate" required value="<%= prevDate != null ? prevDate : "" %>" />
                <div class="note">Choose the date this availability applies to.</div>
            </div>
            <div>
                <label for="startTime">Start Time</label>
                <input type="time" id="startTime" name="startTime" required value="<%= prevStart != null ? prevStart : "" %>" />
            </div>
            <div>
                <label for="endTime">End Time</label>
                <input type="time" id="endTime" name="endTime" required value="<%= prevEnd != null ? prevEnd : "" %>" />
            </div>
        </div>
        <button type="submit" class="add-btn">Save Availability</button>
    </form>
    <hr style="margin:22px 0; border:none; border-top:1px solid #f0e9eb">
    <div class="section-title" style="font-size:20px; margin-bottom:12px;">Your Existing Availability</div>
    <div class="lead" style="margin-bottom:8px">Manage, edit or delete previously saved availability slots.</div>
    <div>
        <table style="width:100%; border-collapse:collapse;">
            <thead>
                <tr style="text-align:left; border-bottom:1px solid #eee;">
                    <th style="padding:10px">Service</th>
                    <th style="padding:10px">Date</th>
                    <th style="padding:10px">Start</th>
                    <th style="padding:10px">End</th>
                    <th style="padding:10px">Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                try {
                    Integer caregiverUserId2 = (Integer) session.getAttribute("userId");
                    models.Caregiver cg2 = models.Caregiver.getCaregiverByUserId(caregiverUserId2);
                    if (cg2 != null) {
                        java.util.ArrayList<models.CaregiverAvailability> mySlots = models.CaregiverAvailability.getByCaregiver(cg2.getCaregiverId());
                        for (models.CaregiverAvailability s : mySlots) {
                            models.Product prod = models.Product.getProductById(s.getProductId());
                %>
                <tr>
                    <td style="padding:10px"><%= prod != null ? prod.getName() : "-" %></td>
                    <td style="padding:10px"><%= s.getAvailabilityDate() %></td>
                    <td style="padding:10px"><%= s.getStartTime().toString().substring(0,5) %></td>
                    <td style="padding:10px"><%= s.getEndTime().toString().substring(0,5) %></td>
                    <td style="padding:10px">
                        <button type="button" onclick="editSlot('<%= s.getAvailabilityId() %>','<%= s.getProductId() %>','<%= s.getAvailabilityDate() %>','<%= s.getStartTime().toString().substring(0,5) %>','<%= s.getEndTime().toString().substring(0,5) %>')" style="margin-right:8px; padding:6px 10px; border-radius:8px; border:1px solid #ffd0d9; background:#fff; cursor:pointer">Edit</button>
                        <form method="post" action="<%=request.getContextPath()%>/caregiver/setServiceTimeslots" style="display:inline;" onsubmit="return confirm('Delete this availability?');">
                            <input type="hidden" name="action" value="delete" />
                            <input type="hidden" name="availabilityId" value="<%= s.getAvailabilityId() %>" />
                            <button type="submit" style="padding:6px 10px; border-radius:8px; border:none; background:#ffdce4; cursor:pointer">Delete</button>
                        </form>
                    </td>
                </tr>
                <%      }
                    }
                } catch (Exception e) {
                    out.print("<tr><td colspan='5' style='padding:10px;color:#a00'>Error loading slots</td></tr>");
                }
                %>
            </tbody>
        </table>
    </div>

    <script>
    function editSlot(id, productId, date, start, end) {
        document.getElementById('formAction').value = 'update';
        document.getElementById('availabilityId').value = id;
        document.getElementById('serviceId').value = productId;
        document.getElementById('availabilityDate').value = date;
        document.getElementById('startTime').value = start;
        document.getElementById('endTime').value = end;
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    </script>
</div>
</body>
</html>
