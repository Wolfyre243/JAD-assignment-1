<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.JDBC" %>
<%--
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 06/11/2025
  Description: Secure handler to delete feedback using JDBC utility and AuthServlet session
--%>
<%
    Integer adminId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");

    if (adminId == null || !"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }

    // === INPUT VALIDATION ===
    String feedbackIdStr = request.getParameter("feedbackId");
    if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
        response.sendRedirect("adminFeedback.jsp?msg=invalid");
        return;
    }

    int feedbackId;
    try {
        feedbackId = Integer.parseInt(feedbackIdStr.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("adminFeedback.jsp?msg=invalid");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // === JDBC: Delete feedback using utility class ===
        conn = JDBC.connect();
        if (conn == null) throw new SQLException("Connection failed");

        String sql = "DELETE FROM feedback WHERE feedback_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, feedbackId);

        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            response.sendRedirect("adminFeedback.jsp?msg=not_found");
        } else {
            response.sendRedirect("adminFeedback.jsp?msg=deleted");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("adminFeedback.jsp?msg=db_error");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminFeedback.jsp?msg=error");
    } finally {
        // === RESOURCE CLEANUP ===
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>