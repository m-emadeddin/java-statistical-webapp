<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Some Aggregates</title>
    <link rel="icon" type="image/png" href="resume.png">
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body {
            font-family: 'Helvetica', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f3f0f5; /* Light purple background */
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .container {
            width: 70%;
            margin-top: 30px;
            margin-bottom: 30px;
            display: flex;
            justify-content: center; /* Center content horizontally */
        }

        .header {
            background-color: #7e57c2; /* Violet header */
            color: #ffffff; /* White text color */
            padding: 20px;
            text-align: center;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            width: 100%; /* Full width */
            margin-bottom: 20px; /* Add space below header */
        }

        .infoTable {
            width: 80%;
            max-width: 80%; /* Ensure table doesn't exceed container width */
            border-collapse: collapse;
            background-color: #ffffff; /* White background for table */
            box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
        }

        .infoTable th, .infoTable td {
            border: 1px solid #ede7f6; /* Light purple border */
            padding: 12px 15px;
            text-align: left;
        }

        .infoTable th {
            background-color: #ba68c8; /* Dark purple background for headers */
            color: #ffffff;
            font-weight: bold;
        }

        .infoTable tr:nth-child(even) {
            background-color: #f3e5f5; /* Alternate row color */
        }

        .infoTable tr:hover {
            background-color: #e1bee7; /* Light purple background on row hover */
            cursor: pointer;
        }

        h1 {
            font-size: 28px; /* Larger font size */
            font-weight: bold; /* Bold text */
            color: #7e57c2; /* Violet color */
            background-color: #ffffff; /* White background */
            padding: 10px 20px; /* Padding around text */
            border-radius: 5px; /* Rounded corners */
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); /* Subtle shadow */
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.15); /* Text shadow for depth */
            margin-top: 30px; /* More space on top */
            margin-bottom: 20px; /* Space below */
            width: 100%; /* Control the width */
            text-align: center; /* Ensure text is centered */
        }



    </style>

    <script type="text/javascript">
       // to draw charts
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Country');
            data.addColumn('number', 'Percentage');

            <% 
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                // 
                StringBuilder mostActiveData = new StringBuilder();
                StringBuilder languageData = new StringBuilder();
                StringBuilder projectData = new StringBuilder();
                StringBuilder courseData = new StringBuilder();
                StringBuilder enrollmentData = new StringBuilder();
                StringBuilder zagPeopleData = new StringBuilder();
                
                try {
                    String url = "jdbc:mysql://localhost:3306/mycvproject?useSSL=false";
                    String user = "root";
                    String password = "root";
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, user, password);
                    
                    // chart query
                    String chartQuery = "SELECT country, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM person) AS percentage FROM person GROUP BY country";
                    pstmt = conn.prepareStatement(chartQuery);
                    rs = pstmt.executeQuery();
                    

                    while(rs.next()) {
                        out.println("data.addRow(['" + rs.getString("country").replaceAll("'", "\\\\'") + "', " + rs.getDouble("percentage") + "]);");
                    }
                            
                    
                    // GET MOST ACTIVE PEOPLE
                    String mostActiveQuery = "SELECT p.idperson, p.fName, p.lName, " +
                                             " COUNT(DISTINCT l.idlanguage) AS language_count, " +
                                             "COUNT(DISTINCT t.idapp) AS training_count, " +
                                             " COUNT(DISTINCT c.idcourse) AS course_count " +
                                             " FROM person p LEFT JOIN language l ON p.idperson = l.person_idperson" +
                                             " LEFT JOIN training t ON p.idperson = t.person_idperson " +
                                             "LEFT JOIN course c ON p.idperson = c.person_idperson " +
                                             " GROUP BY p.idperson, p.fName, p.lName " +
                                             " ORDER BY language_count DESC, training_count DESC, course_count DESC LIMIT 3;" ;
                    pstmt = conn.prepareStatement(mostActiveQuery);
                    rs = pstmt.executeQuery();
                    
                    // Start building the HTML table
                    mostActiveData.append("<table class='infoTable'>");
                    mostActiveData.append("<tr><th>Person Full Name</th><th>No. of Programming Lnaguages Knowledge</th><th>No. of Trainings</th> <th> No. of Courses Attended</th></tr>");  // Table header

                    while (rs.next()) {
                        mostActiveData.append("<tr>")
                                    .append("<td>").append(rs.getString("fName") + " " + rs.getString("lName")).append("</td>")
                                    .append("<td>").append(rs.getInt("language_count")).append("</td>")
                                    .append("<td>").append(rs.getInt("training_count")).append("</td>")
                                    .append("<td>").append(rs.getInt("course_count")).append("</td>")
                                    .append("</tr>");
                    }
                    mostActiveData.append("</table>");



                    // fetch language counts
                   String languageQuery = "SELECT languageName, COUNT(*) AS count " +
                                "FROM mycvproject.language " + 
                                "WHERE languageName IS NOT NULL AND languageName <> '' " +
                                "GROUP BY languageName " +
                                "ORDER BY count DESC; ";
                    pstmt = conn.prepareStatement(languageQuery);
                    rs = pstmt.executeQuery();

                    // Start building the HTML table
                    languageData.append("<table class='infoTable'>");
                    languageData.append("<tr><th>Language Name</th><th>Count</th></tr>");  // Table header

                    while (rs.next()) {
                        languageData.append("<tr>")
                                    .append("<td>").append(rs.getString("languageName")).append("</td>")
                                    .append("<td>").append(rs.getInt("count")).append("</td>")
                                    .append("</tr>");
                    }
                    languageData.append("</table>");

                    // most common projects in egypt
                    String projectQuery = "SELECT projectName as most_common_project_in_Egypt, COUNT(*) as count " +
                        "FROM mycvproject.project " +
                        "JOIN mycvproject.person ON person.idperson = project.person_idperson " +
                        "WHERE country = 'Egypt' AND projectName IS NOT NULL AND TRIM(projectName) <> '' " +
                        "GROUP BY projectName " +
                        "ORDER BY count DESC " +
                        "LIMIT 4;";
                    pstmt = conn.prepareStatement(projectQuery);
                    rs = pstmt.executeQuery();

                    // Build HTML table data
                    projectData.append("<table class='infoTable'><tr><th>Project Name</th><th>Count</th></tr>");
                    while (rs.next()) {
                        projectData.append("<tr><td>")
                                  .append(rs.getString("most_common_project_in_Egypt"))
                                  .append("</td><td>")
                                  .append(rs.getInt("count"))
                                  .append("</td></tr>");
                    }
                    projectData.append("</table>");
                    // most enrolled courses
                   String enrollmentQuery = "SELECT courseName, COUNT(idperson) AS total_enrollments " +
                                     "FROM mycvproject.course " +
                                     "JOIN mycvproject.person ON person.idperson = course.person_idperson " +
                                     "WHERE courseName IS NOT NULL AND TRIM(courseName) <> '' " +
                                     "GROUP BY courseName " +
                                     "ORDER BY total_enrollments DESC " +
                                     "LIMIT 5";
                    pstmt = conn.prepareStatement(enrollmentQuery);
                    rs = pstmt.executeQuery();

                    // Start table HTML for top enrollments
                    enrollmentData.append("<table class='infoTable'><tr><th>Course Name</th><th>Total Enrollments</th></tr>");
                    while (rs.next()) {
                        enrollmentData.append("<tr><td>")
                                      .append(rs.getString("courseName"))
                                      .append("</td><td>")
                                      .append(rs.getInt("total_enrollments"))
                                      .append("</td></tr>");
                    }
                    enrollmentData.append("</table>");
                  
                    
                   

                    // Fetch count of people from Zagazig
                   String peopleQuery = "SELECT fName, lName,  (SELECT COUNT(*) FROM mycvproject.person WHERE city = 'Zagazig') AS totalCount FROM mycvproject.person WHERE city = 'Zagazig'";
                    pstmt = conn.prepareStatement(peopleQuery);
                    rs = pstmt.executeQuery();
   

                    // Start building the HTML table
                    zagPeopleData.append("<table class='infoTable'><tr><th>First Name</th><th>Last Name</th></tr>");
                    int totalCount = 0; 
                    while (rs.next()) {
                        totalCount++;
                        // Append each row of data to the table
                        zagPeopleData.append("<tr><td style='width: 50%;'>")
                                     .append(rs.getString("fName"))
                                     .append("</td><td style='width: 50%;'>")
                                     .append(rs.getString("lName"))
                                     .append("</td></tr>");
                    }
                    // Append the final row with the total count
                    zagPeopleData.append("<tr><td colspan='2' style='text-align: center;'><strong>Total People from Zagazig: ")
                        .append(totalCount)
                        .append("</strong></td></tr>");
                    zagPeopleData.append("</table>");
                    
                } catch(Exception e) {
                    out.println("/* Exception: " + e.toString() + " */");
                    
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("/* RS Close Error: " + e.getMessage() + " */"); }
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("/* Stmt Close Error: " + e.getMessage() + " */"); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { out.println("/* Conn Close Error: " + e.getMessage() + " */"); }
                }
            %>

            var options = {
                title: 'Percentage of Nationalities',
                pieSliceText: 'percentage',
                is3D: true,
                width: 700,
                height: 400
            };

            var chart = new google.visualization.PieChart(document.getElementById('piechart'));
            chart.draw(data, options);
            // Select the <rect> element
            var rectElement = document.querySelector('rect');

            // Update the fill attribute
            rectElement.setAttribute('fill', '#f3f0f5');

        }
    </script>
</head>
<body>
    <h1>Top 3 Active People </h1>
    <%=mostActiveData.toString()%>     
    <h1>Programming Languages </h1>
    <%=languageData.toString()%> 
    <h1>Top Projects in Egypt</h1>
    <%=projectData.toString()%> 
    <h1>Top 5 Enrolled Courses</h1>
    <%=enrollmentData.toString()%> 
    <h1>Nationality Statistics</h1>
    <div id="piechart"></div>
    <h1>People from Zagazig</h1>
    <%=zagPeopleData.toString()%>
    
</body>

</html>
