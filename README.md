# de-daily
30 days of SQL and Python on an AI moderation dataset
## Daily Log
- Day 1: generated users.csv (200 rows) with Python's csv and random modules. Learned: random.seed makes "random" data reproducible.
- Day 2: generated prompts.csv (2,000 rows) and flags.csv (313 rows). Planted issues: ~2% blank user_id in prompts, ~2% flags dated in the future (2027), ~2% duplicate flag rows.