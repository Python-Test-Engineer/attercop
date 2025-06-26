# Python Dependency Management with Ruff - Complete Setup Guide

## Project Structure Setup

Assuming your project structure looks like:
```
my-project/
├── src/
│   └── my_package/
│       ├── __init__.py
│       └── main.py
├── tests/
├── pyproject.toml
├── requirements.txt (or requirements-dev.txt)
└── README.md
```

## 1. Configure pyproject.toml

Create or update your `pyproject.toml` file:

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-package"
version = "0.1.0"
description = "Your package description"
authors = [{name = "Your Name", email = "your.email@example.com"}]
dependencies = [
    # Core dependencies
    "requests>=2.25.0",
    "click>=8.0.0",
]

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.setuptools.package-dir]
"" = "src"

# Ruff configuration
[tool.ruff]
target-version = "py38"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (handled by formatter)
]

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]  # Allow unused imports in __init__.py
"tests/**/*" = ["S101"]   # Allow assert in tests

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

# Import sorting
[tool.ruff.lint.isort]
known-first-party = ["my_package"]
force-single-line = false
```

## 2. Install Dependencies

### Option A: Using pip with pyproject.toml (Recommended)
```bash
# Install the package in development mode with dev dependencies
pip install -e ".[dev]"

# Or if you prefer to install dev dependencies separately
pip install -e .
pip install ruff pytest mypy pre-commit
```

### Option B: Using requirements files
Create `requirements-dev.txt`:
```
# Development dependencies
ruff>=0.1.0
pytest>=7.0.0
pytest-cov>=4.0.0
mypy>=1.0.0
pre-commit>=3.0.0

# Install main package in development mode
-e .
```

Then install:
```bash
pip install -r requirements-dev.txt
```

## 3. Configure Ruff for Dependency Checking

### Import Sorting and Unused Imports
Ruff automatically handles:
- Import sorting (replaces isort)
- Unused import detection
- Missing imports in `__init__.py`

### Check for dependency issues:
```bash
# Check for import/dependency issues
ruff check src/ tests/

# Fix auto-fixable issues
ruff check --fix src/ tests/

# Format code
ruff format src/ tests/
```

## 4. Additional Dependency Management Tools

### A. Use pip-tools for dependency pinning
```bash
pip install pip-tools

# Create requirements.in with your direct dependencies
echo "requests>=2.25.0" > requirements.in
echo "click>=8.0.0" >> requirements.in

# Generate pinned requirements.txt
pip-compile requirements.in

# For dev dependencies
echo "ruff" > requirements-dev.in
echo "pytest" >> requirements-dev.in
pip-compile requirements-dev.in
```

### B. Use pipdeptree to visualize dependencies
```bash
pip install pipdeptree
pipdeptree --packages my-package
```

## 5. Set Up Pre-commit Hooks

Create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

Install pre-commit:
```bash
pre-commit install
```

## 6. Makefile for Common Tasks

Create a `Makefile`:
```makefile
.PHONY: install check format test clean

install:
	pip install -e ".[dev]"

check:
	ruff check src/ tests/
	mypy src/

format:
	ruff format src/ tests/

lint-fix:
	ruff check --fix src/ tests/

test:
	pytest tests/ -v --cov=src/

clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov/
```

## 7. CI/CD Configuration

### GitHub Actions example (`.github/workflows/ci.yml`):
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v4
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -e ".[dev]"

    - name: Lint with Ruff
      run: |
        ruff check src/ tests/
        ruff format --check src/ tests/

    - name: Type check with mypy
      run: mypy src/

    - name: Test with pytest
      run: pytest tests/ -v --cov=src/
```

## 8. Daily Workflow Commands

```bash
# Before starting work
make install

# During development
make check          # Check for issues
make format         # Format code
make lint-fix       # Fix auto-fixable issues
make test          # Run tests

# Before committing
ruff check src/ tests/
ruff format src/ tests/
pytest tests/
```

## 9. Dependency Security and Updates

### Check for security vulnerabilities:
```bash
pip install safety
safety check

# Or use pip-audit
pip install pip-audit
pip-audit
```

### Update dependencies:
```bash
# If using pip-tools
pip-compile --upgrade requirements.in
pip-compile --upgrade requirements-dev.in

# Then sync
pip-sync requirements.txt requirements-dev.txt
```

## 10. Troubleshooting Common Issues

### Import path issues with src layout:
```bash
# Install package in development mode
pip install -e .

# Or add src to PYTHONPATH temporarily
export PYTHONPATH="${PYTHONPATH}:${PWD}/src"
```

### Ruff not finding imports:
- Ensure `src` is in `tool.ruff.src` in pyproject.toml
- Check that your package is properly installed with `pip install -e .`
- Verify `__init__.py` files exist in all package directories

This setup ensures robust dependency management with Ruff handling linting, formatting, and import organization while maintaining clean dependency declarations and proper project structure.
