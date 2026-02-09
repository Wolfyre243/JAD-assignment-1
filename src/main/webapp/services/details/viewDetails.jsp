<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%@ page import="models.Product" %>
<%@ page import="models.CaregiverAvailability" %>
<%@ page import="java.util.ArrayList" %>
<%
// Handle AJAX timeslot requests early so we return only the snippet (avoid returning full page)
if ("1".equals(request.getParameter("ajaxTimeslots"))) {
    String idParamAjax = request.getParameter("id");
    String dateStrAjax = request.getParameter("date");
    if (idParamAjax == null || idParamAjax.isEmpty() || dateStrAjax == null || dateStrAjax.isEmpty()) {
        out.print("<div style='color:red'>Invalid request</div>");
        return;
    }
    int productIdAjax = Integer.parseInt(idParamAjax);
    java.sql.Date dateAjax = null;
    try { dateAjax = java.sql.Date.valueOf(dateStrAjax); } catch (Exception e) { out.print("<div style='color:red'>Invalid date</div>"); return; }
    java.util.List<models.CaregiverAvailability> slotsAjax = new java.util.ArrayList<>();
    try {
        slotsAjax = models.CaregiverAvailability.getAvailableTimeslots(productIdAjax, dateAjax);
    } catch (Exception e) {
        out.print("<div style='color:red'>Error loading timeslots</div>");
        return;
    }
    if (slotsAjax == null || slotsAjax.isEmpty()) {
        out.print("<div style='color:#888'>No available timeslots for this date.</div>");
    } else {
        out.print("<label style='font-weight:bold;'>Available Timeslots (caregiver shown):</label><br>");
        out.print("<select id='timeslotSelect' name='timeslotSelect' required onchange='onTimeslotChange(this.value)' style='padding:10px; font-size:16px; border-radius:10px; border:2px solid #ccc; width:100%; max-width:400px;'>");
        for (models.CaregiverAvailability slot : slotsAjax) {
            String slotStr = slot.getStartTime().toString().substring(0,5) + " - " + slot.getEndTime().toString().substring(0,5);
            models.Caregiver cg = null;
            try { cg = models.Caregiver.getCaregiverById(slot.getCaregiverId()); } catch (Exception e) { /* ignore */ }
            String caregiverName = (cg != null) ? cg.getFullName() : "Caregiver #" + slot.getCaregiverId();
            String optVal = slot.getAvailabilityId() + "|" + slot.getCaregiverId() + "|" + slot.getStartTime() + "|" + slot.getEndTime() + "|" + slot.getAvailabilityDate();
            out.print("<option value='" + optVal + "'>" + slotStr + " — " + caregiverName + "</option>");
        }
        out.print("</select>");
        out.print("<div style='margin-top:8px;font-size:13px;color:#666;'>Selected timeslot will assign the caregiver shown above.</div>");
    }
    return;
}
%>
<%-- AJAX handler moved to top of file to avoid returning full page for XHR requests --%>
<html>
<head>
<meta charset="UTF-8">
<title>Service Details</title>

