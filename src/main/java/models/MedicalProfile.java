package models;

import java.sql.*;

import db.JDBC;

public class MedicalProfile {

  private int medicalProfileId;
  private int clientId;
  private String bloodType;
  private String allergies;
  private String chronicConditions;
  private String medications;
  private String mobilityLevel;
  private String cognitiveStatus;
  private String preferredHospital;
  private String doctorName;
  private String doctorContact;
  private String notes;
  private Timestamp createdAt;
  private Timestamp updatedAt;

  public MedicalProfile(int medicalProfileId, int clientId, String bloodType, String allergies,
      String chronicConditions, String medications, String mobilityLevel, String cognitiveStatus,
      String preferredHospital, String doctorName, String doctorContact, String notes, Timestamp createdAt,
      Timestamp updatedAt) {
    super();
    this.medicalProfileId = medicalProfileId;
    this.clientId = clientId;
    this.bloodType = bloodType;
    this.allergies = allergies;
    this.chronicConditions = chronicConditions;
    this.medications = medications;
    this.mobilityLevel = mobilityLevel;
    this.cognitiveStatus = cognitiveStatus;
    this.preferredHospital = preferredHospital;
    this.doctorName = doctorName;
    this.doctorContact = doctorContact;
    this.notes = notes;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  public static MedicalProfile getMedicalProfileByClientId(int _clientId) throws SQLException {
    final Connection conn = JDBC.connect();
    if (conn == null) {
      throw new SQLException("Database connection failed");
    }

    String sql = new StringBuilder()
        .append("SELECT * ")
        .append("FROM client_medical_profile ")
        .append("WHERE client_id = ?;")
        .toString();

    final PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, _clientId);
    final ResultSet rs = stmt.executeQuery();

    MedicalProfile profile = null;
    if (rs.next()) {
      profile = resultMapper(rs);
    }

    conn.close();
    return profile;
  }

  private static MedicalProfile resultMapper(ResultSet rs) throws SQLException {
    int id = rs.getInt("medical_profile_id");
    int clientId = rs.getInt("client_id");
    final String bloodType = rs.getString("blood_type");
    final String allergies = rs.getString("allergies");
    final String chronicConditions = rs.getString("chronic_conditions");
    final String medications = rs.getString("medications");
    final String mobilityLevel = rs.getString("mobility_level");
    final String cognitiveStatus = rs.getString("cognitive_status");
    final String preferredHospital = rs.getString("preferred_hospital");
    final String doctorName = rs.getString("doctor_name");
    final String doctorContact = rs.getString("doctor_contact");
    final String notes = rs.getString("notes");
    final Timestamp createdAt = rs.getTimestamp("created_at");
    final Timestamp updatedAt = rs.getTimestamp("updated_at");

    return new MedicalProfile(id, clientId, bloodType, allergies,
        chronicConditions, medications, mobilityLevel,
        cognitiveStatus, preferredHospital, doctorName,
        doctorContact, notes, createdAt, updatedAt);
  }

  public int getMedicalProfileId() {
    return medicalProfileId;
  }

  public int getClientId() {
    return clientId;
  }

  public String getBloodType() {
    return bloodType;
  }

  public String getAllergies() {
    return allergies;
  }

  public String getChronicConditions() {
    return chronicConditions;
  }

  public String getMedications() {
    return medications;
  }

  public String getMobilityLevel() {
    return mobilityLevel;
  }

  public String getCognitiveStatus() {
    return cognitiveStatus;
  }

  public String getPreferredHospital() {
    return preferredHospital;
  }

  public String getDoctorName() {
    return doctorName;
  }

  public String getDoctorContact() {
    return doctorContact;
  }

  public String getNotes() {
    return notes;
  }

  public Timestamp getCreatedAt() {
    return createdAt;
  }

  public Timestamp getUpdatedAt() {
    return updatedAt;
  }

}
