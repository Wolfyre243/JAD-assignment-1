/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 28/01/2026
  Description: EventBooking model to record sign-ups (supports client and guest bookings)
*/
package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import db.JDBC;

public class EventBooking {
  private int bookingId;
  private int eventId;
  private Integer clientId; // nullable
  private Integer userId; // nullable - logged-in user without client record
  private String guestName;
  private String guestEmail;
  private Timestamp createdAt;

  public EventBooking(int bookingId, int eventId, Integer clientId, Integer userId, String guestName, String guestEmail, Timestamp createdAt) {
    this.bookingId = bookingId;
    this.eventId = eventId;
    this.clientId = clientId;
    this.userId = userId;
    this.guestName = guestName;
    this.guestEmail = guestEmail;
    this.createdAt = createdAt;
  }

  public int getBookingId() { return bookingId; }
  public int getEventId() { return eventId; }
  public Integer getClientId() { return clientId; }
  public Integer getUserId() { return userId; }
  public String getGuestName() { return guestName; }
  public String getGuestEmail() { return guestEmail; }
  public Timestamp getCreatedAt() { return createdAt; }
  public static int createBooking(int eventId, Integer clientId, Integer userId, String guestName, String guestEmail) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = new StringBuilder()
        .append("INSERT INTO event_booking (event_id, client_id, user_id, guest_name, guest_email, created_at, updated_at) ")
        .append("VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING booking_id")
        .toString();

    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, eventId);
    if (clientId != null) stmt.setInt(2, clientId); else stmt.setNull(2, java.sql.Types.INTEGER);
    if (userId != null) stmt.setInt(3, userId); else stmt.setNull(3, java.sql.Types.INTEGER);
    if (guestName != null) stmt.setString(4, guestName); else stmt.setNull(4, java.sql.Types.VARCHAR);
    if (guestEmail != null) stmt.setString(5, guestEmail); else stmt.setNull(5, java.sql.Types.VARCHAR);

    final ResultSet rs = stmt.executeQuery();
    int id = -1;
    if (rs.next()) id = rs.getInt(1);
    conn.close();
    return id;
  }
}
