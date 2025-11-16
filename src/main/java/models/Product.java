package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import db.JDBC;

public class Product {
	private int productId;
	private Category category;
	private String name;
	private String description;
	private float price;
	private boolean isActive;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public Product(int productId, Category category, String name, String description, float price, boolean isActive,
	    Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.productId = productId;
		this.category = category;
		this.name = name;
		this.description = description;
		this.price = price;
		this.isActive = isActive;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}

	public static Product getProductById(int _productId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		String sql = new StringBuilder().append("SELECT * ").append("FROM product ").append("WHERE product_id = ?")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, _productId);

		final ResultSet rs = stmt.executeQuery();
		Product product = null;
		if (rs.next()) {
			product = resultMapper(rs);
		}

		conn.close();
		return product;
	}

	private static Product resultMapper(ResultSet rs) throws SQLException {

		int id = rs.getInt("product_id");
		int categoryId = rs.getInt("category_id");
		final String name = rs.getString("name");
		final String description = rs.getString("description");
		final float price = rs.getFloat("price");
		final boolean isActive = rs.getBoolean("is_active");
		final Timestamp createdAt = rs.getTimestamp("created_at");
		final Timestamp updatedAt = rs.getTimestamp("updated_at");
		
		final Category category = Category.getCategoryById(categoryId);

		return new Product(id, category, name, description, price, isActive, createdAt, updatedAt);
	}

	public int getProductId() {
		return productId;
	}

	public Category getCategory() {
		return category;
	}

	public String getName() {
		return name;
	}

	public String getDescription() {
		return description;
	}

	public float getPrice() {
		return price;
	}

	public boolean isActive() {
		return isActive;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}
}
