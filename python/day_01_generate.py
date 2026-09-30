# this is a simple script to generate some random data for our users.csv file
import csv
import random
from datetime import date, timedelta

# setting a seed isn't required, but it makes the "random" values
# the same every run, so the data is reproducible for anyone who runs it.
random.seed(42)  

# these are lists of the options we can choose from when generating 
# random data for the country and plan columns. this just defines the possible values
# but doesn't actually generate any data yet. the data will be generated in the next
# step.
COUNTRIES = ["US", "CA", "MX", "UK", "IN", "PH"]
PLANS = ["free", "pro"]


with open("data/users.csv", "w", newline="") as f:
    writer = csv.writer(f)
    # write the header row once. It's outside the for loop, so it doesn't repeat.
    writer.writerow(["user_id", "signup_date", "country", "plan"])
    
    # loop over user IDs 1-200 (range stops before 201). For each one,
    # pick a random 2025 signup date, country, and plan, then write the row.
    for user_id in range(1, 201):
        signup_date = date(2025, 1, 1) + timedelta(days=random.randint(0, 364))
        country = random.choice(COUNTRIES)
        plan = random.choice(PLANS)
        writer.writerow([user_id, signup_date, country, plan])


print("Wrote data/users.csv")