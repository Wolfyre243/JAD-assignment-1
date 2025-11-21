package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import db.JDBC;

public class EmergencyContact {
  private int contactId;
  private int clientId;
  private String name;
  private String phone;
  private String relationship;

  public EmergencyContact(int contactId, int clientId, String name, String phone, String relationship) {
    super();
    this.contactId = contactId;
    this.clientId = clientId;
    this.name = name;
    this.phone = phone;
    this.relationship = relationship;
  }

  public static ArrayList<EmergencyContact> getEmergencyContactsByClientId(int clientId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) {
      throw new SQLException("Database connection failed");
    }

    final String sql = new StringBuilder()
        .append("SELECT * ")
        .append("FROM emergency_contact ")
        .append("WHERE client_id = ?")
        .toString();

    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, clientId);

    final ResultSet rs = stmt.executeQuery();
    ArrayList<EmergencyContact> emContactArr = new ArrayList<EmergencyContact>();
    while (rs.next()) {
      emContactArr.add((resultMapper(rs)));
    }

    rs.close();
    conn.close();
    return emContactArr;
  }

  public static void createEmergencyContact(int clientId, String name, String phone, String relationship) throws SQLException {
  	final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		// Write the query
		final String sql = new StringBuilder()
		    .append("INSERT INTO emergency_contact ")
		    .append("(client_id, name, phone, relationship) ")
		    .append("VALUES (?, ?, ?, ?);")
		    .toString();

		// Load the params
		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, clientId);
		stmt.setString(2, name);
		stmt.setString(3, phone);
		stmt.setString(4, relationship);
		stmt.executeUpdate();

		conn.close();
  }
  
  private static EmergencyContact resultMapper(ResultSet rs) throws SQLException {

    final int contactId = rs.getInt("contact_id");
    final int clientId = rs.getInt("client_id");
    final String name = rs.getString("name");
    final String phone = rs.getString("phone");
    final String relationship = rs.getString("relationship");

    return new EmergencyContact(contactId, clientId, name, phone, relationship);
  }

  public int getContactId() {
    return contactId;
  }

  public int getClientId() {
    return clientId;
  }

  public String getName() {
    return name;
  }

  public String getPhone() {
    return phone;
  }

  public String getRelationship() {
    return relationship;
  }
  
  public String toString() {
  	return name + " (" + relationship + ") - " + phone;
  }
}