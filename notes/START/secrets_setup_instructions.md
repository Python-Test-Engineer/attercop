# Secret Detection Pre-commit Hook Setup

## Quick Setup

1. **Create the script directory and copy the hook:**
   ```bash
   mkdir -p scripts
   # Copy the detect-secrets.sh script to scripts/detect-secrets.sh
   chmod +x scripts/detect-secrets.sh
   ```

2. **Copy the pre-commit configuration:**
   ```bash
   # Copy the .pre-commit-config.yaml to your repo root
   ```

3. **Install and setup pre-commit:**
   ```bash
   pip install pre-commit
   pre-commit install
   ```

4. **Initialize detect-secrets baseline (optional but recommended):**
   ```bash
   pip install detect-secrets
   detect-secrets scan --baseline .secrets.baseline
   ```

5. **Test the setup:**
   ```bash
   pre-commit run --all-files
   ```

## Adding New Secret Patterns

To add new secret detection patterns, edit the `PATTERNS` array in `scripts/detect-secrets.sh`:

```bash
declare -a PATTERNS=(
    # Existing patterns...

    # ADD NEW PATTERNS HERE:
    "your-new-pattern-regex"
    "another[_-]pattern['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{16,}['\"]"
)
```

### Pattern Examples:

- **Custom API Key:** `"myapi[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{32}['\"]"`
- **Database Password:** `"db[_-]?password['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"`
- **Custom Token:** `"myservice[_-]?token['\"]?\s*[:=]\s*['\"]sk_[a-zA-Z0-9]{24}['\"]"`

## Adding New File Extensions

To scan additional file types, add them to the `EXTENSIONS` array:

```bash
declare -a EXTENSIONS=(
    # Existing extensions...
    "new-extension"
    "another-ext"
)
```

## Configuration Options

You can modify these variables in the script:

- `EXCLUDE_PATTERNS`: Files/paths to skip scanning
- `MAX_FILE_SIZE`: Maximum file size to scan (in bytes)
- `PATTERNS`: Array of regex patterns to detect secrets
- `EXTENSIONS`: File extensions to scan

## Testing New Patterns

Test your new patterns before committing:

```bash
# Test on specific files
./scripts/detect-secrets.sh path/to/test/file.py

# Test on all files
./scripts/detect-secrets.sh

# Test with pre-commit
pre-commit run detect-secrets-custom --all-files
```

## Common Pattern Formats

### Environment Variables
```bash
"ENV_VAR['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
```

### Tokens with Prefixes
```bash
"prefix_[a-zA-Z0-9_-]{32}"
```

### Configuration Values
```bash
"config[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{16,}['\"]"
```

### URLs with Credentials
```bash
"https://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+"
```

## Troubleshooting

### False Positives
- Add exclusions to `EXCLUDE_PATTERNS`
- Refine regex patterns to be more specific
- Use the detect-secrets baseline to ignore known false positives

### Performance Issues
- Reduce `MAX_FILE_SIZE` for large repositories
- Add more specific file extensions instead of scanning everything
- Exclude binary files and generated files

### Pattern Not Matching
- Test regex patterns with tools like regex101.com
- Remember to escape special characters in bash strings
- Use case-insensitive matching: `grep -i` (modify the script if needed)

## Integration with CI/CD

Add to your GitHub Actions workflow:

```yaml
- name: Run pre-commit hooks
  run: |
    pre-commit run --all-files
```

Or run the script directly:

```yaml
- name: Detect secrets
  run: |
    ./scripts/detect-secrets.sh
```
