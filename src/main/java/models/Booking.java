/*
  Author: Zhang Junkai
  Admin No: P2429634
  Class: DIT-2B-01
  Last Edited: 16/01/2025
  Description: Booking DAO to enable DB access for the Booking entity
*/

package models;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import db.JDBC;

public class Booking {
	private int bookingId;
	private int orderId;
	private int productId;
	private int caregiverId;
	private int clientId;
	private String specialRequests;
	private boolean checkedIn;
	private boolean checkedOut;
	private Timestamp createdAt;
	private Timestamp updatedAt;
	
	public Booking(int bookingId, int orderId, int productId, int caregiverId, int clientId, String specialRequests,
	    boolean checkedIn, boolean checkedOut, Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.bookingId = bookingId;
		this.orderId = orderId;
		this.productId = productId;
		this.caregiverId = caregiverId;
		this.clientId = clientId;
		this.specialRequests = specialRequests;
		this.checkedIn = checkedIn;
		this.checkedOut = checkedOut;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}
	
	public int getBookingId() {
		return bookingId;
	}
	public int getOrderId() {
		return orderId;
	}
	public int getProductId() {
		return productId;
	}
	public Product getProduct() throws SQLException {
    return Product.getProductById(this.productId);
  }
	public int getCaregiverId() {
		return caregiverId;
	}
	public Caregiver getCaregiver() throws SQLException {
    return Caregiver.getCaregiverById(this.caregiverId);
  }
	public int getClientId() {
		return clientId;
	}
	public String getSpecialRequests() {
		return specialRequests;
	}
	public boolean isCheckedIn() {
		return checkedIn;
	}
	public boolean isCheckedOut() {
		return checkedOut;
	}
	public Timestamp getCreatedAt() {
		return createdAt;
	}
	public String getCreatedAtFormatted() {
	  final SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    return sdf.format(this.createdAt);
  }
	public Timestamp getUpdatedAt() {
		return updatedAt;
	}
	
	public static ArrayList<Booking> getAllBookings() throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM booking ")
		    .append("ORDER BY updated_at, created_at DESC;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		final ResultSet rs = stmt.executeQuery();

		ArrayList<Booking> bookingArr = new ArrayList<Booking>();
		while (rs.next()) {
			Booking booking = resultMapper(rs);
			bookingArr.add(booking);
		}

		conn.close();
		return bookingArr;
	}
	
	public static ArrayList<Booking> getAllClientBookings(int clientId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM booking ")
		    .append("WHERE client_id = ? ")
		    .append("ORDER BY updated_at, created_at DESC;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, clientId);
		final ResultSet rs = stmt.executeQuery();

		ArrayList<Booking> bookingArr = new ArrayList<Booking>();
		while (rs.next()) {
			Booking booking = resultMapper(rs);
			bookingArr.add(booking);
		}

		conn.close();
		return bookingArr;
	}
	
	public static ArrayList<Booking> getAllCaregiverBookings(int caregiverId) throws SQLException {
		final Connection conn = JDBC.connect();
		if (conn == null) {
			throw new SQLException("Database connection failed");
		}

		final String sql = new StringBuilder()
		    .append("SELECT * ")
		    .append("FROM booking ")
		    .append("WHERE caregiver_id = ? ")
		    .append("ORDER BY updated_at, created_at DESC;")
		    .toString();

		final PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, caregiverId);
		final ResultSet rs = stmt.executeQuery();

		ArrayList<Booking> bookingArr = new ArrayList<Booking>();
		while (rs.next()) {
			Booking booking = resultMapper(rs);
			bookingArr.add(booking);
		}

		conn.close();
		return bookingArr;
	}
	
	// Helper method
	private static Booking resultMapper(ResultSet rs) throws SQLException {

		int bookingId = rs.getInt("booking_id");
		int orderId = rs.getInt("order_id");
		int productId = rs.getInt("product_id");
		int caregiverId = rs.getInt("caregiver_id");
		int clientId = rs.getInt("client_id");
		String specialRequests = rs.getString("special_requests");
		boolean checkedIn = rs.getBoolean("checked_in");
		boolean checkedOut = rs.getBoolean("checked_out");
		final Timestamp createdAt = rs.getTimestamp("created_at");
		final Timestamp updatedAt = rs.getTimestamp("updated_at");

		return new Booking(bookingId, orderId, productId, caregiverId, clientId, specialRequests, checkedIn, checkedOut, createdAt, updatedAt);
	}
	
}
