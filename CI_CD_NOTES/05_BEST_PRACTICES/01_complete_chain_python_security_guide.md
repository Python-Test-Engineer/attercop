# Python Code Quality & Security Implementation Guide

## Overview
This document provides a comprehensive plan for implementing code quality, typing, and security checks for Python projects using GitHub Actions, from local development through CI/CD deployment.

## Local Development (Pre-commit)

### Pre-commit Hook Configuration

- Set up pre-commit hooks for linting, testing, and security checks.
- Run pre-commit automatically on commit.

### Conventional Commit Messages

- This provides structure around what has been committed and can be used for versioning.

## CI/CD Pipeline (GitHub Actions)

<img src="../../_images/lint-test-matrix-security-1.png">
<img src="../../_images/lint-test-matrix-security-2.png">

### Build Matrix Strategy
- Set up matrix testing across Python versions (3.9, 3.10, 3.11, 3.12).
- Test across Ubuntu only.
- Install dependencies with caching for faster build times.
- Download Pytest-HTML reports.

### Code and Security Quality Checks

- Run Ruff, MyPy/Pyright, Unit tests/Coverage, CodeQL, Bandit, Safety,Pip-audit in CI
- Scan for secrets and credentials in commit history and codebase
- Check for dependency vulnerabilities with GitHub's dependency review TO DO

### Docker

<img src="../../_images/docker-build-scan-push.png">

We use Trivy and Docker Scout, inbuilt in GitHub Actions, to scan Docker images for vulnerabilities and secrets, with a downloadable report.

## Environments

- prod
- staging
- dev

*dev* can be used for local development, staging for testing, and prod for production deployment.

*staging * is the dress rehearsal for prod and allows QA to work on 'almost live' code before deploying to prod.

Have the following branches:

- main (for prod)
- staging (for staging)
- dev (for dev) - devs branch off dev and merge to dev
- PR dev to staging
- Pre-release use staging for QA and final checks
- PR staging to main

Rules:

- no direct push to main but PR using two people ideally to prevent compromised account
- have dealy of 15 mins for deploying to prod to have grace period *just in case*
- in GHA have rule that PR to main must come from prod environment to ad extra security layer
- dedicated team for security review and deployment


## Deployment Gates

### Quality Gates

- Set up team permissions and access controls
- Require all automated checks to pass before allowing merge
- Set minimum code coverage thresholds (typically 80-90%)
- Block deployment on any high-severity security vulnerabilities
- Enforce mandatory code review approval alongside automated checks
- Require up-to-date branches before merging
- Use only PROD environment on main branch and only PR from deployable branch. This locks it down.
- 2 people for a release and manual to start with
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
- Validate all inputs in custom actions and reusable workflows, set env:{INPUT_NAME}
- Use separate workflows for trusted vs untrusted code execution
- Implement workflow approval requirements for sensitive operations
- Use reusable workflows for common tasks and avoid duplication

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
- **RUFF**: Linting and style checking ✅
- **mypy**: Static type checking ✅

### Security Tools
- **bandit**: Security vulnerability scanning ✅
- **safety**: Dependency vulnerability checking ✅
- **detect-secrets**: Credential detection ✅ in pre-Commit
- **gitleaks*: Credential detection ✅ in CI/CD
- **trivy**: Container vulnerability scanning ✅
- **semgrep**: Security pattern analysis
- **CodeQL**: GitHub's semantic code analysis ✅

### Testing Tools
- **pytest**: Testing framework  ✅
- **coverage.py**: Code coverage measurement  ✅

### CI/CD Tools
- **GitHub Actions**: Automation platform  ✅
- **Dependabot**: Automated dependency updates
- **GitHub Security Advisories**: Vulnerability management
