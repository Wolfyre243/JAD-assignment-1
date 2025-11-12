<!-- 
Page: /auth/register
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/user-session.jsp"%>
<%
// If user is logged in, redirect to landing page
if (sessUserId != null) {
	response.sendRedirect(request.getContextPath() + "/");
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register Page</title>

<!-- Tailwind CSS CDN (Play CDN - latest) -->
<script src="https://cdn.tailwindcss.com"></script>

<style>
body {
	background: linear-gradient(to bottom right, #f3f4f6, #e5e7eb);
	min-height: 100vh;
	font-family: 'Inter', sans-serif;
}

.card {
	backdrop-filter: blur(12px);
	background: rgba(255, 255, 255, 0.9);
	border: 1px solid rgba(229, 231, 235, 0.8);
}

.input-focus:focus {
	outline: none;
	ring: 2px solid #3b82f6;
	box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}
</style>
</head>
<body class="flex items-center justify-center p-4">
	<div class="w-full max-w-md">
		<div class="card rounded-2xl shadow-lg p-8">

			<h1 class="text-2xl font-bold text-center text-gray-800 mb-6">Create
				Your Account</h1>

			<!-- Error Message -->


			<form action="${pageContext.request.contextPath}/auth/register"
				method="post" class="space-y-5">

				<!-- Full Name -->
				<div>
					<label for="name"
						class="block text-sm font-medium text-gray-700 mb-1"> Full
						Name <span class="text-red-500">*</span>
					</label> <input type="text" id="name" name="name"
						class="w-full px-4 py-2.5 border border-gray-300 rounded-lg input-focus transition"
						required maxlength="100">
				</div>

				<!-- Email -->
				<div>
					<label for="email"
						class="block text-sm font-medium text-gray-700 mb-1">
						Email Address <span class="text-red-500">*</span>
					</label> <input type="email" id="email" name="email"
						class="w-full px-4 py-2.5 border border-gray-300 rounded-lg input-focus transition"
						required maxlength="255">
				</div>

				<!-- Password -->
				<div>
					<label for="password"
						class="block text-sm font-medium text-gray-700 mb-1">
						Password <span class="text-red-500">*</span>
					</label> <input type="password" id="password" name="password"
						class="w-full px-4 py-2.5 border border-gray-300 rounded-lg input-focus transition"
						required>
					<p class="text-xs text-gray-500 mt-1">Minimum 8 characters</p>
				</div>

				<!-- User Type Dropdown -->
				<div>
					<label for="userType"
						class="block text-sm font-medium text-gray-700 mb-1"> I am
						<span class="text-red-500">*</span>
					</label> <select id="userType" name="userType"
						class="w-full px-4 py-2.5 border border-gray-300 rounded-lg input-focus transition"
						required>
						<option value="" disabled>-- Select --</option>
						<option value="2">A client</option>
						<option value="3">A guardian</option>
					</select>
				</div>

				<!-- Terms & Conditions -->
				<div class="flex items-start space-x-2">
					<input type="checkbox" id="terms" name="terms"
						class="mt-1 h-4 w-4 text-blue-600 rounded border-gray-300"
						required> <label for="terms" class="text-sm text-gray-700">
						I have read and agree to the <strong> Terms and
							Conditions</strong>
					</label>
				</div>

				<!-- Submit Button -->
				<button type="submit"
					class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition duration-200">
					Register</button>
			</form>

			<div class="mt-6 text-center text-sm text-gray-600">
				Already have an account? <a
					href="${pageContext.request.contextPath}/auth/login/"
					class="text-blue-600 hover:underline font-medium">Log in</a>
			</div>
		</div>
	</div>
</body>
</html>