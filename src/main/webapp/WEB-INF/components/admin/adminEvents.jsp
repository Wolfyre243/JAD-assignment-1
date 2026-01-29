<%--
 - Name: Goh Yi Xin Karys
 - Admin No: P2424431
 - Class: DIT/FT/2B/01
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="models.Event" %>
<%--
  Admin Events management - consistent with other admin components
--%>
    <h1>Events Management</h1>
    <p><a href="<%= request.getContextPath() %>/admin/dashboard">← Back to Dashboard</a></p>
    <hr>

    <%
        // === DISPLAY FEEDBACK MESSAGES ===
        String msg = request.getParameter("msg");
        if (msg != null) {
            String text = "";
            String color = "";
            switch (msg) {
                case "added":    text = "Event added successfully!"; color = "green"; break;
                case "updated":  text = "Event updated successfully!"; color = "green"; break;
                case "deleted":  text = "Event deleted successfully!"; color = "green"; break;
                case "invalid":  text = "Invalid request."; color = "red"; break;
                case "not_found":text = "Event not found."; color = "red"; break;
                case "db_error": text = "Database error. Please try again."; color = "red"; break;
                default:         text = "Action completed."; color = "green";
            }
    %>
    <% String _msgClass = "msg-success"; if ("red".equals(color)) _msgClass = "msg-error"; %>
    <p class="<%= _msgClass %>"><%= text %></p>
    <%
        }
    %>

    <h2>All Events</h2>
    <p><a href="#create" class="btn">+ Create New Event</a></p>

    <div id="create" style="margin-top: 20px;">
      <form method="POST" action="<%= request.getContextPath() %>/admin/events/action">
        <input type="hidden" name="action" value="create" />
        <label>Title</label>
        <input type="text" name="title" required />
        <label>Description</label>
        <textarea name="description"></textarea>
        <label>Location</label>
        <input type="text" name="location" />
        <div style="display: flex; gap: 15px;">
            <div style="flex: 1;">
              <label>Start Date</label>
              <input type="date" id="start_date" required />
              <label>Start Time</label>
              <select id="start_time_select"></select>
            </div>
            <div style="flex: 1;">
              <label>End Date</label>
              <input type="date" id="end_date" required />
              <label>End Time</label>
              <select id="end_time_select"></select>
            </div>
          </div>
          <input type="hidden" name="start_time" id="start_time" />
          <input type="hidden" name="end_time" id="end_time" />
        <label>Capacity</label>
        <input type="number" name="capacity" value="0" />
        <label>
          <input type="checkbox" name="is_active" style="width: auto; margin-right: 8px;" />
          Active
        </label>
        <br/>
        <button class="btn" type="submit" onclick="return prepareDateTimes(this.form);">Create</button>
      </form>
    </div>

    <h2 style="margin-top: 30px;">Existing Events</h2>
    <%
        List<Event> events = (List<Event>) request.getAttribute("events");
        if (events == null || events.isEmpty()) {
    %>
        <p><em>No events found.</em></p>
    <%
        } else {
    %>
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>When</th>
              <th>Location</th>
              <th class="col-small">Capacity</th>
              <th class="col-registered">Registered</th>
              <th class="col-small">Status</th>
              <th class="col-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
          <%
            for (Event e : events) {
              boolean active = e.isActive();
          %>
            <tr>
              <td><%= e.getTitle() %></td>
              <td><%= e.getStartTime() %> - <%= e.getEndTime() %></td>
              <td><%= e.getLocation() %></td>
              <td class="col-small"><%= e.getCapacity() %></td>
              <% java.util.Map<Integer,Integer> bookingCounts = (java.util.Map<Integer,Integer>) request.getAttribute("bookingCounts");
                 Integer reg = (bookingCounts != null && bookingCounts.get(e.getEventId()) != null) ? bookingCounts.get(e.getEventId()) : 0;
                 boolean isFull = reg >= e.getCapacity();
              %>
              <td class="col-registered"><span class="<%= isFull ? "badge-full" : "badge-normal" %>"><%= reg %></span></td>
              <% String statusClass = active ? "status-active" : "status-inactive"; %>
              <td class="col-small <%= statusClass %>"><%= active ? "Active" : "Inactive" %></td>
              <td class="col-actions">
                <a href="<%= request.getContextPath() %>/admin/events?action=edit&event_id=<%= e.getEventId() %>">Edit</a>
                |
                <a href="<%= request.getContextPath() %>/admin/events?include=details&event_id=<%= e.getEventId() %>">View signups</a>
                |
                <form method="POST" action="<%= request.getContextPath() %>/admin/events/action" style="display:inline">
                  <input type="hidden" name="action" value="delete" />
                  <input type="hidden" name="event_id" value="<%= e.getEventId() %>" />
                  <button class="btn" type="submit" onclick="return confirm('Delete event?');" style="padding: 4px 12px; font-size: 14px;">Delete</button>
                </form>
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

    <script>
      // Populate time dropdowns (every 30 minutes from 08:00 to 18:00)
      (function(){
        function pad(n){ return n<10?('0'+n):(''+n); }
        var startSel = document.getElementById('start_time_select');
        var endSel = document.getElementById('end_time_select');
        var times = [];
        for(var h=8; h<=18; h++){
          times.push(pad(h)+':00');
          times.push(pad(h)+':30');
        }
        times.forEach(function(t){
          var o1 = document.createElement('option'); o1.value = t; o1.text = t; startSel.appendChild(o1);
          var o2 = document.createElement('option'); o2.value = t; o2.text = t; endSel.appendChild(o2);
        });

        // set default dates
        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = ('0'+(today.getMonth()+1)).slice(-2);
        var dd = ('0'+today.getDate()).slice(-2);
        var todayStr = yyyy + '-' + mm + '-' + dd;
        document.getElementById('start_date').value = todayStr;
        document.getElementById('end_date').value = todayStr;

        // default times
        startSel.value = '09:00';
        endSel.value = '10:00';
      })();

      function prepareDateTimes(form){
        var sd = document.getElementById('start_date').value;
        var st = document.getElementById('start_time_select').value;
        var ed = document.getElementById('end_date').value;
        var et = document.getElementById('end_time_select').value;
        if(!sd || !st || !ed || !et){ alert('Please select start and end date/time'); return false; }

        var startStr = sd + ' ' + st;
        var endStr = ed + ' ' + et;

        var s = new Date(sd + 'T' + st + ':00');
        var e = new Date(ed + 'T' + et + ':00');
        if (e <= s){ alert('End time must be after start time'); return false; }

        document.getElementById('start_time').value = startStr;
        document.getElementById('end_time').value = endStr;
        return true;
      }
    </script>
