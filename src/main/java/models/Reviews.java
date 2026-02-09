/*
  Author: Lim Song Chern Jayden
  Admin No: P2424093
  Class: DIT-2B-01
  Last Edited: 30/1/2026
*/

package models;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;

public class Reviews {
    private int feedbackId;
    private int userId;
    private int overallRating;
    private int caregiverRating;
    private String comments;
    private Timestamp createdAt;
    private Integer caregiverId;
    private Integer productId;
    private String caregiverName;
    private String productName;   

    public Reviews(int feedbackId, int userId, int overallRating, int caregiverRating, String comments, Timestamp createdAt, Integer caregiverId, Integer productId, String caregiverName, String productName) {
        this.feedbackId = feedbackId;
        this.userId = userId;
        this.overallRating = overallRating;
        this.caregiverRating = caregiverRating;
        this.comments = comments;
        this.createdAt = createdAt;
        this.caregiverId = caregiverId;
        this.productId = productId;
        this.caregiverName = caregiverName;
        this.productName = productName;
    }

    public int getFeedbackId() { return feedbackId; }
    public int getUserId() { return userId; }
    public int getOverallRating() { return overallRating; }
    public int getCaregiverRating() { return caregiverRating; }
    public String getComments() { return comments; }
    public Timestamp getCreatedAt() { return createdAt; }
    public Integer getCaregiverId() { return caregiverId; }
    public Integer getProductId() { return productId; }
    public String getCaregiverName() { return caregiverName; }
    public String getProductName() { return productName; }

    // VIEW ALL
    public static ArrayList<Reviews> getAllWithNames() throws SQLException {
        ArrayList<Reviews> list = new ArrayList<>();
        Connection conn = db.JDBC.connect();

        String sql =
            "SELECT f.feedback_id, f.user_id, f.overall_rating, f.caregiver_rating, f.comments, f.created_at, " +
            "       f.caregiver_id, f.product_id, " +
            "       CONCAT(c.first_name, ' ', c.last_name) AS caregiver_name, " +
            "       p.name AS product_name " +
            "FROM feedback f " +
            "LEFT JOIN caregiver c ON f.caregiver_id = c.caregiver_id " +
            "LEFT JOIN product p ON f.product_id = p.product_id " +
            "ORDER BY f.feedback_id DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Reviews(
                    rs.getInt("feedback_id"),
                    rs.getInt("user_id"),
                    rs.getInt("overall_rating"),
                    rs.getInt("caregiver_rating"),
                    rs.getString("comments"),
                    rs.getTimestamp("created_at"),
                    (Integer) rs.getObject("caregiver_id"),
                    (Integer) rs.getObject("product_id"),
                    rs.getString("caregiver_name"),
                    rs.getString("product_name")
                ));
            }
        }
        return list;
    }

    // CREATE
    public static boolean create(int userId, int overallRating, int caregiverRating,
                                 String comments, int caregiverId, int productId) throws SQLException {
        Connection conn = db.JDBC.connect();

        String sql =
            "INSERT INTO feedback (user_id, overall_rating, caregiver_rating, comments, caregiver_id, product_id, created_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, overallRating);
            ps.setInt(3, caregiverRating);
            ps.setString(4, comments != null ? comments.trim() : null);
            ps.setInt(5, caregiverId);
            ps.setInt(6, productId);
            return ps.executeUpdate() > 0;
        }
    }

    // UPDATE (owner check by user_id)
    public static boolean update(int feedbackId, int userId, int overallRating, int caregiverRating, String comments, int caregiverId, int productId) throws SQLException {
        Connection conn = db.JDBC.connect();

        // NOTE: don’t overwrite created_at; use updated_at if you have it.
        String sql =
            "UPDATE feedback " +
            "SET overall_rating = ?, caregiver_rating = ?, comments = ?, caregiver_id = ?, product_id = ? " +
            "WHERE feedback_id = ? AND user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, overallRating);
            ps.setInt(2, caregiverRating);
            ps.setString(3, comments != null ? comments.trim() : null);
            ps.setInt(4, caregiverId);
            ps.setInt(5, productId);
            ps.setInt(6, feedbackId);
            ps.setInt(7, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // (Optional)
    public static Reviews getById(int feedbackId) throws SQLException {
        Connection conn = db.JDBC.connect();

        String sql =
            "SELECT feedback_id, user_id, overall_rating, caregiver_rating, comments, created_at, caregiver_id, product_id " +
            "FROM feedback WHERE feedback_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Reviews(
                    rs.getInt("feedback_id"),
                    rs.getInt("user_id"),
                    rs.getInt("overall_rating"),
                    rs.getInt("caregiver_rating"),
                    rs.getString("comments"),
                    rs.getTimestamp("created_at"),
                    (Integer) rs.getObject("caregiver_id"),
                    (Integer) rs.getObject("product_id"),
                    null,
                    null
                );
            }
        }
        return null;
    }
}
