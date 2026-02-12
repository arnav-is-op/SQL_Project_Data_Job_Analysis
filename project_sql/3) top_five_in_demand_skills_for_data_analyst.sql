/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
    providing insights into the most valuable skills for job seekers.
*/

-- practice probelm 7 also done in the same way but this right here is a different approach..





SELECT 
skills,
COUNT(skills_job_dim.job_id) AS in_demand_skills_count
FROM
job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE
job_title_short = 'Data Analyst' 
-- instead of data analyst we can searcg other stuff also
-- AND
-- job_work_from_home = TRUE
-- for remote job search use this
GROUP BY
skills
ORDER BY in_demand_skills_count DESC
-- same like the previous problem.. we need to join those two tables again
LIMIT 5
