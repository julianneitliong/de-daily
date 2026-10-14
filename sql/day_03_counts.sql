-- Day 3: aggregation, HAVING and subqueries practice
-- Run: python python/run_sql.py sql/day_03_counts.sql

DESCRIBE users;
DESCRIBE prompts;
DESCRIBE flags;

-- Problem 1 How many users are on each plan?
SELECT COUNT(user_id) AS user_count, plan -- removed distinct since group by already gives one row per group
FROM users
GROUP BY plan;
-- there are 109 on free and 91 on pro

-- Problem 2 run three queries to count users with pro plan
-- what will happen if you filter using the following strings? write prediction
-- 'pro' - this will result in 91
-- 'Pro' - this will result in 0
-- "pro" -- this will result in error
SELECT COUNT(*) -- the question asks for a count, so it should be a single value and not multiple columns
FROM users
WHERE plan ='pro';

SELECT COUNT(*) 
FROM users
WHERE plan ='Pro'; -- won’t error, but returns 0 because comparisons are case-sensitive.

SELECT COUNT(*) 
FROM users
WHERE plan = "pro"; -- will result with an error because of the use of double quotes

-- Problem 3 how many users are not on the pro plan
SELECT COUNT(*) -- the result should be a count so there should only be one column to display
FROM users
WHERE plan <> 'pro';
-- answer: there are 109 free plan

-- Problem 4 users by country and plan revisit
SELECT country, plan, COUNT(user_id) AS user_count -- remember, no need for distinct when using group by
FROM users
WHERE country IS NOT NULL
GROUP BY country, plan -- make sure to add plan to group by. all non-aggregate columns should be listed
ORDER BY user_count DESC;
-- answer: 12 rows. max is 20 users in UK are free, min is 9 users in MX on pro

-- Problem 5 which signup months had more than 15 signups?
SELECT COUNT(user_id) AS user_count, DATE_TRUNC('month', signup_date) AS signup_month -- keeps the year and the month and sets the day to the 1st
FROM users
GROUP BY signup_month
HAVING COUNT(user_id) > 15 -- instead of WHERE use HAVING after group by since the group has already been created 
ORDER BY signup_month ASC;
-- answer: jan, feb, mar, apr, may, july, oct, dec

-- Problem 6 who wrote more prompts than the average user?
-- step 1: get the columns you need
SELECT u.user_id -- always double check separators
    ,p.prompt_id
    ,u.plan
    ,p.topic -- check table source to make sure columns exist
FROM prompts AS p
INNER JOIN users AS u ON p.user_id = u.user_id;
-- use inner join because we want to see all matches. no null values should show

-- step 2: get the count
-- count the number of prompts per user
SELECT user_id, COUNT(prompt_id) AS prompt_count
FROM prompts
WHERE user_id IS NOT NULL -- remove orphaned prompts
GROUP BY user_id
ORDER BY prompt_count DESC;

-- after finding the count, create a subquery to find the avg
SELECT AVG(prompt_count)
FROM (
    SELECT user_id, COUNT(prompt_id) AS prompt_count
    FROM prompts
    WHERE user_id IS NOT NULL -- remove orphaned prompts
    GROUP BY user_id
    --ORDER BY prompt_count DESC -- not needed in a subquery
) AS user_prompt_count;

-- keep the above average users
-- will use the first query to use the columns
SELECT user_id, COUNT(prompt_id) AS prompt_count
FROM prompts
WHERE user_id IS NOT NULL -- remove orphaned prompts
GROUP BY user_id
HAVING COUNT(prompt_id) > (
    SELECT AVG(prompt_count) -- display the avg and pull the info from the following table
    FROM (
        SELECT user_id, COUNT(prompt_id) AS prompt_count
        FROM prompts
        WHERE user_id IS NOT NULL -- remove orphaned prompts
        GROUP BY user_id
        --ORDER BY prompt_count DESC -- not needed inside a subquery, reference outside query
) AS user_prompt_count
)
ORDER BY prompt_count DESC;
-- result: avg is 9.815

-- check if the top user is a real user
-- choice to solve: query the user table
SELECT user_id, plan
FROM users
WHERE user_id = 36;
-- user 36 does exist in the user table, so it is a real user

-- Problem 7 how many prompts came from users who signed up in Q1 2025
    -- initial thoughts before writing query: will need to join users since it has signup_date and prompts for prompt_id
    -- the kind of join needed will be INNER JOIN. this is because we need to find
    -- all the users who created prompts and then pull out the months jan, feb, and march 
    -- and the year 2025 from the signup_date column
-- final result should be one value
SELECT COUNT(p.prompt_id) AS prompt_count
FROM users AS u
INNER JOIN prompts AS p
ON u.user_id = p.user_id
WHERE u.signup_date BETWEEN '2025-01-01' AND '2025-03-31';
-- result: 460

-- checking how many users signed up in Q1 2025
SELECT COUNT(user_id) AS user_count
FROM users
WHERE signup_date BETWEEN '2025-01-01' AND '2025-03-31';
-- result: 48 users. 460 / 48 ≈ 9.6 prompts per user, close to the overall average of 9.815, so 460 is plausible