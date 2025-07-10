#!/bin/bash

# setup-dev-env.sh
# Script to set up a secure development environment with uv

set -e  # Exit on any error

echo "🚀 Setting up secure Python development environment with uv..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    print_error "uv is not installed. Please install it first:"
    echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

print_status "uv version: $(uv --version)"

# Create virtual environment with uv
print_status "Creating virtual environment with uv..."
uv venv --python 3.11

# Activate virtual environment
print_status "Activating virtual environment..."
source .venv/bin/activate

# Install dependencies
print_status "Installing dependencies with uv..."
uv pip install -r requirements.txt
uv pip install -r requirements-dev.txt

# Install pre-commit hooks
print_status "Installing pre-commit hooks..."
uv run pre-commit install --install-hooks

# Create necessary directories
print_status "Creating project directories..."
mkdir -p src tests docs .github/workflows

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    print_status "Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# PyCharm
.idea/

# VS Code
.vscode/

# Security
.secrets.baseline
secrets.json
*.key
*.pem
*.crt
config.json
.env.*

# OS
.DS_Store
Thumbs.db

# Project specific
logs/
tmp/
temp/
*.tmp
*.bak
*.swp
*~
EOF
fi

# Create secrets baseline for detect-secrets
print_status "Creating secrets baseline..."
uv run detect-secrets scan --baseline .secrets.baseline

# Run initial security checks
print_status "Running initial security checks..."
uv run bandit -r . -f txt || print_warning "Bandit found potential security issues"
uv run safety check || print_warning "Safety found vulnerable dependencies"

# Run code quality checks
print_status "Running code quality checks..."
uv run black --check . || print_warning "Code needs formatting with black"
uv run isort --check-only . || print_warning "Imports need sorting with isort"
uv run ruff check . || print_warning "Ruff found code issues"

# Create sample test file
if [ ! -f tests/test_sample.py ]; then
    print_status "Creating sample test file..."
    mkdir -p tests
    cat > tests/test_sample.py << 'EOF'
"""Sample test file."""

import pytest


def test_sample():
    """Sample test function."""
