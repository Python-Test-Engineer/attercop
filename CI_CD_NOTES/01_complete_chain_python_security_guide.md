# Python Code Quality & Security Implementation Guide

## Overview
This document provides a comprehensive plan for implementing code quality, typing, and security checks for Python projects using GitHub Actions, from local development through CI/CD deployment.

## Local Development (Pre-commit)

### Pre-commit Hook Configuration

- Precommit hooks built in
    - id: trailing-whitespace
    - id: end-of-file-fixer
    - id: check-yaml
    - id: check-added-large-files
    - id: check-merge-conflict
    - id: debug-statements

- id: pyright Pyright is a powerful, fast, and feature-packed static type checker explicitly designed for Python. It helps to ensure code quality, catch errors early, and boost productivity through static type checking.
- id: ruff-check linter
    args: [--fix]
- id: ruff-format
- id: conventional-pre-commit  ensures commit message is standardised
  - stages: [commit-msg]
- id: python-script LEAK DETECTION CUSTOM
    - **enables easy dev change if needed.**
    - name: Python Script
    - entry: python custom.py
    - language: python
    - stages: [pre-commit]
    - *We can add other checks here if needed*
- id: bandit

### Conventional Commit Messages

- This provides structure around what has been committed and can be used for versioning.

### Dependency Management TO DO

UV best with its --check and lock features. uv.lock will pin everything down.

This might be done in CI/CD

We can use Tox to run tests across Python versions.


## CI/CD Pipeline (GitHub Actions)

### Workflow Triggers
- Trigger automated checks on pull requests to main/develop branches
- Execute pipeline on pushes to main branch
- Schedule periodic security scans for dependency updates

### Build Matrix Strategy
- Set up matrix testing across Python versions (3.8, 3.9, 3.10, 3.11, 3.12)
- Test across Ubuntu only.
- Install dependencies with caching for faster build times.

### Code and Security Quality Checks

- Run Ruff, tests, CodeQL, Bandit in CI
- Run mypy for static type checking
- Perform security scans with bandit for common security issues
- Run safety checks for known vulnerabilities in dependencies
- Execute semgrep for additional security pattern detection
- Scan for secrets and credentials in commit history and codebase
- Check for dependency vulnerabilities with GitHub's dependency review

### Testing & Coverage

- Run test suite with coverage if we have one.

### Docker

We can use Bandit and Docker Scout to test any images made.

We can run matric Python version for the Docerfile using arguments: --build-arg PYTHON_VERSION=3.9 etc `02_CI/DockerfileMultiple` and `02/cicd_pipeline.yaml`.

## Deployment Gates

### Quality Gates

- Enable branch protection rules by restriciting who can push to main
- Ensure there are protocols in place for code review and security alerts
- Set up team permissions and access controls
- Require all automated checks to pass before allowing merge
- Set minimum code coverage thresholds (typically 80-90%)
- Block deployment on any high-severity security vulnerabilities
- Enforce mandatory code review approval alongside automated checks
- Require up-to-date branches before merging
- Use only PROD environment on main branch and only PR from deployable branch. This locks it down.
- 4 eyes for a release and manual to start with
- Always use environment variables for sensitive information and then echo out the variable rather than having ${{}} in the output.

## GitHub Security Best Practices

### Access Control & Permissions
- Use GitHub teams with least-privilege access principles
- Enable two-factor authentication organization-wide as a requirement

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
- Implement Software Bill of Materials (SBOM) generation for transparency

### Workflow Security
- Pin GitHub Actions to specific SHA commits rather than mutable tags
- Use minimal permissions in workflow files (contents: read, issues: write, etc.)
- Avoid using pull_request_target trigger unless absolutely necessary
- Validate all inputs in custom actions and reusable workflows
- Use separate workflows for trusted vs untrusted code execution
- Implement workflow approval requirements for sensitive operations
- Use reusable workflows for common tasks and avoid duplication

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
- [ ] Secret detection setup
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
