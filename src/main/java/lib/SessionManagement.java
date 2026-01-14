/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Session management utility for user authentication and authorization checks
 */
package lib;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public class SessionManagement {

	public static boolean isLoggedIn(HttpServletRequest req) {
		HttpSession sess = req.getSession(false);
		if (sess == null) return false;
		Integer userId = (Integer) sess.getAttribute("userId");
		return userId != null;
	}

	// No javax.* overloads — project targets Jakarta servlet API

	public static Integer getUserId(HttpServletRequest req) {
		HttpSession sess = req.getSession(false);
		return (sess == null) ? null : (Integer) sess.getAttribute("userId");
	}

    

	public static Integer getUserRoleId(HttpServletRequest req) {
		HttpSession sess = req.getSession(false);
		return (sess == null) ? null : (Integer) sess.getAttribute("userRoleId");
	}

    

	public static boolean isAdmin(HttpServletRequest req) {
		Integer roleId = getUserRoleId(req);
		return roleId != null && roleId == 1; // role_id 1 = admin in this project
	}
	
	public static boolean isClient(HttpServletRequest req) {
	    Integer roleId = getUserRoleId(req);
	    return roleId != null && roleId == 2; // role_id 2 = client
	}
	
	public static boolean isCaregiver(HttpServletRequest req) {
	    Integer roleId = getUserRoleId(req);
	    return roleId != null && roleId == 5; // role_id 5 = caregiver
	}
}
