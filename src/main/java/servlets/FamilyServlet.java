package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Client;
import models.Family;
import models.FamilyMember;

import java.io.IOException;
import java.sql.Date;

class FamilyController {
  public static void createFamilyMember(HttpServletRequest request, HttpServletResponse response)
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
      String firstName = request.getParameter("firstName");
      String lastName = request.getParameter("lastName");
      Date dob = Date.valueOf(request.getParameter("dob"));
      String gender = request.getParameter("gender");
      String nric = request.getParameter("nric").toUpperCase();
      String phone = request.getParameter("phone");
      String email = request.getParameter("email");

      final int newClientId = Client.createClient(
          null,
          firstName, lastName, dob, gender, nric, phone, email);
      
      String relationship = request.getParameter("relationship");
      
      final int familyId = Family.getUserFamily(sessUserId).getFamilyId();
      FamilyMember.createFamilyMember(familyId, newClientId, relationship);
      
      request.setAttribute("success", "Family member '" + firstName + " " + lastName + "' added successfully!");
      request.getRequestDispatcher("/family/index.jsp").forward(request, response);

    } catch (Exception e) {
      e.printStackTrace();
      request.setAttribute("error", "Failed to add family member. Please try again.");
//      response.sendRedirect(request.getContextPath() + "/family/");
      request.getRequestDispatcher("/family/index.jsp").forward(request, response);
      return;
    }
  }
  
  public static void removeFamilyMember(HttpServletRequest request, HttpServletResponse response)
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
      int clientId = Integer.parseInt(request.getParameter("cid"));

      Client.deleteClientById(clientId);

      response.sendRedirect(request.getContextPath() + "/family/");

    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
          "Failed to remove family member. Please try again.");
      return;
    }
  }
}


@WebServlet({ "/family/add", "/family/remove" })
public class FamilyServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public FamilyServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/family/add")) {
      FamilyController.createFamilyMember(request, response);
    } else if (path.endsWith("/family/remove")) {
      FamilyController.removeFamilyMember(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

}
