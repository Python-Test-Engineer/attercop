You can prevent secret keys from being pushed using pre-commit hooks with several tools. Here are the most effective approaches:

https://github.com/awslabs/git-secrets

## Using detect-secrets

The most popular tool is `detect-secrets`. Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: package.lock.json
```

Initialize the baseline file:
```bash
detect-secrets scan --baseline .secrets.baseline
```

## Using GitLeaks

Another excellent option is GitLeaks:

```yaml
repos:
  - repo: https://github.com/zricethezav/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

## Using pre-commit-hooks

The basic pre-commit-hooks repo includes a simple detector:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: detect-private-key
```

## Complete example .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: detect-private-key
      - id: check-added-large-files
      - id: trailing-whitespace
      - id: end-of-file-fixer

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: |
          (?x)^(
              poetry.lock|
              package-lock.json|
              \.secrets\.baseline
          )$
```

## Setup steps

1. Install pre-commit: `pip install pre-commit`
2. Create `.pre-commit-config.yaml` in your repo root
3. Install the hooks: `pre-commit install`
4. If using detect-secrets, create baseline: `detect-secrets scan --baseline .secrets.baseline` https://www.youtube.com/watch?v=15A_TkKipSc
5. Test: `pre-commit run --all-files`

The hooks will automatically run before each commit and block the commit if secrets are detected. `detect-secrets` is generally recommended as it's more sophisticated and has fewer false positives than the basic detector.
