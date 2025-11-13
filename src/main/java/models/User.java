package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import db.JDBC;

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
    final Connection conn = JDBC.connect();

    String sql = new StringBuilder().append("SELECT u.*, r.role_id, r.name as role_name ").append("FROM public.user u ")
        .append("JOIN user_role ur ON u.user_id = ur.user_id ").append("JOIN role r ON r.role_id = ur.role_id ")
        .append("WHERE u.email = ?").toString();

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
    conn.close();
    return user;
  }

  public static void createUser(String email, String password, int roleId) throws SQLException {

    final Connection conn = JDBC.connect();
    
    final String userSQL = new StringBuilder()
        .append("INSERT INTO public.user ")
        .append("(email, password) ")
        .append("VALUES ")
        .append("(?, ?) ")
        .append("RETURNING *;")
        .toString();
    
    final String userRoleSQL = new StringBuilder()
        .append("INSERT INTO user_role ")
        .append("(user_id, role_id) ")
        .append("VALUES ")
        .append("(?, ?);")
        .toString();
    
    PreparedStatement psUser = conn.prepareStatement(userSQL);
    PreparedStatement psUserRole = conn.prepareStatement(userRoleSQL);
    
    try {
      // Start transaction
      conn.setAutoCommit(false);
      
      int insertedUserId = -1;
      
      // Perform user insertion
      psUser.setString(1, email);
      psUser.setString(2, password);
      
      ResultSet rs = psUser.executeQuery();
      
      if (rs.next()) {
        insertedUserId = rs.getInt("user_id");
      }
      
      // Perform user_role insertion
      psUserRole.setInt(1, insertedUserId);
      psUserRole.setInt(2, roleId);
      rs = psUserRole.executeQuery();
      
      rs.close();
      
    } catch (SQLException e) {
      try {
        conn.rollback();
      } catch (Exception ignored) {
        ignored.printStackTrace();
      }
      
      throw e;
    }
    
    psUser.close();
    psUserRole.close();
    conn.close();
  }
}
