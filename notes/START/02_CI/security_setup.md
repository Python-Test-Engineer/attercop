# Repository Security Setup Guide

## GitHub Repository Security Settings

### 1. Branch Protection Rules
Navigate to **Settings → Branches** and configure:

**For `main` branch:**
- ✅ Require a pull request before merging
- ✅ Require approvals (minimum 1-2 reviewers)
- ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ Require review from code owners
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Require signed commits
- ✅ Require linear history
- ✅ Include administrators in restrictions

**Required status checks:**
- `code-analysis`
- `dependency-check`
- `test (3.11)` (or your primary Python version)
- `docker-build-scan`

### 2. Security & Analysis Settings
Navigate to **Settings → Security & analysis**:

- ✅ Enable Dependency graph
- ✅ Enable Dependabot alerts
- ✅ Enable Dependabot security updates
- ✅ Enable CodeQL analysis
- ✅ Enable Secret scanning
- ✅ Enable Push protection for secret scanning

### 3. Actions Permissions
Navigate to **Settings → Actions → General**:

- ✅ Allow enterprise, and select non-enterprise, actions and reusable workflows
- ✅ Allow actions created by GitHub
- ✅ Allow specified actions and reusable workflows
- ✅ Require approval for first-time contributors
- ✅ Require approval for all outside collaborators

### 4. Environments Setup
Navigate to **Settings → Environments**:

**Create `production` environment:**
- ✅ Required reviewers (add team members)
- ✅ Wait timer: 0 minutes
- ✅ Restrict pushes to protected branches
- ✅ Environment secrets:
  - `DOCKER_REGISTRY_USERNAME`
  - `DOCKER_REGISTRY_PASSWORD`
  - `KUBECONFIG` (if using Kubernetes)
  - `SLACK_WEBHOOK` (for notifications)

## Required Secrets Configuration

### Repository Secrets
Navigate to **Settings → Secrets and variables → Actions**:

**Required secrets:**
- `SEMGREP_APP_TOKEN` - Get from [Semgrep](https://semgrep.dev)
- `SNYK_TOKEN` - Get from [Snyk](https://snyk.io)
- `CODECOV_TOKEN` - Get from [Codecov](https://codecov.io)
- `SLACK_WEBHOOK` - For CI/CD notifications
- `DOCKER_REGISTRY_PASSWORD` - For container registry access

### Environment Variables
- `DOCKER_REGISTRY` - Your container registry URL
- `IMAGE_NAME` - Your Docker image name
- `PYTHON_VERSION` - Default Python version

## Dockerfile Security Best Practices

```dockerfile
# Use specific, non-root base image
FROM python:3.11-slim-bullseye AS base

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install security updates
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (non-privileged)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["python", "app.py"]
```

## Additional Security Tools Integration

### 1. SAST Tools
- **Semgrep**: Detects security vulnerabilities, bugs, and code quality issues
- **CodeQL**: GitHub's semantic code analysis
- **Bandit**: Python-specific security linter

### 2. Dependency Security
- **Safety**: Checks Python dependencies for known vulnerabilities
- **pip-audit**: Audits Python packages for known vulnerabilities
- **Dependabot**: Automated dependency updates

### 3. Container Security
- **Trivy**: Comprehensive vulnerability scanner for containers
- **Snyk**: Container and dependency vulnerability scanning
- **Checkov**: Infrastructure as Code security scanning

### 4. Secrets Management
- **GitHub Secret Scanning**: Detects secrets in code
- **TruffleHog**: Additional secret detection
- **GitLeaks**: Git repository secret scanner

## CI/CD Security Best Practices

### 1. Workflow Security
- Use pinned action versions (e.g., `actions/checkout@v4`)
- Limit workflow permissions using `permissions` key
- Use environment protection rules for sensitive deployments
- Implement approval workflows for production deployments

### 2. Container Security
- Use multi-stage builds to reduce attack surface
- Run containers as non-root users
- Scan images for vulnerabilities before deployment
- Use distroless or minimal base images when possible

### 3. Deployment Security
- Use encrypted secrets for sensitive data
- Implement proper RBAC for deployment targets
- Use service accounts with minimal permissions
- Enable audit logging for deployments

## Monitoring and Alerting

### 1. Security Monitoring
- Set up alerts for failed security scans
- Monitor for new vulnerabilities in dependencies
- Track security metrics and trends
- Implement incident response procedures

### 2. Notification Channels
- Slack integration for CI/CD status
- Email alerts for security findings
- Dashboard for security metrics
- Regular security reports

## Pre-commit Hooks Setup

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run on all files (optional)
pre-commit run --all-files
```

## Development Workflow

1. **Create feature branch** from `main`
2. **Write code** following security best practices
3. **Run pre-commit hooks** automatically
4. **Create pull request** with security checks
5. **Code review** by team members
6. **Merge after** all checks pass
7. **Automated deployment** to staging/production

## Incident Response

1. **Immediate Response**
   - Disable affected systems if critical
   - Assess impact and scope
   - Notify stakeholders

2. **Investigation**
   - Analyze security findings
   - Identify root cause
   - Document findings

3. **Remediation**
   - Apply security patches
   - Update dependencies
   - Implement additional controls

4. **Prevention**
   - Update security policies
   - Enhance monitoring
   - Conduct security training

## Regular Security Tasks

### Weekly
- Review Dependabot alerts
- Check security scan results
- Update dependencies

### Monthly
- Security scan results review
- Access permission audit
- Security metrics analysis

### Quarterly
- Comprehensive security audit
- Penetration testing
- Security training updates
