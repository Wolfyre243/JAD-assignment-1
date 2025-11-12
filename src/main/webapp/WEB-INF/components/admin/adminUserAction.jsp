<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/components/auth/protected.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure handler to activate/deactivate user account using JDBC utility and AuthServlet session
--%>
<%
    // === INPUT VALIDATION ===
    String action = request.getParameter("action");
    String userIdStr = request.getParameter("userId");

    if (userIdStr == null || userIdStr.trim().isEmpty() ||
        !("activate".equals(action) || "deactivate".equals(action))) {
        response.sendRedirect("adminUsers.jsp?msg=invalid");
        return;
    }

    int targetUserId;
    try {
        targetUserId = Integer.parseInt(userIdStr.trim());
        // Check if trying to deactivate themselves
        if (targetUserId == sessUserId) {
            response.sendRedirect("adminUsers.jsp?msg=self_action_denied");
            return;
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("adminUsers.jsp?msg=invalid");
        return;
    }

    boolean newStatus = "activate".equals(action);

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // === JDBC: Update user status using utility class ===
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        String sql =
            "UPDATE \"user\" SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setBoolean(1, newStatus);
        pstmt.setInt(2, targetUserId);

        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            response.sendRedirect("adminUsers.jsp?msg=not_found");
        } else {
            response.sendRedirect("adminUsers.jsp?msg=" + action + "d");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("adminUsers.jsp?msg=db_error");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminUsers.jsp?msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>