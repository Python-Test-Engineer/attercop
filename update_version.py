import os
import re

# Get values from environment
version = os.environ["NEXT_VERSION"]
build_number = os.environ["BUILD_NUMBER"]
commit_sha = os.environ["COMMIT_SHA"]

print(f"Updating to version: {version}")

# Update pyproject.toml
with open("pyproject.toml", "r") as f:
    content = f.read()
content = re.sub(r'version = "[^"]*"', f'version = "{version}"', content)
with open("pyproject.toml", "w") as f:
    f.write(content)

# Update __init__.py
with open("src/calculator/__init__.py", "r") as f:
    content = f.read()
content = re.sub(r'__version__ = "[^"]*"', f'__version__ = "{version}"', content)
with open("src/calculator/__init__.py", "w") as f:
    f.write(content)

print("Version files updated successfully!")
