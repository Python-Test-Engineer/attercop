import os
import re

# Folder to search
START_FOLDER = "./src"

# Keywords to search for in variable names (wild match, case-insensitive)
KEYWORDS = ["secret", "password", "api"]

# Compile regex to match variable assignments like secret_key = "..."
PATTERN = re.compile(
    r"\b\w*(?:" + "|".join(KEYWORDS) + r')\w*\b\s*=\s*["\'].*?["\']', re.IGNORECASE
)

# Collect all results in a list
results = []


def search_sensitive_info(filepath):
    with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
        for i, line in enumerate(file, start=1):
            if PATTERN.search(line):
                results.append((filepath, i, line.strip()))


def scan_directory(directory):
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".py"):
                full_path = os.path.join(root, filename)
                search_sensitive_info(full_path)


def print_results():
    if results:
        print("\nSensitive-like assignments found:\n")
        for filepath, lineno, line in results:
            print(f"{filepath}:{lineno}: {line}")
    else:
        print("No sensitive-like assignments found.")


if __name__ == "__main__":
    scan_directory(START_FOLDER)
    print_results()
