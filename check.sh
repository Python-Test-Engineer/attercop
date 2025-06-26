#!/bin/bash

# 1. Lock dependencies
pip-compile requirements.in

# 2. Scan for vulnerabilities
safety check -r requirements.txt
pip-audit -r requirements.txt

# 3. Run security-focused linting
ruff check --select S .  # Security rules only
bandit -r src/

# 4. Format and lint all code
ruff format .
ruff check .
