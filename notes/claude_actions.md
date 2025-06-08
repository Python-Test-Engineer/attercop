Test Job:

Runs tests across multiple Python versions (3.9-3.12)
Installs uv using the official astral-sh/setup-uv action
Creates a virtual environment and installs dependencies
Runs pytest with coverage reporting
Uploads coverage reports to Codecov

Security Job:

Multiple vulnerability scanning tools:

Bandit: Scans for common security issues in Python code
Safety: Checks for known security vulnerabilities in dependencies
pip-audit: Audits Python packages for known vulnerabilities


Uploads security reports as artifacts for review

CodeQL Analysis:

GitHub's semantic code analysis engine
Scans for security vulnerabilities and coding errors
Results appear in the Security tab of your repository

Lint Job:

Code formatting checks with Black
Import sorting verification with isort
Code linting with flake8
Type checking with mypy

Key Features:

Triggers on pushes to main/develop branches and pull requests
Uses the latest uv version for fast dependency management
Continues on security tool errors to avoid blocking the pipeline
Uploads artifacts for security reports
Proper virtual environment handling

To use this workflow:

Save it as .github/workflows/ci.yml in your repository
Ensure your project has a pyproject.toml or setup.py file for uv to install
Adjust the package name from attercop if needed in the coverage and scanning paths

The workflow will run automatically on pushes and pull requests, providing comprehensive testing and security analysis for your Python project.RetryClaude can make mistakes. Please double-check responses. Sonnet 4
