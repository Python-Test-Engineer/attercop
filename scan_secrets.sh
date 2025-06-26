#!/usr/bin/env bash

# Exit on error
set -e

echo "🔍 Scanning for hardcoded secrets in Python files..."

# Find all .py files, skip virtualenvs and hidden directories
FILES=$(find . -type f -name "*.py" -not -path "*/\.*" -not -path "*/venv/*" -not -path "*/.venv/*")

# Regex patterns to detect secrets (add more as needed)
PATTERNS=(
  "password\s*=\s*['\"]([^'\"]+)['\"]"
  "secret(_key)?\s*=\s*['\"]([^'\"]+)['\"]"
  "api[_-]?key\s*=\s*['\"]([^'\"]+)['\"]"
  "token\s*=\s*['\"]([^'\"]+)['\"]"
)

FOUND=0

for file in $FILES; do
  for pattern in "${PATTERNS[@]}"; do
    if grep -nE "$pattern" "$file"; then
      FOUND=1
    fi
  done
done

if [ "$FOUND" -eq 1 ]; then
  echo "❌ Potential secrets found. Please remove or secure them before committing."
  exit 1
else
  echo "✅ No secrets found."
fi
