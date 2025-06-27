"""Search for key words in the codebase and ERROR if found."""

import os
import re

START_FOLDER = "./src"  # Change this to your desired start folder
# Define the words to search for

words_to_search = [
    "access_key",
    "access_token",
    "api_key",
    "apikey",
    "auth_token",
    "aws_access_key_id",
    "aws_secret_access_key",
    "azure_client_secret",
    "bearer_token",
    "cert",
    "certificate",
    "client_id",
    "client_secret",
    "connection_string",
    "database_url",
    "db_password",
    "db_user",
    "dsn",
    "firebase_api_key",
    "gcp_credentials",
    "keystore",
    "mongo_uri",
    "passwd",
    "password",
    "pem",
    "pfx",
    "private_key",
    "public_key",
    "refresh_token",
    "secret",
    "secret_key",
    "secret_api",
    "settings",
    "sha_key",
    "slack_token",
    "sqlalchemy_database_uri",
    "ssh_key",
    "token",
    "truststore",
    "twilio_sid",
    "twilio_token",
]

words_to_search = []

file_types = [".py", ".js"]  # Add or remove file types as needed
words_to_search = []

# Initialize an empty list to store the results
results = []

# Walk through the directory tree
for root, dirs, files in os.walk(START_FOLDER):
    for file in files:
        # Check if the file has one of the specified extensions
        # If not, skip to the next file
        if not any(file.endswith(ext) for ext in file_types):
            continue
        try:
            # Open the file and read its contents
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
    exit(
        1
    )  # Exit with a non-zero status to indicate an error and trigger pre-commit failure
else:
    print("NO POTENTIAL sensitive information found.")
