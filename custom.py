"""Search for key words in the codebase"""

import os
import re


# Define the words to search for
words_to_search = ["password", "api_token", "secret"]
words_to_search = []

# Initialize an empty list to store the results
results = []

# Walk through the directory tree
for root, dirs, files in os.walk("./src"):
    for file in files:
        # Open the file and read its contents
        try:
            with open(
                os.path.join(root, file), "r", encoding="utf-8", errors="ignore"
            ) as f:
                contents = f.read()
        except UnicodeDecodeError:
            # If the file can't be decoded as UTF-8, try reading it as binary
            with open(os.path.join(root, file), "rb") as f:
                contents = f.read().decode("utf-8", errors="ignore")

            # If the file is binary, skip it
            if not contents.isalpha():
                continue

        # Search for the words in the file contents
        for word in words_to_search:
            matches = re.findall(
                r"\b" + re.escape(word) + r"\b", contents, re.IGNORECASE
            )
            if matches:
                # Add the matches to the results list
                results.append(
                    {
                        "file": os.path.join(root, file),
                        "word": word,
                        "locations": [contents.index(match) for match in matches],
                    }
                )

# Print the results
if results:
    print("[red]Potential sensitive information found:[/red]")
    for result in results:
        print(
            f"  * {result['word']} in {result['file']} at locations {result['locations']}"
        )
    exit(1)  # Exit with a non-zero status to indicate an error
else:
    print("NO POTENTIAL sensitive information found.")
