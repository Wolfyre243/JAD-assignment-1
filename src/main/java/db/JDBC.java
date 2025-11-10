package db;

import java.sql.*;

public class JDBC {
  private static Connection conn = null;
  private static String connURL = "jdbc:postgresql://ep-calm-water-a18qegew-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_6dLgQzjR9OEa&sslmode=require&channelBinding=require";
  private static String username = "neondb_owner";
  private static String password = "npg_6dLgQzjR9OEa";

  public static Connection connect() {
    String errorMessage = null;
    try {
      if (conn == null || conn.isClosed()) {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(connURL, username, password);
      }
    } catch (ClassNotFoundException cnfe) {
      errorMessage = "Database driver not found. Contact the administrator.";
    } catch (SQLException sqle) {
      errorMessage = "Unable to connect to the database. Please try again later.";
    } finally {
      if (errorMessage != null) {
        System.out.print(errorMessage);
        return null;
      }
    }
    
    return conn;
  }
}