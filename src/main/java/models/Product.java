/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 17/11/2025
  Description: Product DAO to allow DB connectivity for the Product entity
*/

package models;

import java.awt.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

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

	public static ArrayList<Product> getAllProducts() throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM product ")
		    .append("ORDER BY updated_at, created_at DESC;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		final ResultSet rs = stmt.executeQuery();

		ArrayList<Product> productArr = new ArrayList<Product>();
		while (rs.next()) {
			Product product = resultMapper(rs);
			productArr.add(product);
		}

		conn.close();
		return productArr;
	}

	public static Product getProductById(int _productId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM product ")
		    .append("WHERE product_id = ?")
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

	public static void createProduct(
	    int categoryId,
	    String name,
	    String description, // can be null
	    float price,
	    boolean isActive) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		// Write the query
		final String sql = new StringBuilder()
		    .append("INSERT INTO product ")
		    .append("（category_id, name, description, price, is_active） ")
		    .append("VALUES （?, ?, ?, ?, ?, ?);")
		    .toString();

		// Load the params
		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, categoryId);
		stmt.setString(2, name);
		stmt.setString(3, description);
		stmt.setFloat(4, price);
		stmt.setBoolean(5, isActive);

		stmt.executeUpdate();

		conn.close();
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
