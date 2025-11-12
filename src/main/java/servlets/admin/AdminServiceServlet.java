package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import db.JDBC;
import lib.SessionManagement;

@WebServlet("/admin/service")
public class AdminServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle simple actions via query params (activate/deactivate)
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.trim().isEmpty() || !("activate".equals(action) || "deactivate".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/WEB-INF/components/admin/adminServices.jsp?msg=invalid");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/WEB-INF/components/admin/adminServices.jsp?msg=invalid");
            return;
        }

        boolean newStatus = "activate".equals(action);

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = "UPDATE product SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, newStatus);
            pstmt.setInt(2, productId);

            int rows = pstmt.executeUpdate();
            if (rows == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=" + action + "d");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/service?msg=db_error&redirect=services");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle add/edit via POST
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            handleAdd(request, response);
            return;
        }
        // Other POST actions can be implemented (edit)
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        String categoryIdStr = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String isActiveStr = request.getParameter("isActive");

        if (name == null || name.trim().isEmpty() || categoryIdStr == null || priceStr == null || isActiveStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/service?msg=invalid&redirect=add");
            return;
        }

        int categoryId;
        double price;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
            price = Double.parseDouble(priceStr);
            if (price < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/service?msg=invalid&redirect=add");
            return;
        }

        boolean isActive = Boolean.parseBoolean(isActiveStr);

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = JDBC.connect();
            if (conn == null) throw new SQLException("Connection failed");

            String sql = "INSERT INTO product (category_id, name, description, price, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, categoryId);
            pstmt.setString(2, name.trim());
            pstmt.setString(3, description != null ? description.trim() : null);
            pstmt.setDouble(4, price);
            pstmt.setBoolean(5, isActive);

            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Insert failed");

            response.sendRedirect(request.getContextPath() + "/admin/services?msg=added");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
