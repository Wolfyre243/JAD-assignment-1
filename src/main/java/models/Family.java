/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Family DAO to connect with the database's Family entity
*/

package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import db.JDBC;

public class Family {
	private int familyId;
	private int ownerId;
	private ArrayList<FamilyMember> members;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public Family(int familyId, int ownerId, ArrayList<FamilyMember> members, Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.familyId = familyId;
		this.ownerId = ownerId;
		this.members = members;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}

	public static void createFamily(int ownerId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("INSERT INTO family ")
		    .append("(owner_id) ")
		    .append("VALUES (?); ")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, ownerId);

		stmt.executeUpdate();
		conn.close();
	}

	public static Family getUserFamily(int userId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM family ")
		    .append("WHERE owner_id = ?;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, userId);

		final ResultSet rs = stmt.executeQuery();
		Family family = null;
		if (rs.next()) {
			family = resultMapper(rs);
		}

		conn.close();
		return family;
	}

	private static Family resultMapper(ResultSet rs) throws SQLException {
		int familyId = rs.getInt("family_id");
		int ownerId = rs.getInt("client_id");
		// Fetch all members in the family
		ArrayList<FamilyMember> members = FamilyMember.getFamilyMembersByFamilyId(familyId);

		Timestamp createdAt = rs.getTimestamp("created_at");
		Timestamp updatedAt = rs.getTimestamp("updated_at");

		return new Family(familyId, ownerId, members, createdAt, updatedAt);
	}

	public int getFamilyId() {
		return familyId;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

}
