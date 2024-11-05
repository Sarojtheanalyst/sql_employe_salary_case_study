use school;
select * from salaries;

-- load the datas 
 /*LOAD DATA INFILE "R://case study//salaries.csv"
INTO TABLE salaries
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;    */

select * from salaries limit 10;
select count(*) from salaries;

/*1.You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries who give work fully remotely, for the title
 'managers’ Paying salaries Exceeding $90,000 USD*/
SELECT distINct(company_locatiON) FROM salaries WHERE 
job_title like '%Manager%' and salary_IN_usd > 90000 and remote_ratio= 100;

/*2.AS a remote work advocate Working for a progressive HR tech startup 
who place their freshers’ clients IN large   */
SELECT company_locatiON, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_locatiON 
ORDER BY cnt DESC
LIMIT 5;

/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is
 to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light 
ON the attractiveness of high-paying remote positions IN today's job market.*/
set @COUNT= (SELECT COUNT(*) FROM salaries  WHERE salary_IN_usd >100000 and remote_ratio=100);  -- salary>1 lakh and remote
set @total = (SELECT COUNT(*) FROM salaries where salary_in_usd>100000);
set @percentage= round((((SELECT @COUNT)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people workINg remotly and havINg salary >100,000 USD';

/*4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to
 identify the Locations where
 entry-level average salaries exceed the average salary for that job title in market for entry level,
 helping your agency guide candidates towards lucrative countries.*/

SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average;


-- break down the query 
SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries
 WHERE experience_level = 'EN' 
GROUP BY  company_locatiON, job_title; -- company_location , job_title , average_per_country

SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title; -- job_ttile , average 

-- practice 
select company_location , count(*) as 'countrys ' from (
SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average) as t group by t.company_location;



/*5. You've been hired by a big HR Consultancy to look at how much 
people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/
SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1;

-- break down the query 
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title;

-- practice 
select company_location,count(*) as 'counts' from (
SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1) as sw group by company_location;

-- p2
select count(*) from (
SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1 and company_locatiON='US') as l;


select year(current_date())-2;

select current_date;


/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary 
trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years
 (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/


WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022;-- step 3 and havINg step 4.

-- break down the each querys 
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years
 FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
GROUP BY  company_locatiON HAVING  num_years = 3;

select * from salaries limit 10;

SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(work_year) AS num_years
 FROM salaries group by company_locatiON;
 
 --
 select count(distinct(work_year)) from salaries where company_locatiON='US';
 
 SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years
 FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2 GROUP BY  company_locatiON;
 
 
 SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years
 FROM salaries GROUP BY  company_locatiON;

select company_location from(
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years
 FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
GROUP BY  company_locatiON HAVING  num_years = 3
) t ; -- this will provide the company name with the 3 years 

-- provide all the details of the country who hgas 3 years of datas
with t as ( 
select * from salaries where company_location in (
select company_location from(
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years
 FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
GROUP BY  company_locatiON HAVING  num_years = 3
) l
))
select distinct(company_location) from t;


-- 
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  salaries GROUP BY company_locatiON, work_year;

-- SELECT  work_year,company_location , AVG(salary_IN_usd) AS average FROM  salaries GROUP BY  work_year ,company_locatiON;

select * from (
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  salaries 
GROUP BY company_locatiON, work_year) T  where company_locatiON='US';

-- corect 
WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022;


-- practice
WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    COUNT(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    COUNT(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    COUNT(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON; 


 /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to
 determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant
 INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 
 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 
 -- we can apply the differnt filter in here
  SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level;
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level where t1.experience_level='EN' ;
 
 -- break down the query 
SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021
 and remote_ratio = 100 GROUP BY experience_level;
 
 select * from salaries limit 10;


 
/* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over 
time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024,
 helpINg the company stay competitive IN the talent market.*/
WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
  SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL ;-- STEP 3

-- practice 4 
select * from (
WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1
SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL
)t where changes>4 and changes<6;
-- breaking the query 
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 
'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY
 experience_level, job_title, work_year;

-- 21,23
WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2022,2023) GROUP BY experience_level, job_title, work_year
)  -- step 1

SELECT *,round((((AVG_salary_2023-AVG_salary_2022)/AVG_salary_2022)*100),2)  AS changes
FROM
(
  SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2022 THEN average END) AS AVG_salary_2022,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2023-AVG_salary_2022)/AVG_salary_2022)*100)  IS NOT NULL ;-- STEP 3



/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences
 such as 
( their year of experience , their employment type, company location and company size )  and want to make
 an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data 
engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, 
so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.
call GetAverageSalary('EN','FT','US','L'); -- EXPERIENCE LEVEL , EMPLOYEE_TYPE , COMPANY_LOCATION,
call GetAverageSalary('EN','FT','US','M');

-- COMPANY_SIZE
--

-- break down the query 
-- n remote rarion also
DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2),IN remote INT)
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type,remote_ratio, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type AND remote_ratio=remote
    GROUP BY experience_level, employment_type, company_location, company_size, job_title ,remote_ratio order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.
call GetAverageSalary('EN','FT','US','L'); -- EXPERIENCE LEVEL , EMPLOYEE_TYPE , COMPANY_LOCATION,
call GetAverageSalary('EN','FT','US','M',100);
call GetAverageSalary('EN','FT','US','M',0);

drop procedure Getaveragesalary
