-- Day 4: aggregation, finding and removing duplicates, subqueries and CTEs
-- Run: python python/run_sql.py sql/day_04_having.sql

DESCRIBE users;
DESCRIBE prompts;
DESCRIBE flags;

-- Problem 1: which users wrote more than 10 prompts?
-- recall how to count the number of prompts per user
-- step 1: count the number of prompts per user (used the same query as day 3)
SELECT user_id, COUNT(prompt_id) AS prompt_count
FROM prompts
WHERE user_id IS NOT NULL -- remove orphaned prompts
GROUP BY user_id
ORDER BY prompt_count DESC;

-- step 2: narrow the list to those who have more than 10 prompts
SELECT user_id, COUNT(prompt_id) AS prompt_count
FROM prompts
WHERE user_id IS NOT NULL
GROUP BY user_id
-- having is fixed. always comes after group by and before order by
HAVING COUNT(prompt_id) > 10
ORDER BY prompt_count DESC;
-- answer: 81 users have more than 10 prompts

-- Problem 2: which flag categories have an average severity above 2?
-- notes: will use flags table
-- show category and average severity (2 columns)
SELECT category, AVG(severity) AS avg_severity
FROM flags
-- remember: where clause cannot contain aggregates, so use having!!
GROUP BY category
HAVING AVG(severity) > 2
ORDER BY avg_severity DESC;
-- answer: harmful with avg of 2.02

-- check: what is the avg for all categories?
SELECT category, AVG(severity) AS avg_severity
FROM flags
-- remember: where clause cannot contain aggregates, so use having!!
GROUP BY category
-- HAVING AVG(severity) > 2
ORDER BY avg_severity DESC;
-- harmful: 2.02, spam: 1.97, pii: 1.92, off_topic: 1.89

-- Problem 3: find the duplicate flag_ids
-- the difference btwn these two numbers should match the extra rows found
SELECT COUNT(*), COUNT(DISTINCT flag_id)
FROM flags;

-- this is grouping the flag_ids and showing the count in each group
-- ideally, each id should have a count of 1
-- if there are duplicates, the group count will show a number higher than 1
SELECT flag_id, COUNT(*) 
FROM flags
GROUP BY flag_id
HAVING COUNT(*) > 1;
-- answer: there are 3 duplicate flag_ids

-- Problem 4: are they exact copies?
-- columns to check: prompt_id, category, severity, flagged_at
-- check for duplicates in the prompt_id column
SELECT prompt_id, COUNT(*)
FROM flags
GROUP BY prompt_id
HAVING COUNT(*) > 1;

-- check if the flag_id and prompt_id are from the same row
-- put every column in select and group by 
SELECT flag_id, prompt_id, category, severity, flagged_at, COUNT(*)
FROM flags
GROUP BY flag_id, prompt_id, category, severity, flagged_at
HAVING COUNT(*) > 1;
-- answer: yes, all 3 are exact copies (every column matches)
-- the duplicate rows planted on day 2

-- Problem 5: among pro users only, which countries have more than 15 users?
SELECT COUNT(user_id) AS pro_user_count, country
FROM users
WHERE plan = 'pro'
-- remember: whenever using group by, one row of the answer = one country, group by country.
-- user_id is diff for every user in country, so it can only appear inside COUNT()
GROUP BY country
-- remember: where filters rows before grouping (pro users only)
-- having filters groups after grouping (countries with more than 15)
HAVING COUNT(user_id) > 15;
-- answer: countries with more than 15 pro users are IN, UK, and PH

-- Problem 6: which prompt topics are more popular than the avg topic?
-- step 1: count the prompts per topic
SELECT COUNT(prompt_id) AS prompt_count, topic
FROM prompts
GROUP BY topic
ORDER BY prompt_count DESC;

-- step 2: find the avg of the per-topic counts
-- calculate the avg by referencing the query above
-- we only need one value as an output
SELECT AVG(prompt_count)
FROM (
    SELECT COUNT(prompt_id) AS prompt_count, topic
    FROM prompts
    GROUP BY topic
) AS prompt_avg;
-- answer: avg is 333.33

-- step 3: now that we have the avg value, we need to use having to filter the results
-- in the select, incl the columns to display
SELECT topic, COUNT(prompt_id) AS prompt_count
FROM prompts
GROUP BY topic
HAVING COUNT(prompt_id) > (
    SELECT AVG(prompt_count) -- write out the avg query
    FROM (
        SELECT COUNT(prompt_id) AS prompt_count, topic
        FROM prompts
        GROUP BY topic
    ) AS prompt_avg
) ORDER BY prompt_count DESC;
-- answer: shopping, news, relationships, and health are the above avg prompt topics

-- Problem 7: rewrite problem 6 as a CTE
-- CTE: one row per topic with its prompt count
-- CTE's are like table variables, they create a smaller table and you can reference
-- note that they only exist for the single statement its in. cannot reference later
WITH topic_count AS (
    -- add subquery
    -- using prompt_count since it is re-written a couple times in previous problem
    SELECT COUNT(prompt_id) AS prompt_count, topic
    FROM prompts
    GROUP BY topic
)

-- add the filter
-- remember: avg cannot be referenced in the where clause so it must be a nested query
SELECT *
FROM topic_count
WHERE prompt_count > (
    SELECT AVG(prompt_count) AS prompt_avg
    FROM topic_count
)
ORDER BY prompt_count;
-- answer: health, relationships, news, shopping

-- Problem 8: how many flags come from pro users?
-- list the user_ids of pro users (innermost layer)
-- step 1: find which table will show the pro users
SELECT user_id
FROM users
WHERE plan = 'pro';

-- step 2: query that lists the prompt_ids written by those users
-- we only want to display the prompt_id since the user_ids are already filtered
SELECT prompt_id
FROM prompts
WHERE user_id IN (
    SELECT user_id
    FROM users
    WHERE plan = 'pro'
);

-- step 3: create the outer query
SELECT COUNT(flag_id) AS flag_pro_users
FROM flags
WHERE prompt_id IN (
    SELECT prompt_id
    FROM prompts
    WHERE user_id IN (
        SELECT user_id
        FROM users
        WHERE plan = 'pro'
    )
);

-- Problem 9: rewrite "users with more prompts than the avg user" as CTE
-- two variables to find: the prompt count for each user and the avg prompt count across all users
-- CTE 1 will be the prompt count
-- statement will have the comparison
-- avg will be nested in the WHERE
WITH prompt_count AS (
    SELECT user_id, COUNT(prompt_id) AS user_prompt_count
    FROM prompts
    WHERE user_id IS NOT NULL
    GROUP BY user_id
)

SELECT * 
FROM prompt_count
WHERE user_prompt_count > (
    SELECT AVG(user_prompt_count)
    FROM prompt_count
)
ORDER BY user_prompt_count DESC;
