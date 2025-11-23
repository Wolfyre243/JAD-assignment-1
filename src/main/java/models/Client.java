/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Client DAO, contains extra info about a person, but said person may not necessarily have an account.
*/

package models;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;

import db.JDBC;

public class Client {
	private int clientId;
	private User user;
	private ArrayList<EmergencyContact> emergencyContacts;
	private MedicalProfile medicalProfile;
	private String firstName;
	private String lastName;
	private Date dob;
	private String gender;
	private String nric;
	private String phone;
	private String email;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public Client(int clientId, User user, ArrayList<EmergencyContact> emergencyContacts, MedicalProfile medicalProfile,
	    String firstName, String lastName, Date dob, String gender, String nric, String phone, String email,
	    Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.clientId = clientId;
		this.user = user;
		this.emergencyContacts = emergencyContacts;
		this.medicalProfile = medicalProfile;
		this.firstName = firstName;
		this.lastName = lastName;
		this.dob = dob;
		this.gender = gender;
		this.nric = nric;
		this.phone = phone;
		this.email = email;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}

	public static Client getClientById(int clientId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM client ")
		    .append("WHERE client_id = ?;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, clientId);

		final ResultSet rs = stmt.executeQuery();

		Client client = null;
		if (rs.next()) {
			client = resultMapper(rs);
		}

		rs.close();
		conn.close();
		return client;
	}

	public static Client getClientByUserId(int userId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM client ")
		    .append("WHERE user_id = ?;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, userId);

		final ResultSet rs = stmt.executeQuery();

		Client client = null;
		if (rs.next()) {
			client = resultMapper(rs);
		}

		rs.close();
		conn.close();
		return client;
	}

	public static int createClient(
	    Integer userId,
	    String firstName,
	    String lastName,
	    Date dob,
	    String gender,
	    String nric,
	    String phone,
	    String email) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		// Write the query
		final String sql = new StringBuilder()
		    .append("INSERT INTO client ")
		    .append("(user_id, first_name, last_name, dob, gender, nric, phone, email) ")
		    .append("VALUES (?, ?, ?, ?, ?, ?, ?, ?) ")
		    .append("RETURNING client_id;")
		    .toString();

		// Load the params
		final PreparedStatement stmt = conn.prepareStatement(sql);
		if (userId != null) {
			stmt.setInt(1, userId);
		} else {
			stmt.setNull(1, Types.INTEGER);
		}
		stmt.setString(2, firstName);
		stmt.setString(3, lastName);
		stmt.setDate(4, dob);
		stmt.setString(5, gender);
		stmt.setString(6, nric);
		stmt.setString(7, phone);
		stmt.setString(8, email);

		int insertedClientId = -1;
		final ResultSet rs = stmt.executeQuery();

		if (rs.next()) {
			insertedClientId = rs.getInt("client_id");
		}

		conn.close();
		return insertedClientId;
	}

	public static void updateClient(
	    int clientId,
	    int userId,
	    String firstName,
	    String lastName,
	    Date dob,
	    String gender,
	    String nric,
	    String phone,
	    String email) throws SQLException {

		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("UPDATE client ")
		    .append("SET user_id = ?, ")
		    .append("    first_name = ?, ")
		    .append("    last_name = ?, ")
		    .append("    dob = ?, ")
		    .append("    gender = ?, ")
		    .append("    nric = ?, ")
		    .append("    phone = ?, ")
		    .append("    email = ? ")
		    .append("WHERE client_id = ?;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, userId);
		stmt.setString(2, firstName);
		stmt.setString(3, lastName);
		stmt.setDate(4, dob);
		stmt.setString(5, gender);
		stmt.setString(6, nric);
		stmt.setString(7, phone);
		stmt.setString(8, email);
		stmt.setInt(9, clientId);

		stmt.executeUpdate();
		conn.close();
		return;
	}

	private static Client resultMapper(ResultSet rs) throws SQLException {

		int clientId = rs.getInt("client_id");
		int userId = rs.getInt("user_id");
		final String firstName = rs.getString("first_name");
		final String lastName = rs.getString("last_name");
		final Date dob = rs.getDate("dob");
		final String gender = rs.getString("gender");
		final String nric = rs.getString("nric");
		final String phone = rs.getString("phone");
		final String email = rs.getString("email");
		final Timestamp createdAt = rs.getTimestamp("created_at");
		final Timestamp updatedAt = rs.getTimestamp("updated_at");

		final User user = User.getUserById(userId);
		final ArrayList<EmergencyContact> emContacts = EmergencyContact.getEmergencyContactsByClientId(clientId);
		final MedicalProfile medicalProfile = MedicalProfile.getMedicalProfileByClientId(clientId);

		return new Client(clientId, user, emContacts, medicalProfile, firstName, lastName, dob, gender, nric, phone, email,
		    createdAt, updatedAt);
	}

	public int getClientId() {
		return clientId;
	}

	public User getUser() {
		return user;
	}

	public ArrayList<EmergencyContact> getEmergencyContacts() {
		return emergencyContacts;
	}

	public MedicalProfile getMedicalProfile() {
		return medicalProfile;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public String getFullName() {
		return firstName + " " + lastName;
	}

	public Date getDob() {
		return dob;
	}

	public String getGender() {
		return gender;
	}

	public String getNric() {
		return nric;
	}

	public String getPhone() {
		return phone;
	}

	public String getEmail() {
		return email;
	}

	public int getAge() {
		return LocalDate.now().getYear() - dob.toLocalDate().getYear();
	}

	public String getCreatedAt() {
		final SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
		return sdf.format(createdAt);
	}

	public String getUpdatedAt() {
		final SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
		return sdf.format(updatedAt);
	}

}
