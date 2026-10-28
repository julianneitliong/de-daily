-- Day 5: assessment review set (part 1: joins and set operations, part 2: data quality)
-- run: python python/run_sql.py sql/day_05_assessment_review.sql
DESCRIBE users;
DESCRIBE prompts;
DESCRIBE flags;
-- A: joining multiple datasets
-- A1: how many flags does each country have?
-- flags lives in flags table, country lives in users table, prompt table is the connection
-- one row = one country
SELECT u.country, COUNT(f.flag_id) AS num_flagged
FROM users AS u
INNER JOIN prompts AS p
ON u.user_id = p.user_id
INNER JOIN flags AS f
ON p.prompt_id = f.prompt_id
    GROUP BY country
ORDER BY num_flagged DESC;
-- answer: 305, not 313: 8 flags are on prompts with no user_id, so the INNER JOIN to users drops them

-- A2: rewrite A1 so both joins use USING(...) instead of ON
SELECT u.country, COUNT(f.flag_id) AS num_flagged
FROM users AS u
INNER JOIN prompts AS p
USING (user_id) -- no need for table name, use ()
INNER JOIN flags AS f
USING (prompt_id)
    GROUP BY country
ORDER BY num_flagged DESC;
-- answer: same rows as A1

-- A3: how many prompts were never flagged? (anti-join)
-- question is asking to show one value (the total number)
-- only use 2 tables (prompt and flags), user table is not needed
SELECT COUNT(prompt_id) AS num_not_flagged
FROM prompts AS p -- use prompt table first since question is asking 'how many prompts'
LEFT JOIN flags AS f
USING (prompt_id) -- table shares prompt_id
WHERE flag_id IS NULL;
-- answer: 1690

-- A4: answer A3 again using EXCEPT
-- EXCEPT works like NOT IN: list A is every prompt_id in prompts,
-- list B is every prompt_id in flags. EXCEPT keeps the prompt_ids
-- from A that aren't in B (prompts never flagged), then COUNT them
SELECT COUNT(*) AS num_not_flagged
FROM (
    SELECT prompt_id FROM prompts
    EXCEPT 
    SELECT prompt_id FROM flags
) AS unflagged_prompts;
-- answer: 1690, matches A3

-- A5: make one list of user_ids that are pro users or wrote at least one 'coding' prompt
-- count it twice. once with union and once with union all
SELECT COUNT(*) AS num_users
FROM (
    SELECT user_id FROM users WHERE plan = 'pro'   -- list 1
    UNION
    SELECT DISTINCT user_id FROM prompts WHERE topic = 'coding'
    AND user_id IS NOT NULL  -- list 2
) AS users_pro_coding;
-- answer: 179 = 91 pro users + 88 free users who wrote a coding prompt

-- try again with union all
SELECT COUNT(*) AS num_users
FROM (
    SELECT user_id FROM users WHERE plan = 'pro'   -- list 1
    UNION ALL
    SELECT user_id FROM prompts WHERE topic = 'coding'   -- list 2
) AS users_pro_coding;
-- answer: 420 counts coding prompts, not users: users with several coding prompts repeat

-- try again with union all and null filter and distinct
SELECT COUNT(*) AS num_users
FROM (
    SELECT user_id FROM users WHERE plan = 'pro'   -- list 1
    UNION ALL
    SELECT DISTINCT user_id FROM prompts WHERE topic = 'coding'   -- list 2
) AS users_pro_coding
WHERE user_id IS NOT NULL;
-- answer: 256 = 91 pro users + 165 distinct coding users. 256 - 179 = 77 users on both lists (see A6)

-- A6: how many users are pro and wrote at least one 'coding' prompt?
-- use intersect (this behaves like 'and')
SELECT COUNT(*) AS num_users
FROM (
    SELECT user_id FROM users WHERE plan = 'pro'   -- list 1
    INTERSECT 
    SELECT DISTINCT user_id FROM prompts WHERE topic = 'coding'   -- list 2
) AS users_pro_coding
WHERE user_id IS NOT NULL;
-- answer: 77, matches union all - union

-- A7: join users to prompts then count u.user_id two ways: COUNT(u.user_id) and COUNT(DISTINCT u.user_id)
SELECT COUNT(u.user_id) AS joined_rows
FROM users AS u 
JOIN prompts AS p
ON u.user_id = p.user_id;
-- output: 1963

SELECT COUNT(DISTINCT u.user_id) AS distinct_users
FROM users AS u 
JOIN prompts AS p
ON u.user_id = p.user_id;
-- output: 200
-- 200 = how many users (each counted once). 
-- 1963 = how many rows the join made (one per prompt with a user)

-- B: quality and validation
-- B1: how many prompts have a missing user_id?
SELECT COUNT(*) AS missing_users
FROM prompts
WHERE user_id IS NULL;
-- answer: 37

SELECT COUNT(*) - COUNT(user_id) AS missing_users
FROM prompts;
-- answer: 37
-- note: you can use math operators in select statements

-- B2: how many flags are dated in the future?
SELECT COUNT(flagged_at) AS future_dated
FROM flags
WHERE flagged_at > CURRENT_DATE;
-- answer: 9 (current date is 10-27-2026)

-- B3: were any flags created before the prompt they flag?
-- prompts holds the created_at timestamp
-- flags holds the flagged_at timestamp
SELECT f.flag_id, f.flagged_at, p.created_at
FROM flags AS f
JOIN prompts AS p USING (prompt_id)
WHERE f.flagged_at < p.created_at;
-- answer: 0 rows, check passes: every flag is dated after its prompt

-- B4: write one query for each, returning a count of bad rows
-- 1. flag whose severity is not 1, 2, or 3
-- severity is in flags table
SELECT COUNT(flag_id) AS bad_severity
FROM flags
WHERE severity NOT IN (1,2,3) OR severity IS NULL;
-- answer: 0, check passes

-- 2. users whose country code isn't exactly 2 characters length
SELECT COUNT(*) AS bad_countries
FROM users
WHERE LENGTH(country) <> 2;
-- answer: 0, check passes

-- 3. users whose plan is something other than 'free' or 'pro'
SELECT COUNT(*) AS bad_plans
FROM users
WHERE plan NOT IN ('free','pro');
-- answer: 0, check passes

-- B5: in one query, show: total rows, distinct flag_ids, and the number of extra rows
SELECT COUNT(*) AS total_rows,
COUNT(DISTINCT flag_id) AS distinct_flag_ids,
COUNT(flag_id) - COUNT(DISTINCT flag_id) AS extra_rows
FROM flags;
-- answer: total_rows 313, distinct: 310, extra: 3

-- B6. count the users who never wrote a prompt, using WHERE user_id NOT IN
-- one number = count(*)
-- v1
SELECT COUNT(*) AS users_wo_prompts
FROM users
WHERE user_id NOT IN (
    SELECT user_id
    FROM prompts
);
-- output is 0, only because the nulls in the list make every NOT IN check unknown.
-- it would be 0 even if some users had no prompts

-- v2
-- remove null values in subquery
SELECT COUNT(*) AS users_wo_prompts
FROM users
WHERE user_id NOT IN (
    SELECT user_id
    FROM prompts
    WHERE user_id IS NOT NULL
);
-- output is 0: every user wrote at least one prompt (matches A7's 200 users)
-- v2 is the only one to trust since it removes the null values
-- never use not in on a column that can be null without filtering the nulls out inside
-- the subquery first
