<%--
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 18/11/2025
  Description: A dropdown to display user information
--%>

<style>
.profile-btn-container {
	display: inline-block;
}

.profile-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 50%;
	transition: all 0.3s ease;
	text-decoration: none;
}

.profile-btn:hover {
	background: #ffa8c0;
	box-shadow: 0 8px 20px rgba(255, 140, 180, 0.4);
}

.profile-btn img {
	filter: brightness(0) invert(0); /* keeps icon black */
	transition: transform 0.3s;
}
</style>
<a href="${pageContext.request.contextPath}/profile/"
	title="View My Profile" class="profile-btn"> <img
	src="https://cdn-icons-png.flaticon.com/512/6522/6522516.png"
	alt="Profile" width="26" height="26">
</a>