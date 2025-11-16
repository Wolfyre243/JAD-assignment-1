package models;

import java.sql.Timestamp;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import db.JDBC;

public class Category {
	private int categoryId;
	private String name;
	private String description;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public Category(int categoryId, String name, String description, Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.categoryId = categoryId;
		this.name = name;
		this.description = description;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}

	public static Category getCategoryById(int _categoryId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		String sql = new StringBuilder().append("SELECT category_id, name, description, created_at, updated_at ")
		    .append("FROM category ").append("WHERE category_id = ?").toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, _categoryId);

		final ResultSet rs = stmt.executeQuery();
		Category category = null;
		if (rs.next()) {
			category = resultMapper(rs);
		}

		conn.close();
		return category;
	}

	private static Category resultMapper(ResultSet rs) throws SQLException {

		int id = rs.getInt("category_id");
		final String name = rs.getString("name");
		final String description = rs.getString("description");
		final Timestamp createdAt = rs.getTimestamp("created_at");
		final Timestamp updatedAt = rs.getTimestamp("updated_at");

		return new Category(id, name, description, createdAt, updatedAt);
	}

	public int getCategoryId() {
		return categoryId;
	}

	public String getName() {
		return name;
	}

	public String getDescription() {
		return description;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

}
