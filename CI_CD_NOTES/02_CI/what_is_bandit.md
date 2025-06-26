Bandit is a security-focused static analysis tool specifically designed for Python code. It's part of the PyCQA (Python Code Quality Authority) project and focuses on finding common security issues in Python applications.

## What Bandit Does

**Python Security Scanner**: It analyzes Python code for security vulnerabilities by looking for known insecure patterns and practices.

**Common Issues It Finds**:
- Hardcoded passwords/secrets in code
- SQL injection vulnerabilities
- Shell injection risks
- Use of insecure random number generators
- Unsafe YAML loading
- Insecure SSL/TLS configurations
- Use of `eval()` or `exec()`
- Weak cryptographic practices
- Path traversal vulnerabilities
- Insecure temporary file creation

## How It Works in Your CI

Looking at your workflow, the Bandit step:

1. **Scans the `attercop/` directory** recursively
2. **Generates reports** in both JSON and text formats
3. **Uses `continue-on-error: true`** so it doesn't fail the build
4. **Uploads artifacts** with the security reports

```bash
bandit -r attercop/ -f json -o bandit-report.json || true
bandit -r attercop/ -f txt
```

## Key Benefits

- **Python-specific** - understands Python security patterns
- **Fast scanning** - much faster than comprehensive tools like CodeQL
- **Easy to integrate** - simple CLI tool
- **Actionable results** - shows exact line numbers and explanations
- **Configurable** - can exclude certain tests or directories

## Bandit vs CodeQL

| Bandit | CodeQL |
|--------|--------|
| Python-only | Multi-language |
| Pattern-based | Semantic analysis |
| Fast | Slower but thorough |
| Simple setup | More complex |
| Free | Free for public repos |

## Example Issues Bandit Catches

```python
# Hardcoded password (B105)
password = "secret123"

# SQL injection risk (B608)
query = "SELECT * FROM users WHERE id = " + user_id

# Unsafe random (B311)
import random
token = random.random()

# Shell injection (B602)
os.system("rm " + filename)
```

## When to Use Bandit

- **All Python projects** - it's lightweight and catches common mistakes
- **Security-conscious development**
- **Before code reviews**
- **As part of security gates**

For your project, Bandit provides a quick security check that complements the deeper analysis from CodeQL, giving you multiple layers of security scanning.
