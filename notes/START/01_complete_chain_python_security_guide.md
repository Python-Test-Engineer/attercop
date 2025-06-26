# Python Code Quality & Security Implementation Guide

## Overview
This document provides a comprehensive plan for implementing code quality, typing, and security checks for Python projects using GitHub Actions, from local development through CI/CD deployment.

## Local Development (Pre-commit)

### Pre-commit Hook Configuration
- Set up pre-commit hooks with black for code formatting
- Configure isort for import sorting
- Add flake8 for linting and style checking
- Include mypy for static type checking
- Configure bandit for security vulnerability scanning
- Add detect-secrets for credential detection
- Run pytest with coverage reporting

### Conventional Commit Messages

This provides structure around what has been committed and can be used for versioning.

### Development Environment Setup
```yaml
# .pre-commit-config.yaml example structure
repos:
  - repo: https://github.com/psf/black
  - repo: https://github.com/pycqa/isort
  - repo: https://github.com/pycqa/flake8
  - repo: https://github.com/pre-commit/mirrors-mypy
  - repo: https://github.com/PyCQA/bandit
  - repo: https://github.com/Yelp/detect-secrets
```

### Dependency Management

UV best with its --check and lock

### Python versions

If we do not have a testing suite, tox, nox, for python versions, developers can UV with different Python versions to do their regular testing.

When it comes to GHA, we can do a matrix of Python versions.

### Detect Secrets

This needs a baseline file and may be cumbersome for devs. There are homemade versions that `grep` for common items and this may be sufficient. (`01_PRECOM MIT/secret_detection_hook.sh`)

## Pre-push Validation

### Comprehensive Testing
- Execute full test suite with tox across multiple Python versions
- Run comprehensive mypy type checking with strict configuration
- Perform security audit with safety (dependency vulnerabilities) and bandit
- Validate code formatting and import sorting compliance
- Ensure all tests pass before allowing push to remote repository

## CI/CD Pipeline (GitHub Actions)

### Workflow Triggers
- Trigger automated checks on pull requests to main/develop branches
- Execute pipeline on pushes to main branch
- Schedule periodic security scans for dependency updates

### Build Matrix Strategy
- Set up matrix testing across Python versions (3.8, 3.9, 3.10, 3.11, 3.12)
- Test across different operating systems (Ubuntu, Windows, macOS)
- Install dependencies with caching for faster build times

### Code Quality Checks
- Run linting suite including flake8, pylint, and black --check
- Execute type checking with mypy in strict mode
- Validate import sorting with isort --check-only
- Check code complexity and maintainability metrics

### Security Scanning
- Perform security scans with bandit for common security issues
- Run safety checks for known vulnerabilities in dependencies
- Execute semgrep for additional security pattern detection
- Scan for secrets and credentials in commit history and codebase
- Check for dependency vulnerabilities with GitHub's dependency review

### Testing & Coverage
- Run comprehensive test suite with pytest
- Generate code coverage reports with coverage.py
- Upload coverage reports to services like Codecov or Coveralls
- Set minimum coverage thresholds that must be met
- Execute integration and end-to-end tests where applicable

### Docker

We can use Bandit and Docker Scout to test any images made.

## Deployment Gates

### Quality Gates
- Require all automated checks to pass before allowing merge
- Set minimum code coverage thresholds (typically 80-90%)
- Block deployment on any high-severity security vulnerabilities
- Enforce mandatory code review approval alongside automated checks
- Require up-to-date branches before merging

## GitHub Security Best Practices

### Repository Security Settings
- Enable branch protection rules with required status checks
- Require signed commits for critical repositories
- Enable vulnerability alerts and GitHub security advisories
- Configure private vulnerability reporting for responsible disclosure
- Set up dependency review to catch vulnerable dependencies in pull requests

### Access Control & Permissions
- Use GitHub teams with least-privilege access principles
- Enable two-factor authentication organization-wide as a requirement
- Regularly audit repository collaborators and their permission levels
- Use deploy keys instead of personal access tokens where possible
- Implement SAML SSO for enterprise accounts and centralized identity management

### Secrets Management
- Store all secrets in GitHub Secrets, never commit them to code or environment files
- Use environment-specific secrets for different deployment stages (dev, staging, prod)
- Rotate secrets regularly and remove unused or expired secrets
- Consider using OpenID Connect (OIDC) instead of long-lived tokens for cloud deployments
- Implement secret scanning to prevent accidental exposure

### Supply Chain Security
- Enable Dependabot for automated dependency updates and security patches
- Use dependency pinning in requirements files for reproducible builds
- Sign releases and tags when possible for authenticity verification
- Enable GitHub's dependency graph and security alerts
- Use CodeQL or third-party Static Application Security Testing (SAST) tools in workflows
- Implement Software Bill of Materials (SBOM) generation for transparency

### Workflow Security
- Pin GitHub Actions to specific SHA commits rather than mutable tags
- Use minimal permissions in workflow files (contents: read, issues: write, etc.)
- Avoid using pull_request_target trigger unless absolutely necessary
- Validate all inputs in custom actions and reusable workflows
- Use separate workflows for trusted vs untrusted code execution
- Implement workflow approval requirements for sensitive operations

### Monitoring & Incident Response
- Set up security event notifications for suspicious activities
- Monitor for unauthorized access attempts and failed authentication
- Regularly review audit logs for compliance and security monitoring
- Maintain an incident response plan for compromised repositories
- Implement automated alerting for security policy violations
- Establish clear escalation procedures for security incidents

## Implementation Checklist

### Phase 1: Local Development Setup
- [ ] Configure pre-commit hooks
- [ ] Set up local testing environment
- [ ] Install and configure security scanning tools
- [ ] Establish coding standards and style guides

### Phase 2: Repository Configuration
- [ ] Enable branch protection rules
- [ ] Configure security settings and alerts
- [ ] Set up team permissions and access controls
- [ ] Implement secrets management strategy

### Phase 3: CI/CD Pipeline Implementation
- [ ] Create GitHub Actions workflows
- [ ] Configure automated testing and quality checks
- [ ] Set up security scanning in pipeline
- [ ] Implement deployment gates and approval processes

### Phase 4: Monitoring & Maintenance
- [ ] Establish regular security reviews
- [ ] Set up automated dependency updates
- [ ] Implement incident response procedures
- [ ] Schedule periodic access audits

## Tools & Technologies Summary

### Code Quality Tools
- **Black**: Code formatting
- **isort**: Import sorting
- **flake8**: Linting and style checking

- **RUFF**: Linting and style checking

- **pylint**: Advanced static analysis
- **mypy**: Static type checking

### Security Tools
- **bandit**: Security vulnerability scanning
- **safety**: Dependency vulnerability checking
- **detect-secrets**: Credential detection
- **semgrep**: Security pattern analysis
- **CodeQL**: GitHub's semantic code analysis

### Testing Tools
- **pytest**: Testing framework
- **tox**: Testing across environments
- **coverage.py**: Code coverage measurement

### CI/CD Tools
- **GitHub Actions**: Automation platform
- **Dependabot**: Automated dependency updates
- **GitHub Security Advisories**: Vulnerability management

This comprehensive approach ensures code quality, security, and maintainability throughout the development lifecycle while leveraging GitHub's built-in security features and best practices.
