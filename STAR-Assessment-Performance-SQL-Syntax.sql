/*Percetage of students at or Above Benchmark*/
CREATE TEMP TABLE t1 AS 
SELECT *,
  CAST(TRIM(REPLACE(Teacher_Name,'Teacher','')) AS int64) AS Teacher_Number, -- making teacher name an integer for statistical measurement
  ROUND(a.Absent/a.Membership,2) AS Abs_Pct,
  CASE
    WHEN ROUND(a.Absent/a.Membership,2) >= .10 THEN 'Yes' ELSE 'No' END AS Chronically_Absent
FROM `single-being-353600.KIPP_Columbus_Performance_Task.STAR_Assessment_Data` AS s
LEFT JOIN `single-being-353600.KIPP_Columbus_Performance_Task.Att_Table` AS a
ON s.Student_ID = a.Student_Number
WHERE (s.Teacher_Name IS NOT NULL) AND (s.Test_Type IS NOT NULL) AND (s.Percentile_Rank IS NOT NULL) AND (a.Status = 'Active');

-- Overall Proficiency 
SELECT 
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) * 100,2) AS Benchmark_or_Above_Overall
FROM t1;

-- Overall Proficiency Gen Ed v Services
SELECT 
 DISTINCT Special_Education_Program, -- 0 = Gen Ed, 1 = Special Education Student
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Special_Education_Program ) * 100,2) AS Benchmark_or_Above_Overall
FROM t1;

-- Overall Proficiency Chronically Absent
SELECT
  DISTINCT Chronically_Absent,
  Benchmark_or_Above_Overall,
  COALESCE(Benchmark_or_Above_Overall - LAG(Benchmark_or_Above_Overall,1) OVER (ORDER BY Benchmark_or_Above_Overall),0) AS Diff,
  COALESCE(ROUND((Benchmark_or_Above_Overall - LAG(Benchmark_or_Above_Overall,1) OVER (ORDER BY Benchmark_or_Above_Overall)) / LAG(Benchmark_or_Above_Overall,1) OVER (ORDER BY Benchmark_or_Above_Overall) * 100,2),0) AS Pct_Diff
FROM
(SELECT 
 DISTINCT Chronically_Absent,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Chronically_Absent ) * 100,2) AS Benchmark_or_Above_Overall
FROM t1)
ORDER BY Benchmark_or_Above_Overall;
-- >= .10 Absenteeism rate is Chronically Absent


-- Proficiency by subject
SELECT 
  DISTINCT Test_Type,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Test_Type) * 100,2) AS Benchmark_or_Above_Subject
FROM t1
ORDER BY Benchmark_or_Above_Subject;

-- Proficiency by subject Gen Ed v Services
SELECT 
  DISTINCT Test_Type,
  Special_Education_Program,-- -- 0 = Gen Ed, 1 = Special Education Student
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Test_Type,Special_Education_Program) * 100,2) AS Benchmark_or_Above_Subject
FROM t1
ORDER BY Benchmark_or_Above_Subject;


-- Overall Proficiency Grade
SELECT 
   DISTINCT Current_Grade,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Current_Grade) * 100,2) AS Benchmark_or_Above_Overall_Grade,
  ROUND(AVG(CASE WHEN Percentile_Rank < 25 THEN 1 ELSE 0 END) OVER (PARTITION BY Current_Grade) * 100,2) AS Intervention_Metric
FROM t1
ORDER BY Benchmark_or_Above_Overall_Grade;
-- Percentile Rank >= 40 is considered to be at benchmark or above
-- Percentile Rank < 25 is considered to need intervention

-- Overall Proficiency Grade Gen Ed v Services
SELECT 
   DISTINCT Current_Grade,
    Special_Education_Program,-- -- 0 = Gen Ed, 1 = Special Education Student
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Current_Grade, Special_Education_Program) * 100,2) AS Benchmark_or_Above_Overall_Grade,
FROM t1
ORDER BY Current_Grade;

-- Reading proficiency by grade
SELECT 
  DISTINCT Test_Type,
  Current_Grade,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Test_Type,Current_Grade),2) * 100 AS Benchmark_or_Above_Grade
FROM t1
WHERE Test_Type = 'Star Reading Enterprise Tests'
ORDER BY Benchmark_or_Above_Grade DESC;

-- Math proficiency by grade
SELECT 
  DISTINCT Test_Type,
  Current_Grade,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Test_Type,Current_Grade),2) * 100 AS Benchmark_or_Above_Grade
FROM t1
WHERE Test_Type = 'Star Math Enterprise Tests'
ORDER BY Benchmark_or_Above_Grade DESC;

-- Overall Proficiency Teacher
SELECT 
   DISTINCT Teacher_Number,
  ROUND(AVG(CASE WHEN Percentile_Rank >= 40 THEN 1 ELSE 0 END) OVER (PARTITION BY Teacher_Number) * 100,2) AS Benchmark_or_Above_Overall_Teacher
FROM t1
ORDER BY Benchmark_or_Above_Overall_Teacher DESC;
