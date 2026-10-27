-- Day 5 (part 1): joins and set operations
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

