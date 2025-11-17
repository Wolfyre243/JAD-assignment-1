/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Family Member DAO to connect with the database's Family Member entity
*/

package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import db.JDBC;

public class FamilyMember {
	private int familyId;
	private int clientId;
	private String relationship;

	public FamilyMember(int familyId, int clientId, String relationship) {
		super();
		this.familyId = familyId;
		this.clientId = clientId;
		this.relationship = relationship;
	}

	public static ArrayList<FamilyMember> getFamilyMembersByFamilyId(int familyId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM family_member ")
		    .append("WHERE family_id = ?")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, familyId);

		final ResultSet rs = stmt.executeQuery();
		ArrayList<FamilyMember> memberArr = new ArrayList<FamilyMember>();
		while (rs.next()) {
			FamilyMember familyMember = resultMapper(rs);
			memberArr.add(familyMember);
		}

		conn.close();
		return memberArr;
	}

	public static void createFamilyMember(int familyId, int clientId, String relationship) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		// Write the query
		final String sql = new StringBuilder()
		    .append("INSERT INTO family_member ")
		    .append("（family_id, client_id, relationship） ")
		    .append("VALUES （?, ?, ?);")
		    .toString();

		// Load the params
		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, familyId);
		stmt.setInt(2, clientId);
		stmt.setString(3, relationship);
		stmt.executeUpdate();

		conn.close();
	}

	private static FamilyMember resultMapper(ResultSet rs) throws SQLException {
		int familyId = rs.getInt("family_id");
		int clientId = rs.getInt("client_id");
		final String relationship = rs.getString("relationship");

		return new FamilyMember(familyId, clientId, relationship);
	}

	public int getFamilyId() {
		return familyId;
	}

	public int getClientId() {
		return clientId;
	}

	public String getRelationship() {
		return relationship;
	}

}