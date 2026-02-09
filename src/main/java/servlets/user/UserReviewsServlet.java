package servlets.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;

import lib.SessionManagement;
import models.Reviews;

@WebServlet("/reviews")
public class UserReviewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isClient(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");

        // 1) VIEW ALL
        if (action == null) {
            try {
                ArrayList<Reviews> reviews = Reviews.getAllWithNames();
                request.setAttribute("reviews", reviews);
                request.setAttribute("sessUserId", SessionManagement.getUserId(request));
                request.getRequestDispatcher("/reviews/index.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/reviews?msg=db_error");
            }
            return;
        }

        // 2) ADD PAGE
        if ("add".equals(action)) {
            request.getRequestDispatcher("/WEB-INF/components/user/addReview.jsp").forward(request, response);
            return;
        }

        // 3) EDIT PAGE 
        if ("edit".equals(action)) {
            String idStr = request.getParameter("feedbackId");
            try {
                int feedbackId = Integer.parseInt(idStr);
                Reviews f = Reviews.getById(feedbackId);
                if (f == null) {
                    response.sendRedirect(request.getContextPath() + "/reviews?msg=not_found");
                    return;
                }

                request.setAttribute("feedback", f);
                request.getRequestDispatcher("/WEB-INF/components/user/editReview.jsp").forward(request, response);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/reviews?msg=invalid");
            }
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isClient(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) { handleAdd(request, response); return; }
        if ("edit".equals(action)) { handleEdit(request, response); return; }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int overallRating = Integer.parseInt(request.getParameter("overall_rating"));
            int caregiverRating = Integer.parseInt(request.getParameter("caregiver_rating"));
            int caregiverId = Integer.parseInt(request.getParameter("caregiver_id"));
            int productId = Integer.parseInt(request.getParameter("product_id"));
            String comments = request.getParameter("comments");

            if (overallRating < 1 || overallRating > 5 || caregiverRating < 1 || caregiverRating > 5) {
                response.sendRedirect(request.getContextPath() + "/reviews?msg=invalid");
                return;
            }

            int userId = SessionManagement.getUserId(request);

            boolean ok = Reviews.create(userId, overallRating, caregiverRating, comments, caregiverId, productId);
            response.sendRedirect(request.getContextPath() + "/reviews?msg=" + (ok ? "added" : "db_error"));

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/reviews?msg=invalid");
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("feedbackId");

        try {
            int feedbackId = Integer.parseInt(idStr);
            int caregiverId = Integer.parseInt(request.getParameter("caregiver_id"));
            int productId = Integer.parseInt(request.getParameter("product_id"));
            int overallRating = Integer.parseInt(request.getParameter("overall_rating"));
            int caregiverRating = Integer.parseInt(request.getParameter("caregiver_rating"));
            String comments = request.getParameter("comments");

            if (overallRating < 1 || overallRating > 5 || caregiverRating < 1 || caregiverRating > 5) {
                response.sendRedirect(request.getContextPath() + "/reviews?action=edit&feedbackId=" + idStr + "&msg=invalid");
                return;
            }

            int userId = SessionManagement.getUserId(request);

            boolean ok = Reviews.update(feedbackId, userId, overallRating, caregiverRating, comments, caregiverId, productId);

            response.sendRedirect(request.getContextPath() + "/reviews?action=edit&feedbackId=" + idStr +
                    "&msg=" + (ok ? "updated" : "forbidden"));

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/reviews?action=edit&feedbackId=" + idStr + "&msg=invalid");
        }
    }
}

