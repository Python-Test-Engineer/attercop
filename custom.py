import os
import re

# Folder to search
SRC_FOLDER = "src"


print(f"Scanning folder: {SRC_FOLDER}")
# Regex pattern to match secret_key and password assignments
PATTERN = re.compile(r'\b(secret_key|password)\b\s*=\s*["\'].*["\']', re.IGNORECASE)


def search_secrets_in_file(filepath):
    with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
        for i, line in enumerate(file, start=1):
            if PATTERN.search(line):
                print(f"{filepath}:{i}: {line.strip()}")


def scan_directory(directory):
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".py"):
                full_path = os.path.join(root, filename)
                search_secrets_in_file(full_path)


if __name__ == "__main__":
    scan_directory(SRC_FOLDER)
