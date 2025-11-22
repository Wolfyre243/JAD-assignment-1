package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Client;
import models.Family;
import models.MedicalProfile;

import java.io.IOException;

class MedicalController {
  public static void createMedicalProfile(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    final HttpSession session = request.getSession();

    int clientId = -1;
    if (request.getParameter("cid") != null) {
      clientId = Integer.parseInt(request.getParameter("cid"));
    }

    final Integer sessUserId = (Integer) session.getAttribute("userId");
    if (sessUserId == null) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }

    try {
      final boolean isInFamily = Family.checkMemberInFamily(sessUserId, clientId);
      if (!isInFamily) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
      }

      MedicalProfile.createMedicalProfile(
          clientId != -1 ? clientId : Client.getClientByUserId(sessUserId).getClientId(),
          request.getParameter("bloodType"),
          request.getParameter("allergies"),
          request.getParameter("chronicConditions"),
          request.getParameter("medications"),
          request.getParameter("mobilityLevel"),
          request.getParameter("cognitiveStatus"),
          request.getParameter("preferredHospital"),
          request.getParameter("doctorName"),
          request.getParameter("doctorContact"),
          request.getParameter("notes"));

      session.setAttribute("medicalSuccess", "Medical profile created successfully!");
      if (clientId != -1) {
        response.sendRedirect(request.getContextPath() + "/family/member?cid=" + clientId);
        return;
      }
      response.sendRedirect(request.getContextPath() + "/profile/");

    } catch (Exception e) {
//      session.setAttribute("medicalError", "Failed to create medical profile. Please try again.");
//      response.sendRedirect("client/medical/createMedicalProfile.jsp");
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
          "An error occurred while creating medical profile.");
    }
  }

  public static void updateMedicalProfile(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    final HttpSession session = request.getSession();

    int clientId = -1;
    if (request.getParameter("cid") != null) {
      clientId = Integer.parseInt(request.getParameter("cid"));
    }

    final Integer sessUserId = (Integer) session.getAttribute("userId");
    if (sessUserId == null) {
      response.sendRedirect(request.getContextPath() + "/auth/login/");
      return;
    }

    try {

      final boolean isInFamily = Family.checkMemberInFamily(sessUserId, clientId);
      if (!isInFamily) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
      }

      MedicalProfile.updateMedicalProfile(
          clientId != -1 ? clientId : Client.getClientByUserId(sessUserId).getClientId(),
          request.getParameter("bloodType"),
          request.getParameter("allergies"),
          request.getParameter("chronicConditions"),
          request.getParameter("medications"),
          request.getParameter("mobilityLevel"),
          request.getParameter("cognitiveStatus"),
          request.getParameter("preferredHospital"),
          request.getParameter("doctorName"),
          request.getParameter("doctorContact"),
          request.getParameter("notes"));

      session.setAttribute("medicalSuccess", "Medical profile updated successfully!");
      if (clientId != -1) {
        response.sendRedirect(request.getContextPath() + "/family/member?cid=" + clientId);
        return;
      }
      response.sendRedirect(request.getContextPath() + "/profile/");

    } catch (Exception e) {
//      session.setAttribute("medicalError", "Failed to create medical profile. Please try again.");
//      response.sendRedirect("client/medical/createMedicalProfile.jsp");
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
          "An error occurred while creating medical profile.");
    }
  }
}

@WebServlet({ "/medical/create", "/medical/edit" })
public class MedicalServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public MedicalServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    final String path = request.getServletPath();

    if (path.endsWith("/medical/create")) {
      MedicalController.createMedicalProfile(request, response);
    } else if (path.endsWith("/medical/edit")) {
      MedicalController.updateMedicalProfile(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested resource was not found.");
    }
  }

}
