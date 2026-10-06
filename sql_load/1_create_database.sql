SELECT '2023-02-19' :: DATE,
    '123' :: INTEGER,
    'true' :: BOOLEAN,
    '3.14' :: REAL;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date :: DATE AS DATE
FROM 
    job_postings_fact
LIMIT 5;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM 
    job_postings_fact
LIMIT 5; 

CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


SELECT job_posted_date
FROM march_jobs;

-- CASE STATEMENT
SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York,NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact 
WHERE 
        job_title_short = 'Data Analyst'
GROUP BY
    location_category;

-- Subqueries and CETS

SELECT *
FROM ( --CTE defination statrts here
        SELECT*
        FROM job_postings_fact
        WHERE EXTRACT(MONTH FROM job_posted_date) =1
) -- CTE job description ends here 

SELECT *FROM  january_jobs;

SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT 
        company_id
    FROM 
            job_postings_fact
    WHERE 
            job_no_degree_mention = true
    ORDER BY
        company_id
);

/*
FIND THE COMPANY WITH MOST JOB OPENINGS.
-Get the total number of job postings per company id(job_posting_fact)
-Return the total number of jobs with the company name (company_dim)
*/

WITH company_job_count AS(
    SELECT
        company_id,
        COUNT(*) AS total_jobs 
FROM 
        job_postings_fact
GROUP BY 
        company_id
)

SELECT
        company_dim.name AS company_name,
        company_job_count.total_jobs
FROM
        company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs;

/*
Find the count of the number of remote job postings per skills_dim
   -Display the top 5 skills by their demand in remote jobs
   -Include skill   ID, name, and count of postings requiring the skill
*/


WITH remote_job_skills AS(
SELECT 
    skill_id,
    count(*) AS skill_count
FROM 
    skills_job_dim AS skills_to_job
INNER JOIN
    job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE 
        job_postings.job_work_from_home = true
    AND job_postings.job_title_short = 'Data Analyst'
GROUP BY 
        skill_id
)
SELECT 
    skills.skill_id,
    skills AS silk_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
        skill_count  DESC
LIMIT 5;

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs

UNION ALL   -- Get jobs and companies from february
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs

UNION ALL-- Get jobs and companies from March
SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    march_jobs

/*
Find job postings from the first quarter that have a salary greater than $70,000.
- Combine job posting tables from the first quarter of 2023 (Jan–Mar).
- Get job postings with an average yearly salary > $70,000.
*/


SELECT
     quarter1_job_postings.job_title_short,
     quarter1_job_postings.job_location,
     quarter1_job_postings.job_via,
     quarter1_job_postings.job_posted_date::DATE,
     quarter1_job_postings.salary_year_avg
 FROM ( 
SELECT *
FROM january_jobs
UNION ALL
SELECT* 
FROM february_jobs
UNION ALL
SELECT*
FROM march_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 7000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst' ;
