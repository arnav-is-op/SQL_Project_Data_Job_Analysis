/*
1) Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely
- Focuses on job postings with specified salaries (remove nulls)
- BONUS: Include company names of top 10 roles
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
*/

SELECT 
company_dim.name AS name_of_company,
job_title_short,
job_location,
salary_year_avg
FROM
job_postings_fact
LEFT JOIN 
company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
job_location = 'Anywhere'
AND
salary_year_avg IS NOT NULL
ORDER BY
salary_year_avg DESC
LIMIT
10;

-- we got top 10 higest paying companies for data analyst here

/*
2) Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles
- Why? It provides a detailed look at which high-paying jobs demand certain skills, 
    helping job seekers understand which skills to develop that align with top salaries
or to be more clear 
Among remote Data Analyst jobs with a specified salary,
which skills appear most frequently in job postings?
*/

WITH cte AS
(

SELECT
job_id,
company_dim.name,
job_title_short,
job_location,
salary_year_avg
FROM
job_postings_fact
LEFT JOIN
company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
job_title_short = 'Data Analyst'
AND
job_location = 'Anywhere'
AND
salary_year_avg IS NOT NULL
ORDER BY
salary_year_avg DESC
LIMIT
10

)

SELECT 
cte.*,
skills_dim.skills
FROM
cte
INNER JOIN
skills_job_dim ON cte.job_id = skills_job_dim.job_id
INNER JOIN
skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

/*You joined job_postings_fact → skills_job_dim → skills_dim.
One job
→ can have many skills
→ so one job becomes multiple rows.
Example from your output:
Data base administrator
Salary: 400000
Skills:oracle,kafka,linux,git,svn,That is ONE job.But after join, it becomes 5 rows
ORDER → LIMIT (inside CTE) → then JOIN
now 
What LEFT JOIN does
It keeps all jobs from the left side.
If a job has no skills:
job info | NULL skill
Now your output contains useless rows.
You are answering:
“What skills are required?”
NULL is not a skill. so inner join

Final JOIN result:

job_id	company	salary	skill
1	AT&T	400000	SQL
1	AT&T	400000	Python
1	AT&T	400000	Tableau
2	Pinterest	380000	Excel
2	Pinterest	380000	R

You still have only 10 jobs.

You now have many job-skill rows.
*/



/*

3) Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
    providing insights into the most valuable skills for job seekers.
*/

-- “What are the top 5 most in-demand skills ie the count of skills for Data Analyst roles, 
-- based on job postings that list a salary?”


SELECT
skills_dim.skills AS skills,
COUNT(skills_dim.skills) AS job_count,
FROM
job_postings_fact
INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
INNER JOIN skills_dim  ON skills_dim.skill_id = skills_job_dim.skill_id

WHERE

job_title_short = 'Data Analyst'
-- AND
-- job_location = 'Anywhere'
-- AND
-- salary_year_avg IS NOT NULL
GROUP BY
skills
ORDER BY
job_count DESC
LIMIT 5 ;


/*
Answer: 4) What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focuses on roles with specified salaries, regardless of location
- Why? It reveals how different skills impact salary levels for Data Analysts and 
    helps identify the most financially rewarding skills to acquire or improve
ie high demand and high paying skill
 this is also almost same like last one we need avg sal form job_postings_fact and skkils from skills_dim
 but instead of count in the previous one here we want average thats it..
*/


 SELECT
 skills_dim.skills AS skills,
 ROUND(AVG(salary_year_avg),0) AS avg_sal
 FROM
 job_postings_fact
 INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
 INNER JOIN skills_dim  ON skills_dim.skill_id = skills_job_dim.skill_id
 WHERE
 job_title_short = 'Data Analyst'
 AND
 salary_year_avg IS NOT NULL
 GROUP BY
 skills
 ORDER BY
 avg_sal DESC
 LIMIT
 30;

/*
(i) Why AVG(salary_year_avg) is required
When you use GROUP BY skills, every other selected column must either:
Be in GROUP BY, or
Be aggregated (AVG, COUNT, SUM, etc.)
s‌alary_year_avg exists at the job level.
One skill appears in many jobs.
So SQL sees:
Skill → multiple salary values
It cannot return multiple salaries per skill in one row.
Therefore you must collapse them into a single value → AVG(salary_year_avg).
Without AVG, SQL throws an error because the value is ambiguous.
ROUND() is optional. It just removes decimals for readability.

(ii) Why job_work_from_home = TRUE changes results
That filter narrows the dataset.
With it:
Only remote jobs are included.
Average salary reflects remote market only.
Without it:
All locations are included.
Average salary reflects overall market.
Different filters → different population → different averages.
Neither is wrong.
*/



/*
Answer: 5) What are the most optimal skills to learn (aka it’s in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles (already done in query 3)
- Concentrates on remote positions with specified salaries (already done in query 4)
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
    offering strategic insights for career development in data analysis
*/


WITH cte_1 AS
(

SELECT
skills_job_dim.skill_id,
skills_dim.skills AS skills,
COUNT(skills_dim.skills) AS skills_req
FROM
job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
job_title_short = 'Data Analyst'
AND
job_work_from_home IS TRUE
AND
salary_year_avg IS NOT NULL
GROUP BY
skills_job_dim.skill_id , skills
ORDER BY
skills_req DESC

) 


,  cte_2 AS 

(

SELECT
skills_dim.skill_id,
ROUND(avg(job_postings_fact.salary_year_avg),0) AS avg_sal
FROM
job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
job_title_short = 'Data Analyst'
AND
salary_year_avg IS NOT NULL
AND
job_work_from_home IS TRUE
GROUP BY
skills_dim.skill_id
ORDER BY
avg_sal DESC
 
)


SELECT 
cte_1.skill_id,
cte_1.skills,
cte_1.skills_req,
cte_2.avg_sal
FROM
cte_1 
INNER JOIN cte_2 ON cte_1.skill_id = cte_2.skill_id
WHERE
skills_req > 10
ORDER BY
 avg_sal DESC