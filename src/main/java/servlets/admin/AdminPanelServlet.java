package servlets.admin;

import jakarta.servlet.ServletException;
import java.sql.SQLException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lib.SessionManagement;

@WebServlet({"/admin/dashboard","/admin/dashboard/","/admin/users","/admin/services","/admin/orders","/admin/feedback"})
public class AdminPanelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionManagement.isLoggedIn(request) || !SessionManagement.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

    final String rawPath = request.getServletPath();
    final String path = (rawPath != null && rawPath.endsWith("/") && rawPath.length() > 1) ? rawPath.substring(0, rawPath.length() - 1) : rawPath;
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
            } else if ("details".equals(includeParam) && "/admin/orders".equals(path)) {
                // show the order details partial when requested
                includeFile = "/WEB-INF/components/admin/adminOrderDetails.jsp";
                active = "orders";
            } else if ("delete".equals(includeParam) && "/admin/feedback".equals(path)) {
                includeFile = "/WEB-INF/components/admin/adminDeleteFeedback.jsp";
                active = "feedback";
            }
        }

        // Prepare data for views via handlers
        try {
            if ("/admin/services".equals(path)) {
                java.util.List<java.util.Map<String,Object>> services = handlers.AdminServiceHandler.listServices();
                request.setAttribute("services", services);
            }

            if ("/admin/users".equals(path)) {
                java.util.List<java.util.Map<String,Object>> users = handlers.AdminUserHandler.listUsers();
                request.setAttribute("users", users);
                // provide current user id for UI logic (e.g., disabling self-deactivate)
                Object uidObj = request.getSession(false) != null ? request.getSession(false).getAttribute("userId") : null;
                if (uidObj instanceof Integer) request.setAttribute("currentUserId", (Integer) uidObj);
            }

            if ("/admin/feedback".equals(path)) {
                // Get filter parameters
                String productIdParam = request.getParameter("productId");
                String caregiverIdParam = request.getParameter("caregiverId");
                Integer productIdFilter = null;
                Integer caregiverIdFilter = null;
                
                if (productIdParam != null && !productIdParam.trim().isEmpty() && !"all".equals(productIdParam)) {
                    try {
                        productIdFilter = Integer.parseInt(productIdParam);
                    } catch (NumberFormatException e) {
                        // Ignore invalid productId
                    }
                }
                
                if (caregiverIdParam != null && !caregiverIdParam.trim().isEmpty() && !"all".equals(caregiverIdParam)) {
                    try {
                        caregiverIdFilter = Integer.parseInt(caregiverIdParam);
                    } catch (NumberFormatException e) {
                        // Ignore invalid caregiverId
                    }
                }
                
                // Get filtered feedback
                java.util.List<java.util.Map<String,Object>> feedbacks = handlers.AdminFeedbackHandler.listFeedback(productIdFilter, caregiverIdFilter);
                request.setAttribute("feedbacks", feedbacks);
                
                // Get all products for filter dropdown
                java.util.List<java.util.Map<String,Object>> products = handlers.AdminFeedbackHandler.listAllProducts();
                request.setAttribute("products", products);
                
                // Get all caregivers for filter dropdown
                java.util.List<java.util.Map<String,Object>> caregivers = handlers.AdminFeedbackHandler.listAllCaregivers();
                request.setAttribute("caregivers", caregivers);
                
                // Pass the current filter selections
                request.setAttribute("selectedProductId", productIdParam != null ? productIdParam : "all");
                request.setAttribute("selectedCaregiverId", caregiverIdParam != null ? caregiverIdParam : "all");
            }

            if ("/admin/orders".equals(path)) {
                java.util.List<java.util.Map<String,Object>> orders = handlers.AdminOrderHandler.listOrders();
                request.setAttribute("orders", orders);
            }

            // Load dashboard stats. Use a relaxed check so variants like "/admin/dashboard/"
            // or servletPath mappings still cause stats to be loaded.
            if ("/admin/dashboard".equals(path) || (rawPath != null && rawPath.contains("/admin/dashboard"))) {
                java.util.Map<String,Integer> stats = handlers.AdminDashboardHandler.getStats();
                request.setAttribute("stats", stats);
            }

            // if showing add form, provide categories
            if (includeParam != null && "add".equals(includeParam) && "/admin/services".equals(path)) {
                java.util.List<java.util.Map<String,Object>> categories = handlers.AdminServiceHandler.listCategories();
                request.setAttribute("categories", categories);
            }
            // if showing edit form, also provide categories and the existing product data
            if (includeParam != null && "edit".equals(includeParam) && "/admin/services".equals(path)) {
                java.util.List<java.util.Map<String,Object>> categories = handlers.AdminServiceHandler.listCategories();
                request.setAttribute("categories", categories);

                // try to load the specific service requested via ?productId=...
                String productIdStr = request.getParameter("productId");
                if (productIdStr != null && !productIdStr.trim().isEmpty()) {
                    try {
                        int pid = Integer.parseInt(productIdStr.trim());
                        java.util.Map<String,Object> service = handlers.AdminServiceHandler.getServiceById(pid);
                        if (service != null) {
                            request.setAttribute("service", service);
                        } else {
                            request.setAttribute("serviceError", "Service not found");
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("serviceError", "Invalid product id");
                    }
                } else {
                    request.setAttribute("serviceError", "No product id provided");
                }
            }

            // if showing order details via include=details and orderId param, provide order data
            if (includeParam != null && "details".equals(includeParam) && "/admin/orders".equals(path)) {
                String orderIdStr = request.getParameter("orderId");
                if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                    try {
                        int oid = Integer.parseInt(orderIdStr.trim());
                        java.util.Map<String,Object> order = handlers.AdminOrderHandler.getOrderDetails(oid);
                        if (order != null) {
                            request.setAttribute("order", order);
                        } else {
                            request.setAttribute("orderError", "Order not found");
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("orderError", "Invalid order id");
                    }
                } else {
                    request.setAttribute("orderError", "No order id provided");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Make sure views render instead of showing 'data not available' by providing empty fallbacks
            request.setAttribute("servicesError", "Failed to load data");
            // ensure lists/maps exist so JSPs render gracefully
            request.setAttribute("services", new java.util.ArrayList<java.util.Map<String,Object>>() );
            request.setAttribute("users", new java.util.ArrayList<java.util.Map<String,Object>>() );
            request.setAttribute("feedbacks", new java.util.ArrayList<java.util.Map<String,Object>>() );
            request.setAttribute("orders", new java.util.ArrayList<java.util.Map<String,Object>>() );
            java.util.Map<String,Integer> emptyStats = new java.util.HashMap<>();
            emptyStats.put("totalUsers", 0);
            emptyStats.put("totalOrders", 0);
            emptyStats.put("totalFeedback", 0);
            emptyStats.put("totalProducts", 0);
            request.setAttribute("stats", emptyStats);
            // ensure order error is set so the order-details jsp shows a clear message
            request.setAttribute("orderError", "Failed to load order data");
        }

        request.setAttribute("includeFile", includeFile);
        request.setAttribute("activePage", active);
        request.getRequestDispatcher("/admin/dashboard/index.jsp").forward(request, response);
    }
}
