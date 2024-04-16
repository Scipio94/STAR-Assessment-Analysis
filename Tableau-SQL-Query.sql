/*SQL Query to Load Data into Tableau*/
SELECT *
FROM `single-being-353600.KIPP_Columbus_Performance_Task.STAR_Assessment_Data` AS s -- STAR Data Table
LEFT JOIN `single-being-353600.KIPP_Columbus_Performance_Task.Att_Table` AS a -- Attendance Data Table
ON s.Student_ID = a.Student_Number -- Unique Identifiers for each table
WHERE (s.Teacher_Name IS NOT NULL) AND (s.Test_Type IS NOT NULL) AND (s.Percentile_Rank IS NOT NULL) AND (a.Status = 'Active');
-- WHERE statement to return relevant values
