<%--
 - Name: Goh Yi Xin Karys
 - Admin No: P2424431
 - Class: DIT/FT/2B/01
 - Description: Admin dashboard main index page routing to AdminPanelServlet
 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/protected.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard | SilverCare</title>

<style>
  /* Admin theme: match the look of login/register/landing pages */
  body { 
    font-family: "Georgia", serif !important; 
    background: #ffffff !important;
    margin: 0;
  }
  
  /* Background image like login page */
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
  
  .admin-card {
    max-width: 980px;
    margin: 36px auto;
    background: #ffdce4;
    padding: 40px 50px;
    border-radius: 30px;
    box-shadow: 0 6px 24px rgba(0,0,0,0.15);
  }
  
  .admin-card h1 { 
    font-size: 36px; 
    font-weight: bold;
    margin-top: 0;
    margin-bottom: 10px;
    color: #222;
  }
  
  .admin-card h2 { 
    font-size: 24px; 
    font-weight: 600;
    margin-top: 30px;
    margin-bottom: 15px;
    color: #333;
  }
  
  .admin-card hr {
    border: none;
    border-top: 2px solid #333;
    margin: 20px 0;
  }
  
  .admin-card p {
    font-size: 18px;
    line-height: 1.6;
  }
  
  /* Tables */
  .admin-card table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
    background: white;
    border-radius: 12px;
    overflow: hidden;
  }
  
  .admin-card table th {
    background: #ffbfd0;
    padding: 14px 16px;
    font-weight: bold;
    text-align: left;
    font-size: 17px;
  }
  
  .admin-card table td {
    padding: 12px 16px;
    border-bottom: 1px solid #f0f0f0;
    font-size: 16px;
  }
  
  .admin-card table tr:last-child td {
    border-bottom: none;
  }
  
  .admin-card table tr:hover {
    background: #fff8f9;
  }
  
  /* Links and buttons */
  .admin-card a {
    color: #b3003b;
    text-decoration: none;
    font-weight: 600;
  }
  
  .admin-card a:hover {
    text-decoration: underline;
  }
  
  .admin-card a.btn, .admin-card button.btn {
    display: inline-block;
    background: #ffbfd0;
    color: #000;
    padding: 10px 22px;
    border-radius: 20px;
    text-decoration: none;
    font-weight: bold;
    font-size: 16px;
    border: none;
    cursor: pointer;
    font-family: "Georgia", serif;
    transition: background 0.2s;
  }
  
  .admin-card a.btn:hover, .admin-card button.btn:hover {
    background: #ff9fb7;
    text-decoration: none;
  }
  
  .admin-card a.btn-secondary {
    background: #f0f0f0;
    color: #333;
  }
  
  .admin-card a.btn-secondary:hover {
    background: #e0e0e0;
  }
  
  /* Lists */
  .admin-card ul {
    list-style-position: inside;
    padding-left: 0;
  }
  
  .admin-card li {
    margin: 10px 0;
    font-size: 18px;
  }
  
  /* Messages */
  .msg-success {
    color: #2d7a2d;
    font-weight: bold;
    background: #d4edda;
    padding: 12px 18px;
    border-radius: 8px;
    margin: 15px 0;
  }
  
  .msg-error {
    color: #a94442;
    font-weight: bold;
    background: #f2dede;
    padding: 12px 18px;
    border-radius: 8px;
    margin: 15px 0;
  }
  
  /* Status classes */
  .status-active {
    color: #2d7a2d;
    font-weight: bold;
  }
  
  .status-inactive {
    color: #a94442;
    font-weight: bold;
  }
  
  /* Form elements */
  .admin-card label {
    display: block;
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 6px;
    margin-top: 15px;
  }
  
  .admin-card input[type="text"],
  .admin-card input[type="email"],
  .admin-card input[type="number"],
  .admin-card input[type="date"],
  .admin-card input[type="password"],
  .admin-card textarea,
  .admin-card select {
    width: 100%;
    padding: 12px;
    font-size: 16px;
    font-family: "Georgia", serif;
    margin-bottom: 15px;
    border-radius: 12px;
    border: 1px solid #999;
    background: #f6f6f6;
    box-sizing: border-box;
  }
  
  .admin-card textarea {
    min-height: 100px;
    resize: vertical;
  }
</style>
</head>

<body>

	<!-- Background image like login page -->
	<div class="bg-photo"></div>

	<!-- Use the same navbar as login/register -->
	<jsp:include page="/WEB-INF/components/user/userNavBar.jsp"></jsp:include>

	<div class="admin-card">
	<%
		String inc = (String) request.getAttribute("includeFile");
		if (inc != null && !inc.isEmpty()) {
	%>
		<jsp:include page="<%= inc %>" />
	<%
		} else {
	%>
		<jsp:include page="/WEB-INF/components/admin/adminDashboard.jsp" />
	<%
		}
	%>
	</div>

</body>
</html>
