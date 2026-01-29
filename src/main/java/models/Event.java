/*
  Name: Karys Goh Yi Xin
  Date: January 29, 2026
  Description: Event model + DB access for events feature
*/
package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import db.JDBC;

public class Event {
  private int eventId;
  private String title;
  private String description;
  private String imagePath;
  private String location;
  private Timestamp startTime;
  private Timestamp endTime;
  private int capacity;
  private boolean isActive;
  private int createdBy;
  private Timestamp createdAt;
  private Timestamp updatedAt;

  public Event(int eventId, String title, String description, String imagePath, String location, Timestamp startTime, Timestamp endTime,
      int capacity, boolean isActive, int createdBy, Timestamp createdAt, Timestamp updatedAt) {
    this.eventId = eventId;
    this.title = title;
    this.description = description;
    this.imagePath = imagePath;
    this.location = location;
    this.startTime = startTime;
    this.endTime = endTime;
    this.capacity = capacity;
    this.isActive = isActive;
    this.createdBy = createdBy;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  public String getImagePath() { return imagePath; }

  public int getEventId() { return eventId; }
  public String getTitle() { return title; }
  public String getDescription() { return description; }
  public String getLocation() { return location; }
  public Timestamp getStartTime() { return startTime; }
  public Timestamp getEndTime() { return endTime; }
  public int getCapacity() { return capacity; }
  public boolean isActive() { return isActive; }
  public int getCreatedBy() { return createdBy; }
  public Timestamp getCreatedAt() { return createdAt; }
  public Timestamp getUpdatedAt() { return updatedAt; }

  public static ArrayList<Event> getAllEvents() throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = new StringBuilder()
        .append("SELECT * ")
        .append("FROM event ")
        .append("ORDER BY start_time ASC;")
        .toString();

    final PreparedStatement stmt = conn.prepareStatement(sql);
    final ResultSet rs = stmt.executeQuery();

    ArrayList<Event> arr = new ArrayList<Event>();
    while (rs.next()) {
      arr.add(resultMapper(rs));
    }

    conn.close();
    return arr;
  }

  public static Event getEventById(int eventId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = "SELECT * FROM event WHERE event_id = ?";
    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, eventId);
    final ResultSet rs = stmt.executeQuery();
    Event ev = null;
    if (rs.next()) ev = resultMapper(rs);
    conn.close();
    return ev;
  }

  public static int createEvent(String title, String description, String location, Timestamp startTime, Timestamp endTime, int capacity, boolean isActive, int createdBy) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = new StringBuilder()
        .append("INSERT INTO event (title, description, location, start_time, end_time, capacity, is_active, created_by, created_at, updated_at) ")
        .append("VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING event_id")
        .toString();

    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, title);
    stmt.setString(2, description);
    stmt.setString(3, location);
    stmt.setTimestamp(4, startTime);
    stmt.setTimestamp(5, endTime);
    stmt.setInt(6, capacity);
    stmt.setBoolean(7, isActive);
    stmt.setInt(8, createdBy);

    final ResultSet rs = stmt.executeQuery();
    int id = -1;
    if (rs.next()) id = rs.getInt(1);
    conn.close();
    return id;
  }

  public static boolean updateEvent(int eventId, String title, String description, String location, Timestamp startTime, Timestamp endTime, int capacity, boolean isActive) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = "UPDATE event SET title = ?, description = ?, location = ?, start_time = ?, end_time = ?, capacity = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE event_id = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, title);
      stmt.setString(2, description);
      stmt.setString(3, location);
      stmt.setTimestamp(4, startTime);
      stmt.setTimestamp(5, endTime);
      stmt.setInt(6, capacity);
      stmt.setBoolean(7, isActive);
      stmt.setInt(8, eventId);
      int updated = stmt.executeUpdate();
      conn.close();
      return updated > 0;
    }
  }

  public static boolean deleteEvent(int eventId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) throw new SQLException("Database connection failed");

    final String sql = "DELETE FROM event WHERE event_id = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, eventId);
      int deleted = stmt.executeUpdate();
      conn.close();
      return deleted > 0;
    }
  }

  private static Event resultMapper(ResultSet rs) throws SQLException {
    int id = rs.getInt("event_id");
    String title = rs.getString("title");
    String description = rs.getString("description");
    String imagePath = rs.getString("image_path");
    String location = rs.getString("location");
    Timestamp start = rs.getTimestamp("start_time");
    Timestamp end = rs.getTimestamp("end_time");
    int capacity = rs.getInt("capacity");
    boolean isActive = rs.getBoolean("is_active");
    int createdBy = rs.getInt("created_by");
    Timestamp createdAt = rs.getTimestamp("created_at");
    Timestamp updatedAt = rs.getTimestamp("updated_at");

    return new Event(id, title, description, imagePath, location, start, end, capacity, isActive, createdBy, createdAt, updatedAt);
  }
}
