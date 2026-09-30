import csv
import random
from datetime import datetime, timedelta

random.seed(42)  # reproducible data, same as Day 1

TOPICS = ["homework", "coding", "health", "relationships", "news", "shopping"]
CATEGORIES = ["spam", "pii", "harmful", "off_topic"]
START = datetime(2025, 1, 1)
MINUTES_IN_2025 = 365 * 24 * 60

prompts = []  # remember each prompt so we can flag some of them

# --- prompts.csv ---
with open("data/prompts.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["prompt_id", "user_id", "created_at", "topic"])
    # TODO 1: write the header row: prompt_id, user_id, created_at, topic

    for prompt_id in range(1, 2001):
        user_id = random.randint(1, 200)  # links to a user from users.csv
        created_at = START + timedelta(minutes=random.randint(0, MINUTES_IN_2025 - 1))
        topic = random.choice(TOPICS)

        # PLANTED ISSUE 1: about 2% of prompts have a blank user_id
        if random.random() < 0.02:
            user_id = ""

        writer.writerow([prompt_id, user_id, created_at, topic])
        prompts.append((prompt_id, created_at))

# --- flags.csv ---
with open("data/flags.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["flag_id", "prompt_id", "category", "severity", "flagged_at"])
    # TODO 2: write the header row: flag_id, prompt_id, category, severity, flagged_at

    flag_id = 0
    for prompt_id, created_at in prompts:
        if random.random() < 0.15:  # about 15% of prompts get flagged
            flag_id += 1  # next flag number
            flagged_at = created_at + timedelta(minutes=random.randint(1, 48 * 60))

            # PLANTED ISSUE 2: about 2% of flags have a date in the future
            if random.random() < 0.02:
                flagged_at = datetime(2027, 1, 1) + timedelta(days=random.randint(0, 100))

            row = [flag_id, prompt_id, random.choice(CATEGORIES), random.randint(1, 3), flagged_at]
            writer.writerow(row)

            # PLANTED ISSUE 3: about 2% of flags are written twice (duplicates)
            if random.random() < 0.02:
                writer.writerow(row)

print("Wrote data/prompts.csv and data/flags.csv")