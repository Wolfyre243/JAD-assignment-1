package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import handlers.AdminServiceHandler;
import lib.SessionManagement;

@WebServlet("/admin/service")
public class AdminServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        // If no action parameter is present, delegate to the AdminPanel listing which
        // prepares `services`, `categories` and handles include=add|edit views.
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String include = request.getParameter("include");
            try {
                String target = request.getContextPath() + "/admin/services";
                if (include != null && !include.trim().isEmpty()) {
                    target += "?include=" + URLEncoder.encode(include, "UTF-8");
                }
                response.sendRedirect(target);
            } catch (UnsupportedEncodingException e) {
                response.sendRedirect(request.getContextPath() + "/admin/services");
            }
            return;
        }

        // Only support activate/deactivate as GET actions
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty() || !("activate".equals(action) || "deactivate".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        boolean newStatus = "activate".equals(action);
        try {
            boolean ok = AdminServiceHandler.setServiceActive(productId, newStatus);
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=" + action + "d");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
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
        } else if ("edit".equals(action)) {
            handleEdit(request, response);
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

        try {
            boolean ok = AdminServiceHandler.addService(categoryId, name.trim(), description != null ? description.trim() : null, price, isActive);
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=added");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String productIdStr = request.getParameter("productId");
        String name = request.getParameter("name");
        String categoryIdStr = request.getParameter("categoryId");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String isActiveStr = request.getParameter("isActive");

        if (productIdStr == null || productIdStr.trim().isEmpty() || name == null || name.trim().isEmpty() || categoryIdStr == null || priceStr == null || isActiveStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        int productId;
        int categoryId;
        double price;
        try {
            productId = Integer.parseInt(productIdStr);
            categoryId = Integer.parseInt(categoryIdStr);
            price = Double.parseDouble(priceStr);
            if (price < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=invalid");
            return;
        }

        boolean isActive = Boolean.parseBoolean(isActiveStr);

        try {
            boolean ok = AdminServiceHandler.updateService(productId, categoryId, name.trim(), description != null ? description.trim() : null, price, isActive);
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=not_found");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/services?msg=updated");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/services?msg=db_error");
        }
    }
}
