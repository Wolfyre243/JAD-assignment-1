/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Auth Servlet for handling all backend auth functionality, like login and register.
*/

package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Family;
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

  public static void register(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    final HttpSession session = request.getSession();

    // Get form fields
    final String email = request.getParameter("email");
    final String password = request.getParameter("password");
    final int roleId = Integer.parseInt(request.getParameter("roleId"));

    try {
      int userId = User.createUser(email, password, roleId);
      final User user = User.getUserById(userId);

      final int userRoleId = user.getRole().getRoleId();
      final String userRoleName = user.getRole().getRoleName();

      if (userRoleId == 3) {
        Family.createFamily(userId); // Create a family for the new user
      }

      session.setAttribute("userId", user.getUserId());
      session.setAttribute("userRoleId", userRoleId);
      session.setAttribute("userRoleName", userRoleName);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred during registration.");
      return;
    }

    response.setStatus(HttpServletResponse.SC_CREATED);
    if (roleId == 2) {
      // Client role
      response.sendRedirect(request.getContextPath() + "/profile/create/");
      return;
    } else {
      // Guardian & Admin role
      response.sendRedirect(request.getContextPath() + "/");
      return;
    }
  }

  public static void logout(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    final HttpSession session = request.getSession();

    try {
      // Render everything in the session useless
      session.invalidate();

      response.sendRedirect(request.getContextPath() + "/");
      return;
    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while logging out.");
    }
  }
}

/**
 * Servlet implementation class AuthServlet
 */
@WebServlet({ "/auth/login", "/auth/register", "/auth/logout" })
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
      AuthController.login(request, response);
    } else if (path.endsWith("/auth/register")) {
      AuthController.register(request, response);
    } else if (path.endsWith("/auth/logout")) {
      AuthController.logout(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
    }
  }
}