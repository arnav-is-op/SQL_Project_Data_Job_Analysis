/*
Answer: What are the most optimal skills to learn (aka it’s in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles (already done in query 3)
- Concentrates on remote positions with specified salaries (already done in query 4)
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
    offering strategic insights for career development in data analysis
*/

-- Identifies skills in high demand for Data Analyst roles
-- make a cte for Query 3 and 4 and combine them

--1st cte


WITH skills_demand AS (

    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS in_demand_skills_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND job_work_from_home = TRUE
        AND salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id, skills_dim.skills

),

avg_salary AS (

    SELECT 
        skills_dim.skill_id,
        ROUND(AVG(salary_year_avg),0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = TRUE
    GROUP BY skills_dim.skill_id
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    skills_demand.in_demand_skills_count,
    avg_salary.avg_salary
FROM skills_demand
INNER JOIN avg_salary 
    ON skills_demand.skill_id = avg_salary.skill_id
WHERE
in_demand_skills_count > 10
ORDER BY 
avg_salary DESC,
in_demand_skills_count DESC
LIMIT
30;



-- rewriting this same query more concisely
SELECT
skills_dim.skill_id,
skills_dim.skills,
COUNT(skills_job_dim.job_id) AS demand_count,
ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL
AND job_work_from_home = True
 GROUP BY
skills_dim.skill_id
 HAVING
COUNT(skills_job_dim.job_id) > 10
ORDER BY
avg_salary DESC,
demand_count DESC
LIMIT 25;


