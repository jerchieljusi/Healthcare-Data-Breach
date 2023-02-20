ALTER TABLE dbo.ReportTable
ALTER COLUMN breach_submission_date DATE; 

SELECT 
  DATEPART(year, breach_submission_date_year) AS year
 FROM dbo.ReportTable; 
 
ALTER TABLE dbo.ReportTable
 ADD year INT; 
 
UPDATE dbo.ReportTable
 SET year = DATEPART(year, breach_submission_date_year);

 DELETE * 
FROM (
 SELECT *, 
   ROW_NUMBER() OVER(PARTITION BY name_of_covered_entity, state, covered_entity_type, 
   individuals_affected, breach_submission_date ORDER BY name_of_covered_entity) row_num 
   FROM dbo.ReportTable) a
WHERE row_num > 1;

SELECT * 
FROM dbo.ReportTable
WHERE state IS NULL; 

DELETE FROM dbo.ReportTable WHERE state IS NULL;

SELECT * 
FROM dbo.ReportTable
WHERE individuals_affected IS NULL; 

DELETE FROM dbo.ReportTable WHERE individuals_affected IS NULL; 

SELECT * 
FROM dbo.ReportTable 
WHERE covered_entity_type IS NULL; 

SELECT 
	a.name_of_covered_entity, 
	a.covered_entity_type, 
	b.name_of_covered_entity, 
	b.covered_entity_type
FROM dbo.ReportTable AS a
JOIN dbo.ReportTable AS b 
	ON a.name_of_covered_entity = b.name_of_covered_entity
WHERE a.covered_entity_type IS NULL 

UPDATE a
SET covered_entity_type = ISNULL(a.covered_entity_type, b.covered_entity_type) 
FROM dbo.ReportTable AS a
JOIN dbo.ReportTable AS b 
	ON a.name_of_covered_entity = b.name_of_covered_entity
WHERE a.covered_entity_type IS NULL 