/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely
- Focuses on job postings with specified salaries (remove nulls)
- BONUS: Include company names of top 10 roles
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
*/

-- SELECT	
-- 	job_id,
-- 	job_title,
-- 	job_location,
-- 	job_schedule_type,
-- 	salary_year_avg,
-- 	job_posted_date
    
-- FROM
--     job_postings_fact

-- WHERE
-- job_title_short = 'Data Analyst' 
-- AND
-- job_location = 'Anywhere'
-- AND
-- salary_year_avg IS NOT NULL
-- ORDER BY
-- salary_year_avg DESC
-- limit 10;

-- now if we want to know the company name also we must use join and with join company_dim

SELECT	
	job_id,
    company_dim.name AS name_of_company,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date
    
FROM
    job_postings_fact

LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id 

WHERE
job_title_short = 'Data Analyst' 
-- like this we can search for any role from here..
AND
job_location = 'Anywhere'
AND
salary_year_avg IS NOT NULL
ORDER BY
salary_year_avg DESC
limit 10;
