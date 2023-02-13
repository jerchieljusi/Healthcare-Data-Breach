# Healthcare Data Breach
This is exploring the healthcare data breach [dataset](https://data.world/health/health-data-breaches) from 2009-2016 provided by the Department of Health and Human Services. I used Microsoft SQL Server to remove any null values, fill in null values, and remove any unnecessary rows and columns before developing a dashboard on Tableau. 

## Data Cleaning 

I need to change the column names in a more coherent format to make it easier when selecting them for analysis. On Microsoft SQL server there are 2 ways to do this. 

**Rename a column using Object Explorer**
1. In **Object Explorer**, connect to an instance of Database engine. 
2. In **Object Explorer**, right-click the table in which you want to rename columns and choose **Rename**.
3. Type a new column name.

**Rename a column using table designer**
1. In **Object Explorer**, right-click the table to which you want to rename columns and choose **Design**. 
2. Under **Column Name**, select the name you want to change and type a new one. 
3. On the **File** menu, select **Save** ***table name***. 

For more details on how to change column name, click [here](https://learn.microsoft.com/en-us/sql/relational-databases/tables/rename-columns-database-engine?view=sql-server-ver16), 

I need to reformat breach_submission_date column to DATE format. 

``` sql 
ALTER TABLE dbo.ReportTable
ALTER COLUMN breach_submission_date DATE; 
```
Extract year from breach_submission_date column and create a new column. 

``` sql 
SELECT 
  DATEPART(year, breach_submission_date_year) AS year
 FROM dbo.ReportTable; 
 
ALTER TABLE dbo.ReportTable
 ADD year INT; 
 
UPDATE dbo.ReportTable
 SET year = DATEPART(year, breach_submission_date_year);
```
See if there's any duplicates and delete the duplicate 
 ``` sql 
DELETE * 
 FROM (
  SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY name_of_covered_entity, state, covered_entity_type, 
    individuals_affected, breach_submission_date ORDER BY name_of_covered_entity) row_num 
    FROM dbo.ReportTable) a
 WHERE row_num > 1;
 ```
Check if there's any nulls on state column 
``` sql 
SELECT * 
FROM dbo.ReportTable
WHERE state IS NULL; 
```
It seems like the rows with no states are companies out of the US. We can delete those since this analysis is only focusing in US data. 
``` sql 
DELETE FROM dbo.ReportTable WHERE state IS NULL; 
```
Checking if there's any nulls on individuals_affected 
``` sql
SELECT * 
FROM dbo.ReportTable
WHERE individuals_affected IS NULL; 
``` 
Delete any null values for individuals_affected.
``` sql
DELETE FROM dbo.ReportTable WHERE individuals_affected IS NULL; 
```
Check to see if there's any null values on covered_entity_type
``` sql 
SELECT * 
FROM dbo.ReportTable 
WHERE covered_entity_type IS NULL; 
```
Checking to see if any of the names were inputted more than once to see if we can use existing data to populate the ones that are null 
``` sql 
SELECT 
	a.name_of_covered_entity, 
	a.covered_entity_type, 
	b.name_of_covered_entity, 
	b.covered_entity_type
FROM dbo.ReportTable AS a
JOIN dbo.ReportTable AS b 
	ON a.name_of_covered_entity = b.name_of_covered_entity
WHERE a.covered_entity_type IS NULL 
```
Populate the missing covered_entity_type with existing one 
``` sql 
UPDATE a
SET covered_entity_type = ISNULL(a.covered_entity_type, b.covered_entity_type) 
FROM dbo.ReportTable AS a
JOIN dbo.ReportTable AS b 
	ON a.name_of_covered_entity = b.name_of_covered_entity
WHERE a.covered_entity_type IS NULL 
```

SELECT * FROM dbo.ReportTable
  
## Visualization 

<div class='tableauPlaceholder' id='viz1676318374109' style='position: relative'><noscript><a href='#'><img alt='Healthcare Data Breach  ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;He&#47;HealthcareDataBreach_16760598564730&#47;Dashboard1&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='HealthcareDataBreach_16760598564730&#47;Dashboard1' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;He&#47;HealthcareDataBreach_16760598564730&#47;Dashboard1&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en-US' /></object></div>                


