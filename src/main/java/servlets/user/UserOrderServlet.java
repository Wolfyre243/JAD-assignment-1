/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: User order servlet handling display of order history and individual order details
 */
package servlets.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import lib.SessionManagement;
import handlers.UserOrderHandler;

@WebServlet({"/user/orders", "/user/orders.jsp"})
public class UserOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check if user is logged in
        if (!SessionManagement.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login/");
            return;
        }

        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String view = request.getParameter("view"); // "list" or "details"
        String orderIdParam = request.getParameter("orderId");

        try {
            if ("details".equals(view) && orderIdParam != null) {
                // Show order details
                int orderId = Integer.parseInt(orderIdParam);
                Map<String, Object> orderDetails = UserOrderHandler.getOrderDetails(orderId, userId);
                
                if (orderDetails != null) {
                    request.setAttribute("orderDetails", orderDetails);
                    request.getRequestDispatcher("/WEB-INF/components/user/orderDetails.jsp")
                           .forward(request, response);
                } else {
                    request.setAttribute("error", "Order not found or access denied.");
                    request.getRequestDispatcher("/WEB-INF/components/user/myOrders.jsp")
                           .forward(request, response);
                }
            } else {
                // Show orders list (default)
                List<Map<String, Object>> orders = UserOrderHandler.getUserOrders(userId);
                request.setAttribute("orders", orders);
                request.getRequestDispatcher("/WEB-INF/components/user/myOrders.jsp")
                       .forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid order ID.");
            response.sendRedirect(request.getContextPath() + "/user/orders");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while loading orders.");
            request.getRequestDispatcher("/WEB-INF/components/user/myOrders.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
