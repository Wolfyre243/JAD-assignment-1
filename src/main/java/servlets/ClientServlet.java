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

      response.sendRedirect(request.getContextPath() + "/profile/");

    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "An occurred while creating account. Please try again later.");
      request.getRequestDispatcher("/error/index.jsp").forward(request, response);
      return;
    }
  }

  public static void editClient(HttpServletRequest request, HttpServletResponse response)
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
      Client client = Client.getClientByUserId(sessUserId);
      if (client == null) {
        response.sendRedirect(request.getContextPath() + "/profile/");
        return;
      }

      String firstName = request.getParameter("firstName");
      String lastName = request.getParameter("lastName");
      Date dob = Date.valueOf(request.getParameter("dob"));
      String gender = request.getParameter("gender");
      String nric = request.getParameter("nric").toUpperCase();
      String phone = request.getParameter("phone");
      String email = request.getParameter("email");
      Client.updateClient(
          client.getClientId(),
          sessUserId,
          firstName, lastName, dob,
          gender, nric, phone, email);
      
      response.sendRedirect(request.getContextPath() + "/profile/");
    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "An unexpected error occurred. Please try again later.");
      request.getRequestDispatcher("/error/index.jsp").forward(request, response);
      return;
    }
  }
}

class EmergencyContactController {
  public static void createEmergencyContact(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    int sessClientId = 0;
    if (request.getParameter("cid") == null) {
      System.out.println("Client profile not found. Redirecting to profile creation page.");
      response.sendRedirect(request.getContextPath() + "/profile/create");
      return;
    } else {
      sessClientId = Integer.parseInt(request.getParameter("cid"));
    }

    try {
      String name = request.getParameter("name");
      String phone = request.getParameter("phone");
      String relationship = request.getParameter("relationship");

      models.EmergencyContact.createEmergencyContact(
          sessClientId,
          name, phone, relationship);

      response.sendRedirect(request.getContextPath() + "/profile/");

    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Failed to create emergency contact. Please try again later.");
      request.getRequestDispatcher("/error/index.jsp").forward(request, response);
      return;
    }
  }
}

@WebServlet({ "/profile/create", "/emergency-contact/add", "/profile/edit" })
public class ClientServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public ClientServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/profile/create")) {
      request.getRequestDispatcher("/profile/create/index.jsp").include(request, response);
    } else if (path.endsWith("/profile/edit")) {
      request.getRequestDispatcher("/profile/edit/index.jsp").include(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/profile/create")) {
      System.out.println("ClientServlet: Handling profile creation POST request.");
      ClientController.createClient(request, response);
    } else if (path.endsWith("/profile/edit")) {
      System.out.println("ClientServlet: Handling edit profile POST request.");
      ClientController.editClient(request, response);
    } else if (path.endsWith("/emergency-contact/add")) {
      System.out.println("ClientServlet: Handling emergency contact creation POST request.");
      EmergencyContactController.createEmergencyContact(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

}
