/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Handler for admin dashboard statistics (users, orders, feedback, products counts)
 */
package handlers;

import java.sql.*;
import java.util.*;
import db.JDBC;

public class AdminDashboardHandler {

    public static Map<String,Integer> getStats() throws SQLException {
        Map<String,Integer> stats = new HashMap<>();
        String[] queries = {
            "SELECT COUNT(*) FROM \"user\"",
            "SELECT COUNT(*) FROM \"order\"",
            "SELECT COUNT(*) FROM feedback",
            "SELECT COUNT(*) FROM product"
        };
        try (Connection conn = JDBC.connect()) {
            if (conn == null) throw new SQLException("Connection failed");
            for (int i = 0; i < queries.length; i++) {
                try (PreparedStatement ps = conn.prepareStatement(queries[i]); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int val = rs.getInt(1);
                        switch(i) {
                            case 0: stats.put("totalUsers", val); break;
                            case 1: stats.put("totalOrders", val); break;
                            case 2: stats.put("totalFeedback", val); break;
                            case 3: stats.put("totalProducts", val); break;
                        }
                    }
                }
            }
        }
        return stats;
    }
}
