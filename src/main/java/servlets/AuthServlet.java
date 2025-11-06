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
      
      // TODO: Send cookie instead
      session.setAttribute("userId", user.getUserId());
      session.setAttribute("userRoleId", user.getRole().getRoleId());
      
      response.setStatus(HttpServletResponse.SC_OK);
      // TODO: Redirect to dashboard or home page
      
      
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
    response.getWriter().append("Served at: ").append(request.getContextPath());
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // TODO Auto-generated method stub
    doGet(request, response);
  }

}
