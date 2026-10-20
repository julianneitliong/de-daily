# de-daily
30 days of SQL and Python on an AI moderation dataset
## Daily Log
- Day 1: generated users.csv (200 rows) with Python's csv and random modules. Learned: random.seed makes "random" data reproducible.
- Day 2: generated prompts.csv (2,000 rows) and flags.csv (313 rows). Planted issues: ~2% blank user_id in prompts, ~2% flags dated in the future (2027), ~2% duplicate flag rows.
- Day 3: first SQL day. Wrote run_sql.py to run a .sql file against the CSVs, then practiced GROUP BY, HAVING, subqueries and a join in sql/day_03_counts.sql. Learned: decide the answer's shape first. One number means no GROUP BY.
- Day 4: practiced HAVING, finding duplicate rows, scalar subqueries, CTEs, and nested IN subqueries in sql/day_04_having.sql. Learned: AVG can't go in WHERE, so calculate it separately and compare.