package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import db.JDBC;
import io.micrometer.core.instrument.Statistic;

public class User {
  private int userId;
  private String email;
  private String password;
  private Role role;
  private Boolean isActive;
  private Date createdAt;
  private Date updatedAt;
  private Date lastLogin;

  public User(int userId, String email, String password, Boolean isActive, Date createdAt, Date updatedAt,
      Date lastLogin, Role role) {
    super();
    this.userId = userId;
    this.email = email;
    this.password = password;
    this.isActive = isActive;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.lastLogin = lastLogin;
    this.role = role;
  }

  public int getUserId() {
    return userId;
  }

  public String getEmail() {
    return email;
  }

  public String getPassword() {
    return password;
  }

  public Boolean getIsActive() {
    return isActive;
  }

  public Date getCreatedAt() {
    return createdAt;
  }

  public Date getUpdatedAt() {
    return updatedAt;
  }

  public Date getLastLogin() {
    return lastLogin;
  }
  
  public Role getRole() {
    return role;
  }

  public static User getUserByEmail(String _email) throws SQLException {
    Connection conn = JDBC.connect();

    String sql = new StringBuilder()
        .append("SELECT u.*, r.role_id, r.name as role_name ")
        .append("FROM public.user u ")
        .append("JOIN user_role ur ON u.user_id = ur.user_id ")
        .append("JOIN role r ON r.role_id = ur.role_id ")
        .append("WHERE u.email = ?")
        .toString();

    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, _email);

    ResultSet rs = stmt.executeQuery();
    User user = null;
    if (rs.next()) {
      final int userId = rs.getInt("user_id");
      final String email = rs.getString("email");
      final String password = rs.getString("password");
      final Boolean isActive = rs.getBoolean("is_active");
      final Date createdAt = rs.getTimestamp("created_at");
      final Date updatedAt = rs.getTimestamp("updated_at");
      final Date lastLogin = rs.getTimestamp("last_login");
      final int roleId = rs.getInt("role_id");
      final String roleName = rs.getString("role_name");

      final Role role = new Role(roleId, roleName);
      user = new User(userId, email, password, isActive, createdAt, updatedAt, lastLogin, role);
    }

    rs.close();
    stmt.close();
    return user;
  }
  
  public static User createUser() {
  	
  }
}
