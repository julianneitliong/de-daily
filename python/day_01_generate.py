import csv
import random
from datetime import date, timedelta

random.seed(42)  # same "random" data every run, so results are reproducible

COUNTRIES = ["US", "CA", "MX", "UK", "IN", "PH"]
PLANS = ["free", "pro"]

with open("data/users.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["user_id", "signup_date", "country", "plan"])

    for user_id in range(1, 201):
        signup_date = date(2025, 1, 1) + timedelta(days=random.randint(0, 364))
        country = random.choice(COUNTRIES)
        plan = random.choice(PLANS)
        writer.writerow([user_id, signup_date, country, plan])

print("Wrote data/users.csv")