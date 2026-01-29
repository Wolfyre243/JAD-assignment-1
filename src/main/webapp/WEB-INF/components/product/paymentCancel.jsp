<%--
  Name: Zhang Junkai
  Admin No: P2429634
  Class: DIT/FT/2B/01
  Description: Payment cancellation page shown when user cancels Stripe checkout
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payment Cancelled | SilverCare</title>
<style>
.cancel-container {
	width: 90%;
	max-width: 700px;
	margin: 60px auto;
	padding: 40px;
}

.cancel-card {
	background: #fff;
	border-radius: 24px;
	padding: 50px 40px;
	box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
	text-align: center;
	border: 1px solid #ffdce4;
}

.cancel-icon {
	font-size: 72px;
	color: #ff6b6b;
	margin-bottom: 20px;
}

.cancel-card h1 {
	font-size: 36px;
	color: #222;
	margin-bottom: 16px;
	font-weight: bold;
}

.lead-text {
	font-size: 20px;
	color: #555;
	margin-bottom: 24px;
	line-height: 1.5;
}

.action-buttons {
	margin: 40px 0 30px;
	display: flex;
	gap: 20px;
	justify-content: center;
	flex-wrap: wrap;
}

.btn {
	display: inline-block;
	padding: 14px 32px;
	font-size: 18px;
	font-weight: bold;
	text-decoration: none;
	border-radius: 30px;
	transition: all 0.25s ease;
	font-family: "Georgia", serif;
	cursor: pointer;
	border: 2px solid transparent;
}

.btn-primary {
	background: #ffbfd0;
	color: #222;
}

.btn-primary:hover {
	background: #ff9fb7;
	transform: translateY(-2px);
	box-shadow: 0 6px 16px rgba(255, 159, 183, 0.4);
}

.btn-secondary {
	background: #f0f0f0;
	color: #555;
	border: 2px solid #ccc;
}

.btn-secondary:hover {
	background: #e0e0e0;
	transform: translateY(-2px);
}

.help-text {
	font-size: 16px;
	color: #777;
	margin-top: 30px;
}

.link {
	color: #b3003b;
	text-decoration: none;
	font-weight: 600;
}

.link:hover {
	text-decoration: underline;
}
</style>
</head>
<body>
	<%@ include file="/WEB-INF/components/user/userNavBar.jsp"%>

	<div class="cancel-container">
		<div class="cancel-card">
			<div class="cancel-icon">✗</div>
			<h1>Payment Cancelled</h1>
			<p class="lead-text">Your payment process was not completed.</p>
			<p>No charges have been made to your card.</p>

			<div class="action-buttons">
				<a href="<%=request.getContextPath()%>/product/viewCart"
					class="btn btn-primary"> Return to Cart </a> <a
					href="<%=request.getContextPath()%>/services/"
					class="btn btn-secondary"> Continue Shopping </a>
			</div>

			<p class="help-text">If you experienced any issues during
				checkout, please contact our support team.</p>
		</div>
	</div>
</body>
</html>