<style>
    body {
        margin: 0;
        font-family: "Georgia", serif;
        background: white;
    }

    .container {
        width: 90%;
        margin: 40px auto;
        display: flex;
        gap: 50px;
        align-items: flex-start;
    }
    
	.error {
	    margin: 20px auto;
	    width: fit-content;
	    padding: 14px 22px;
	    color: #555;                
	    font-size: 16px;
	    font-family: "Georgia", serif;
	    text-align: center;
	}


    .image-box {
        width: 50%;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 4px 18px rgba(0,0,0,0.1);
        border: 2px solid black;
    }

    .image-box img {
        width: 100%;
        height: 500px;
        object-fit: fill;
    }

    .info-box {
        width: 50%;
        padding-right: 20px;
    }

    .category {
        font-size: 20px;
        color: #666;
        font-style: italic;
        margin-bottom: 10px;
    }

    .title {
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .price {
        font-size: 28px;
        font-weight: bold;
        margin-bottom: 25px;
    }

    .section-title {
        font-size: 22px;
        margin-bottom: 10px;
    }

    .description {
        font-size: 18px;
        line-height: 1.5;
        margin-bottom: 35px;
        max-width: 600px;
    }

    .login-warning {
        padding: 15px;
        border: 2px solid red;
        background: #ffe5e5;
        color: red;
        width: fit-content;
        border-radius: 10px;
        margin-top: 20px;
        font-weight: bold;
    }

    .add-btn {
        background: #ff8aa1;
        padding: 14px 32px;
        border-radius: 25px;
        text-decoration: none;
        color: black;
        font-weight: bold;
        border: 2px solid black;
        font-size: 18px;
        display: inline-block;
        transition: 0.2s ease;
    }

    .add-btn:hover {
        transform: translateY(-2px);
    }
    
    .view-cart-btn {
        background: white;
        padding: 12px 28px;
        border-radius: 25px;
        text-decoration: none;
        color: black;
        font-weight: bold;
        border: 2px solid black;
        font-size: 16px;
        display: inline-block;
        margin-left: 15px;
        transition: 0.2s ease;
    }
    
    .view-cart-btn:hover {
        background: #f0f0f0;
        transform: translateY(-2px);
    }
</style>

</head>
<body>

<%@ include file="/WEB-INF/components/user/userNavBar.jsp" %>

<%
    // Image map
    java.util.HashMap<Integer, String> imageMap = new java.util.HashMap<>();

	imageMap.put(1, request.getContextPath() + "/images/personalCare.png");
	imageMap.put(2, request.getContextPath() + "/images/personalCare.png");
	imageMap.put(3, request.getContextPath() + "/images/medicalMonitoring.png");
	imageMap.put(4, request.getContextPath() + "/images/medication.png");
	imageMap.put(5, request.getContextPath() + "/images/companionship.png");
	imageMap.put(6, request.getContextPath() + "/images/companionship.png");
	imageMap.put(7, request.getContextPath() + "/images/housekeeping.png");
	imageMap.put(8, request.getContextPath() + "/images/mealPrep.png");
	imageMap.put(9, request.getContextPath() + "/images/transportMed.png");
	imageMap.put(10, request.getContextPath() + "/images/transportShop.png");

    String defaultImg = request.getContextPath() + "/images/default.png";

    // Load product from DB
    String idParam = request.getParameter("id");
    if (idParam == null) {
    %>
        <div class="error">No services available...</div>
   <%
        return;
    }

    int productId = Integer.parseInt(idParam);

    Product product = null;
    try { product = Product.getProductById(productId); }
    catch (Exception e) { e.printStackTrace(); }

    if (product == null) {
  	%>
        <div class="error">Service not found...</div>
   <%
        return;
    }
%>

<div class="container">

    <!-- LEFT: IMAGE -->
    <div class="image-box">
        <img src="<%= imageMap.getOrDefault(product.getProductId(), defaultImg) %>">
    </div>

    <!-- RIGHT: DETAILS -->
    <div class="info-box">
        <div class="title"><%= product.getName() %></div>
        <div class="price">$<%= product.getPrice() %></div>

        <div class="section-title">Description</div>
        <div class="description"><%= product.getDescription() %></div>

        <%
        // Check if user is logged in (access request attribute directly)
        Integer currentUserId = (Integer) request.getAttribute("sessUserId");
        Integer currentRoleId = (Integer) request.getAttribute("sessRoleId");
        
        if (currentUserId != null && currentRoleId != null && (currentRoleId == 2 || currentRoleId == 3)) { 
        %>
            <!-- USER LOGGED IN & IS CLIENT & IS GUARDIAN→ SHOW "ADD TO CART" -->
            <form action="<%=request.getContextPath()%>/product/addToCart" method="post">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                
                <%
                    java.util.List<models.Caregiver> availableCaregivers = (java.util.List<models.Caregiver>) request.getAttribute("availableCaregivers");
                %>
                
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px;">Client ID (Optional):</label>
                    <input type="number" name="clientId" placeholder="Enter client ID" 
                           style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 200px;">
                </div>
                
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px; font-weight: bold;">Select Date:</label>
                    <input type="date" id="clientDate" name="clientDate" style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 100%; max-width: 400px;" onchange="showTimeslots()">
                    <div id="timeslotContainer" style="margin-top: 15px;"></div>
                    <!-- Hidden fields to capture selected caregiver and timeslot for addToCart -->
                    <input type="hidden" id="selectedCaregiverId" name="caregiverId" value="">
                    <input type="hidden" id="selectedTimeslot" name="timeslot" value="">
                    <input type="hidden" id="selectedTimeslotEnd" name="timeslotEnd" value="">
                    <input type="hidden" id="selectedAvailabilityId" name="availabilityId" value="">
                    <script>
                    function showTimeslots() {
                        var date = document.getElementById('clientDate').value;
                        var container = document.getElementById('timeslotContainer');
                        var addBtn = document.getElementById('addToCartBtn');
                        // clear previous selection and disable add button while loading
                        try {
                            document.getElementById('selectedCaregiverId').value = '';
                            document.getElementById('selectedTimeslot').value = '';
                            document.getElementById('selectedTimeslotEnd').value = '';
                            document.getElementById('selectedAvailabilityId').value = '';
                        } catch (e) { }
                        if (addBtn) addBtn.disabled = true;
                        if (!date) { container.innerHTML = ''; updateAddButtonState(); return; }
                        var xhr = new XMLHttpRequest();
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState == 4) {
                                if (xhr.status == 200) container.innerHTML = xhr.responseText;
                                else container.innerHTML = "<div style='color:red'>Error loading timeslots</div>";
                                // after insertion, ensure event handlers and button state are correct
                                updateAddButtonState();
                            }
                        };
                        xhr.open('GET', '<%=request.getContextPath()%>/services/details/viewDetails.jsp?id=<%=product.getProductId()%>&ajaxTimeslots=1&date=' + date, true);
                        xhr.send();
                    }

                    function onTimeslotChange(val) {
                        if (!val) {
                            document.getElementById('selectedCaregiverId').value = '';
                            document.getElementById('selectedTimeslot').value = '';
                            document.getElementById('selectedAvailabilityId').value = '';
                            updateAddButtonState();
                            return;
                        }
                        // value format: availabilityId|caregiverId|start|end|date
                        var parts = val.split('|');
                        var availabilityId = parts[0];
                        var caregiverId = parts[1];
                        var start = parts[2];
                        var end = parts[3];
                        var date = parts[4];
                        // set hidden field and, if a visible caregiver select exists, set that too
                        document.getElementById('selectedCaregiverId').value = caregiverId;
                        var vis = document.querySelector('select[name="caregiverId"]');
                        if (vis) {
                            try { vis.value = caregiverId; } catch (e) { /* ignore */ }
                        }
                        document.getElementById('selectedAvailabilityId').value = availabilityId;
                        // timeslot string format: YYYY-MM-DDTHH:MM (ISO datetime for booking start)
                        var timeslotStr = date + 'T' + start.substring(0,5);
                        var timeslotEndStr = date + 'T' + end.substring(0,5);
                        document.getElementById('selectedTimeslot').value = timeslotStr;
                        document.getElementById('selectedTimeslotEnd').value = timeslotEndStr;
                        // enable add button now that a timeslot is selected
                        var addBtn = document.getElementById('addToCartBtn');
                        if (addBtn) addBtn.disabled = false;
                    }

                    function updateAddButtonState() {
                        var addBtn = document.getElementById('addToCartBtn');
                        if (!addBtn) return;

                        // If the injected timeslot select exists, and has a value, use it to populate hidden fields
                        var sel = document.getElementById('timeslotSelect');
                        if (sel && sel.value) {
                            // populate hidden fields from the select's current value
                            try { onTimeslotChange(sel.value); } catch (e) { /* ignore */ }
                            addBtn.disabled = false;
                            return;
                        }

                        var ts = document.getElementById('selectedTimeslot');
                        if (ts && ts.value && ts.value.trim() !== '') addBtn.disabled = false;
                        else addBtn.disabled = true;
                    }

                    document.addEventListener('DOMContentLoaded', function(){ updateAddButtonState(); });
                    </script>
                </div>
                
                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 16px; margin-bottom: 5px;">Special Requests (Optional):</label>
                    <textarea name="specialRequests" placeholder="Any special requirements..." 
                              style="padding: 10px; font-size: 16px; border: 2px solid #ccc; border-radius: 10px; width: 100%; max-width: 500px; min-height: 80px; font-family: 'Georgia', serif;"></textarea>
                </div>
                
                <button type="submit" id="addToCartBtn" class="add-btn">Add To Cart</button>
                <a href="<%=request.getContextPath()%>/product/viewCart" class="view-cart-btn">View Cart</a>
            </form>
        
        <% } else { %>
        
            <!-- NOT LOGGED IN OR WRONG ROLE -->
            <div class="login-warning">
                <% if (currentUserId == null) { %>
                    Login as a client guardian to add this service to your cart.
                <% } else if (currentRoleId != null && currentRoleId != 2 && currentRoleId != 3) { %>
                    Only clients and guardian can add services to cart.
                <% } %>
            </div>
        
        <% } %>


    </div>

</div>

</body>
</html>

