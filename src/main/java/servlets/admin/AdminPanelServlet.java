package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lib.SessionManagement;

@WebServlet({"/admin/dashboard","/admin/users","/admin/services","/admin/orders","/admin/feedback"})
public class AdminPanelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        final String path = request.getServletPath();
        String includeFile = "/WEB-INF/components/admin/adminDashboard.jsp";
        String active = "dashboard";

        switch (path) {
            case "/admin/users":
                includeFile = "/WEB-INF/components/admin/adminUsers.jsp";
                active = "users";
                break;
            case "/admin/services":
                includeFile = "/WEB-INF/components/admin/adminServices.jsp";
                active = "services";
                break;
            case "/admin/orders":
                includeFile = "/WEB-INF/components/admin/adminOrders.jsp";
                active = "orders";
                break;
            case "/admin/feedback":
                includeFile = "/WEB-INF/components/admin/adminFeedback.jsp";
                active = "feedback";
                break;
            default:
                includeFile = "/WEB-INF/components/admin/adminDashboard.jsp";
                active = "dashboard";
        }

        // support showing sub-views (add/edit) via ?include=add or include=edit
        String includeParam = request.getParameter("include");
        if (includeParam != null) {
            if ("add".equals(includeParam) && "/admin/services".equals(path)) {
                includeFile = "/WEB-INF/components/admin/adminAddService.jsp";
                active = "services";
            } else if ("edit".equals(includeParam) && "/admin/services".equals(path)) {
                includeFile = "/WEB-INF/components/admin/adminEditService.jsp";
                active = "services";
            }
        }

        request.setAttribute("includeFile", includeFile);
        request.setAttribute("activePage", active);
        request.getRequestDispatcher("/admin/dashboard/index.jsp").forward(request, response);
    }
}
