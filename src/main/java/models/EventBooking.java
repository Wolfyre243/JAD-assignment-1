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

    // After creating a booking, check if the event reached capacity and auto-deactivate it
    try {
      models.Event ev = models.Event.getEventById(eventId);
      if (ev != null) {
        int count = getBookingCount(eventId);
        if (count >= ev.getCapacity()) {
          models.Event.setActive(eventId, false);
        }
      }
    } catch (Exception ignored) {
      // ignore any errors here to avoid failing the booking on post-check
    }

    return id;
  }

  public static boolean hasBooking(int eventId, Integer clientId, Integer userId, String guestEmail) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    StringBuilder sb = new StringBuilder();
    sb.append("SELECT 1 FROM event_booking WHERE event_id = ? AND (");
    boolean added = false;
    if (clientId != null) {
      sb.append("client_id = ?");
      added = true;
    }
    if (userId != null) {
      if (added) sb.append(" OR ");
      sb.append("user_id = ?");
      added = true;
    }
    if (guestEmail != null && !guestEmail.trim().isEmpty()) {
      if (added) sb.append(" OR ");
      sb.append("LOWER(guest_email) = LOWER(?)");
      added = true;
    }

    if (!added) {
      conn.close();
      return false; // nothing to check against
    }

    sb.append(") LIMIT 1");

    final PreparedStatement stmt = conn.prepareStatement(sb.toString());
    int idx = 1;
    stmt.setInt(idx++, eventId);
    if (clientId != null) stmt.setInt(idx++, clientId);
    if (userId != null) stmt.setInt(idx++, userId);
    if (guestEmail != null && !guestEmail.trim().isEmpty()) stmt.setString(idx++, guestEmail.trim());

    final ResultSet rs = stmt.executeQuery();
    final boolean exists = rs.next();
    rs.close();
    stmt.close();
    conn.close();
    return exists;
  }

  /**
   * Return number of bookings for the given event
   */
  public static int getBookingCount(int eventId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = "SELECT COUNT(*) AS cnt FROM event_booking WHERE event_id = ?";
    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, eventId);
    final ResultSet rs = stmt.executeQuery();
    int cnt = 0;
    if (rs.next()) cnt = rs.getInt("cnt");
    rs.close();
    stmt.close();
    conn.close();
    return cnt;
  }

  /**
   * Return list of bookings for the given event
   */
  public static java.util.List<EventBooking> getBookingsForEvent(int eventId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = "SELECT * FROM event_booking WHERE event_id = ? ORDER BY created_at ASC";
    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, eventId);
    final ResultSet rs = stmt.executeQuery();
    final java.util.List<EventBooking> bookings = new java.util.ArrayList<>();
    while (rs.next()) {
      int bookingId = rs.getInt("booking_id");
      int evId = rs.getInt("event_id");
      Integer clientId = rs.getObject("client_id") != null ? rs.getInt("client_id") : null;
      Integer userId = rs.getObject("user_id") != null ? rs.getInt("user_id") : null;
      String guestName = rs.getString("guest_name");
      String guestEmail = rs.getString("guest_email");
      java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
      bookings.add(new EventBooking(bookingId, evId, clientId, userId, guestName, guestEmail, createdAt));
    }
    rs.close();
    stmt.close();
    conn.close();
    return bookings;
  }
}
