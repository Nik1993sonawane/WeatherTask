<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    String latitude = request.getParameter("latitude");
    String longitude = request.getParameter("longitude");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    StringBuilder jsonResponse = new StringBuilder();
    if (latitude != null && longitude != null && startDate != null && endDate != null) {
        try {
            // Database connection
            String dbURL = "jdbc:mysql://localhost:3306/weather";
            String dbUser = "root";
            String dbPass = "root";
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // Query to fetch weather data
            String query = "SELECT date, max_temp, min_temp, mean_temp, max_apparent_temp, min_apparent_temp, mean_apparent_temp FROM weather WHERE latitude = ? AND longitude = ? AND date BETWEEN ? AND ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, latitude);
            stmt.setString(2, longitude);
            stmt.setString(3, startDate);
            stmt.setString(4, endDate);

            ResultSet rs = stmt.executeQuery();

            // Construct JSON-like response
            jsonResponse.append("{ \"status\": \"success\", \"data\": [");
            boolean firstRecord = true;
            while (rs.next()) {
                if (!firstRecord) {
                    jsonResponse.append(",");
                }
                jsonResponse.append("{")
                    .append("\"date\":\"").append(rs.getString("date")).append("\",")
                    .append("\"maxTemp\":").append(rs.getDouble("max_temp")).append(",")
                    .append("\"minTemp\":").append(rs.getDouble("min_temp")).append(",")
                    .append("\"meanTemp\":").append(rs.getDouble("mean_temp")).append(",")
                    .append("\"maxApparentTemp\":").append(rs.getDouble("max_apparent_temp")).append(",")
                    .append("\"minApparentTemp\":").append(rs.getDouble("min_apparent_temp")).append(",")
                    .append("\"meanApparentTemp\":").append(rs.getDouble("mean_apparent_temp"))
                    .append("}");
                firstRecord = false;
            }
            jsonResponse.append("]}");

            conn.close();
        } catch (Exception e) {
            jsonResponse.setLength(0); // Clear the response
            jsonResponse.append("{ \"status\": \"error\", \"message\": \"").append(e.getMessage()).append("\" }");
        }
    } else {
        jsonResponse.append("{ \"status\": \"error\", \"message\": \"Invalid input parameters.\" }");
    }

    out.print(jsonResponse.toString());
%>
