Ruff itself is primarily a Python linter and formatter, not a dependency management tool. However, you can use Ruff alongside proper dependency management practices to maintain secure Python projects. Here's how to approach secure dependency management with Ruff in the mix:

## Using Ruff for Security-Related Code Quality

Ruff can help with security through its linting rules:

```bash
# Install ruff
pip install ruff

# Configure ruff with security-focused rules
```

Create a `pyproject.toml` or `ruff.toml` with security-relevant rules:

```toml
[tool.ruff]
select = [
    "S",    # flake8-bandit (security)
    "B",    # flake8-bugbear
    "E",    # pycodestyle errors
    "F",    # pyflakes
    "UP",   # pyupgrade
]

[tool.ruff.per-file-ignores]
# Allow assert statements in tests
"tests/*" = ["S101"]
```

## Actual Dependency Management for Security

For secure dependency management, combine these tools with Ruff:

### 1. Use pip-tools with Ruff
```bash
# Install pip-tools
pip install pip-tools

# Create requirements.in with your dependencies
echo "requests>=2.28.0" > requirements.in

# Generate locked requirements
pip-compile requirements.in

# Install dependencies
pip-sync requirements.txt

# Run ruff on your code
ruff check .
ruff format .
```

### 2. Use Poetry with Ruff
```bash
# Initialize project
poetry init
poetry add requests
poetry add --group dev ruff

# Install dependencies
poetry install

# Run ruff
poetry run ruff check .
```

### 3. Security Scanning Alongside Ruff
```bash
# Install security tools
pip install safety bandit pip-audit

# Check for known vulnerabilities
safety check
pip-audit
bandit -r .

# Run ruff for code quality
ruff check .
```

## Complete Secure Workflow

Here's a comprehensive approach:

```bash
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
```

## Pre-commit Integration

Set up pre-commit hooks in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]

  - repo: https://github.com/gitguardian/ggshield
    rev: v1.25.0
    hooks:
      - id: ggshield
        language: python
        stages: [commit]
```

The key is that Ruff handles code quality and some security linting, while dedicated tools like `pip-audit`, `safety`, or `bandit` handle dependency vulnerability scanning. Use them together for a comprehensive secure development workflow.
