package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

import java.io.IOException;

class AuthController {
  public static void login(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    final HttpSession session = request.getSession();
    
    final String email = request.getParameter("email");
    final String password = request.getParameter("password");

    try {
      // Get user from database
      final User user = User.getUserByEmail(email);
      // Validate credentials
      if (user == null || !user.getPassword().equals(password)) {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid email or password.");
        return;
      }

      final int userRoleId = user.getRole().getRoleId();
      final String userRoleName = user.getRole().getRoleName();
      // TODO: Send cookie instead
      session.setAttribute("userId", user.getUserId());
      session.setAttribute("userRoleId", userRoleId);
      session.setAttribute("userRoleName", userRoleName);

      // Update last_login timestamp for this user
      try {
        User.updateLastLogin(user.getUserId());
      } catch (Exception e) {
        // Log and continue; failing to update last_login should not block login
        e.printStackTrace();
      }

      response.setStatus(HttpServletResponse.SC_OK);
      // TODO: Redirect to dashboard or home page
      if (userRoleId == 1) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard/");
        return;
      }
      response.sendRedirect(request.getContextPath() + "/");
      return;

    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred during login.");
    }
  }
}

/**
 * Servlet implementation class AuthServlet
 */
@WebServlet({ "/auth/login", "/auth/register" })
public class AuthServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public AuthServlet() {
    super();
    // TODO Auto-generated constructor stub
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // TODO Auto-generated method stub
    response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/auth/login")) {
      System.out.println("Login attempt"); 
      AuthController.login(request, response);
    } else if (path.endsWith("/auth/register")) {
//      AuthController.register(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
    }
  }
}