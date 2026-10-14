# Runs every query in a .sql file against the CSVs in data/ and prints each result.
import sys
import duckdb

con = duckdb.connect()
for table in ["users", "prompts", "flags"]:
    con.sql(f"CREATE VIEW {table} AS SELECT * FROM 'data/{table}.csv'")

sql = open(sys.argv[1]).read()
for statement in sql.split(";"):
    code = [line for line in statement.splitlines() if line.strip() and not line.strip().startswith("--")]
    if not code:
        continue
    print("\n".join(code))
    try:
        print(con.sql(statement))
    except duckdb.Error as e:
        print("ERROR:", e, "\n")