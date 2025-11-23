package servlets.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import db.JDBC;
import lib.SessionManagement;

@WebServlet("/reviews")
public class UserReviewsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Role check (same style as AdminServicesServlet)
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isClient(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");

        // --- 1) VIEW ALL REVIEWS ---
        if (action == null) {
            request.getRequestDispatcher("/reviews/index.jsp")
                   .forward(request, response);
            return;
        }

        // --- 2) ADD REVIEW PAGE ---
        if (action.equals("add")) {
            request.getRequestDispatcher("/WEB-INF/components/user/addReview.jsp")
                   .forward(request, response);
            return;
        }
        
        if (action.equals("edit")) {
            request.getRequestDispatcher("/WEB-INF/components/user/editReview.jsp")
                   .forward(request, response);
            return;
        }
        
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Role check
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isClient(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            handleAdd(request, response);
            return;
        }
        
        if ("edit".equals(action)) {
            handleEdit(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {

    	// 1. Read form fields
        String overallStr = request.getParameter("overall_rating");
        String caregiverStr = request.getParameter("caregiver_rating");
        String caregiverIdStr = request.getParameter("caregiver_id");
        String productIdStr = request.getParameter("product_id");
        String comments = request.getParameter("comments");

        // 2. Validate empty fields 
        if (overallStr == null || caregiverStr == null ||
                caregiverIdStr == null || productIdStr == null ||
                overallStr.isEmpty() || caregiverStr.isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/user/reviews?msg=invalid");
            return;
        }

        int overallRating;
        int caregiverRating;
        int caregiverId;
        int productId;

        try {
            overallRating = Integer.parseInt(overallStr);
            caregiverRating = Integer.parseInt(caregiverStr);
            caregiverId = Integer.parseInt(caregiverIdStr);
            productId = Integer.parseInt(productIdStr);

            if (overallRating < 1 || overallRating > 5 ||
                caregiverRating < 1 || caregiverRating > 5) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user/reviews?msg=invalid");
            return;
        }
        
        Integer userId = SessionManagement.getUserId(request);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql =
            	    "INSERT INTO feedback (user_id, overall_rating, caregiver_rating, comments, caregiver_id, product_id, created_at) " +
            	    "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";


            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, overallRating);
            pstmt.setInt(3, caregiverRating);
            pstmt.setString(4, comments != null ? comments.trim() : null);
            pstmt.setInt(5, caregiverId);
            pstmt.setInt(6, productId);

            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Insert failed");

            response.sendRedirect(request.getContextPath() + "/user/reviews?msg=added");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user/reviews?msg=db_error");

        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
    
    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("feedbackId");
        String caregiverStr = request.getParameter("caregiver_id");
        String productStr = request.getParameter("product_id");
        String overallStr = request.getParameter("overall_rating");
        String caregiverRatingStr = request.getParameter("caregiver_rating");
        String comments = request.getParameter("comments");

        if (idStr == null || caregiverStr == null || productStr == null ||
            overallStr == null || caregiverRatingStr == null) {

            response.sendRedirect(request.getContextPath()
                    + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=invalid");
            return;
        }

        int feedbackId, overallRating, caregiverRating, caregiverId, productId;

        try {
            feedbackId = Integer.parseInt(idStr);
            overallRating = Integer.parseInt(overallStr);
            caregiverRating = Integer.parseInt(caregiverRatingStr);
            caregiverId = Integer.parseInt(caregiverStr);
            productId = Integer.parseInt(productStr);
            
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=invalid");
            return;
        }

        // Bounds check
        if (overallRating < 1 || overallRating > 5 || caregiverRating < 1 || caregiverRating > 5) {
            response.sendRedirect(request.getContextPath() + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=invalid");
            return;
        }

        Integer userId = SessionManagement.getUserId(request);

        try (Connection conn = JDBC.connect()) {

            String sql =
                    "UPDATE feedback SET overall_rating = ?, caregiver_rating = ?, comments = ?, caregiver_id = ?, product_id = ?, created_at = CURRENT_TIMESTAMP " +
                    "WHERE feedback_id = ? AND user_id = ?";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, overallRating);
            pstmt.setInt(2, caregiverRating);
            pstmt.setString(3, comments != null ? comments.trim() : null);
            pstmt.setInt(4, caregiverId);
            pstmt.setInt(5, productId);
            pstmt.setInt(6, feedbackId);
            pstmt.setInt(7, userId);

            int rows = pstmt.executeUpdate();

            if (rows == 0) {
                // Either not found OR user does not own the review
                response.sendRedirect(request.getContextPath() + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=forbidden");
            } else {
                response.sendRedirect(request.getContextPath() + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=updated");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user/reviews?action=edit&feedbackId=" + idStr + "&msg=db_error");
        }
    }
}
