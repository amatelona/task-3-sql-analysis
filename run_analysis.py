
from pathlib import Path
import sqlite3

folder = Path(__file__).resolve().parent
sql_file = folder / "task3_sql_analysis.sql"
db_file = folder / "ecommerce_analysis.db"

# Read SQL commands from the file
script = sql_file.read_text(encoding="utf-8")

# Start with a fresh database each time
if db_file.exists():
    db_file.unlink()

with sqlite3.connect(db_file) as connection:
    connection.execute("PRAGMA foreign_keys = ON")

    # Split script into complete SQL statements
    statements = []
    buffer = ""

    for line in script.splitlines():
        line = line.strip()

        if not line or line.startswith("--"):
            continue

        buffer += line + "\n"

        if sqlite3.complete_statement(buffer):
            statements.append(buffer.strip())
            buffer = ""

    cursor = connection.cursor()
    query_number = 0

    for statement in statements:
        first_word = statement.lstrip().upper()

        if first_word.startswith("SELECT") or first_word.startswith("EXPLAIN"):
            cursor.execute(statement)
            rows = cursor.fetchall()
            columns = [column[0] for column in cursor.description]

            query_number += 1
            print("\n" + "=" * 65)
            print(f"QUERY OUTPUT {query_number}")
            print("=" * 65)
            print(" | ".join(columns))
            print("-" * 65)

            for row in rows:
                print(" | ".join(str(value) for value in row))

            print(f"Rows returned: {len(rows)}")
        else:
            cursor.execute(statement)

    connection.commit()

print("\nSUCCESS! All SQL queries executed.")
print("Database saved as ecommerce_analysis.db")
