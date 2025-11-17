<%-- Minimal header include: adds a simple nav and inline CSS for a consistent, minimal layout --%>
<%
  // Safe-include: nothing dynamic here except context path
  String ctx = request.getContextPath();
%>
<style>
  /* Minimalistic layout */
  body { font-family: Arial, Helvetica, sans-serif; margin:0; padding:0; background:#f7f7f8; color:#222; }
  .site-header { background: #fff; border-bottom: 1px solid #e6e6e6; padding: 12px 20px; }
  .site-container { max-width: 980px; margin: 24px auto; padding: 18px; background: #fff; box-shadow: 0 1px 2px rgba(0,0,0,0.03); }
  .site-title { display:inline-block; font-weight:600; color:#111; margin-right:20px; }
  .nav-links { display:inline-block; }
  .nav-links a { margin-right:12px; color:#0077cc; text-decoration:none; }
  .nav-links a:hover { text-decoration:underline; }
  .muted { color:#666; }
  table { width:100%; border-collapse:collapse; }
  th, td { padding:8px 10px; border:1px solid #e9e9e9; }
  .btn { display:inline-block; padding:6px 10px; background:#0077cc; color:#fff; text-decoration:none; border-radius:4px; }
  .btn.alt { background:#f0f0f0; color:#333; border:1px solid #ddd; }
  .msg-success { color: green; font-weight: bold; }
  .msg-error { color: red; font-weight: bold; }
</style>

<div class="site-header">
  <div class="site-container">
    <span class="site-title"><a href="<%= ctx %>/" style="color:inherit; text-decoration:none;">Silvercare</a></span>
    <span class="nav-links">
      <a href="<%= ctx %>/">Home</a>
      <a href="<%= ctx %>/product/viewCart">Cart</a>
      <a href="<%= ctx %>/admin/adminDashboard">Admin</a>
    </span>
    <jsp:include page="/WEB-INF/components/auth/logout-button.jsp"></jsp:include>
  </div>
</div>

<div class="site-container">
