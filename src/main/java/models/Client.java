/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Client DAO, contains extra info about a person, but said person may not necessarily have an account.
*/

package models;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Client {
	private int clientId;
	private User user;
	private String firstName;
	private String lastName;
	private Date dob;
	private String gender;
	private String nric;
	private String phone;
	private String email;
	private Timestamp createdAt;
	private Timestamp updatedAt;
	
	public Client(int clientId, User user, String firstName, String lastName, Date dob, String gender, String nric,
	    String phone, String email, Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.clientId = clientId;
		this.user = user;
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
	
	private static Client resultMapper(ResultSet rs) throws SQLException {

		int clientId = rs.getInt("client_id");
		int userId = rs.getInt("user_id");
		final String firstName = rs.getString("firstName");
		final String lastName = rs.getString("lastName");
		final Date dob = rs.getDate("dob");
		final String gender = rs.getString("gender");
		final String nric = rs.getString("nric");
		final String phone = rs.getString("phone");
		final String email = rs.getString("email");
		final Timestamp createdAt = rs.getTimestamp("created_at");
		final Timestamp updatedAt = rs.getTimestamp("updated_at");

		final User user = User.getUserById(userId);

		return new Client(clientId, user, firstName, lastName, dob, gender, nric, phone, email, createdAt, updatedAt);
	}

	public int getClientId() {
		return clientId;
	}

	public User getUser() {
		return user;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getLastName() {
		return lastName;
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

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}
	
	
}
