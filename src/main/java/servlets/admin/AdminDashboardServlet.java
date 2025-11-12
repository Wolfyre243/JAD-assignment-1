package servlets.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import jakarta.servlet.http.HttpSession;
import lib.SessionManagement;

/**
 * Servlet implementation class AdminDashboardServlet
 */
@WebServlet("/admin/dashboard/")
public class AdminDashboardServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminDashboardServlet() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Check session and role
		HttpSession sess = request.getSession(false);
		if (sess == null || !SessionManagement.isLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/auth/login/");
			return;
		}

		if (!SessionManagement.isAdmin(request)) {
			// Not an admin - redirect to home
			response.sendRedirect(request.getContextPath() + "/");
			return;
		}

		// Forward to the admin dashboard JSP (JSP performs the DB queries)
		request.getRequestDispatcher("/WEB-INF/components/admin/adminDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
