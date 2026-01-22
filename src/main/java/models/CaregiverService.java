/*
  Author: Goh Yi Xin Karys
  Admin No: P2424431
  Class: DIT-2B-01
  Last Edited: 22/01/2026
*/

package models;

import java.sql.*;
import java.util.ArrayList;

public class CaregiverService {
    public static ArrayList<Product> getAssignedServices(int caregiverId) throws SQLException {
        ArrayList<Product> services = new ArrayList<>();
        String sql = "SELECT p.* FROM product p JOIN service_caregiver sc ON p.product_id = sc.product_id WHERE sc.caregiver_id = ? AND sc.is_available = true ORDER BY p.name";
        try (Connection conn = db.JDBC.connect(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, caregiverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(new Product(
                        rs.getInt("product_id"),
                        null, // category, can be set if needed
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getFloat("price"),
                        rs.getBoolean("is_active"),
                        rs.getString("image_path"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    ));
                }
            }
        }
        return services;
    }
}
