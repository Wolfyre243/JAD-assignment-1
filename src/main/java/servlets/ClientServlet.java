package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Client;
import models.User;

import java.io.IOException;
import java.sql.Date;

class ClientController {
  public static void createClient(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    final HttpSession session = request.getSession();

    int sessUserId = 0;
    if (session.getAttribute("userId") == null) {
      System.out.println("User not logged in. Redirecting to login page.");
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    } else {
      sessUserId = (int) session.getAttribute("userId");
    }

    try {
      // Verify if user already has a client profile
      Client client = Client.getClientByUserId(sessUserId);
      if (client != null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
      }

      String firstName = request.getParameter("firstName");
      String lastName = request.getParameter("lastName");
      Date dob = Date.valueOf(request.getParameter("dob"));
      String gender = request.getParameter("gender");
      String nric = request.getParameter("nric").toUpperCase();
      String phone = request.getParameter("phone");
      String email = request.getParameter("email");

      Client.createClient(
          sessUserId,
          firstName, lastName, dob, gender, nric, phone, email);

      response.sendRedirect(request.getContextPath() + "/");

    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create profile. Please try again.");
      return;
    }
  }
}

@WebServlet("/profile/create")
public class ClientServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public ClientServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/profile/create")) {
      request.getRequestDispatcher("/profile/create/index.jsp").include(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/profile/create")) {
      System.out.println("ClientServlet: Handling profile creation POST request.");
      ClientController.createClient(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

}
