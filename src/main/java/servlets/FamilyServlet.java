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
          sessUserId,
          firstName, lastName, dob, gender, nric, phone, email);
      
      String relationship = request.getParameter("relationship");
      
      final int familyId = Family.getUserFamily(sessUserId).getFamilyId();
      FamilyMember.createFamilyMember(familyId, newClientId, relationship);

      response.sendRedirect(request.getContextPath() + "/family/");

    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
          "Failed to add family member. Please try again.");
      return;
    }
  }
}


@WebServlet("/family/add")
public class FamilyServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public FamilyServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.getWriter().append("Served at: ").append(request.getContextPath());
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/family/add")) {
      System.out.println("ClientServlet: Handling profile creation POST request.");
      FamilyController.createFamilyMember(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

}
