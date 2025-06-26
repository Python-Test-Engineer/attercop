#!/bin/bash

# Secret Detection Pre-commit Hook
# Add new patterns to the PATTERNS array below

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Configuration
EXCLUDE_PATTERNS="\.git/|\.secrets\.baseline|package-lock\.json|poetry\.lock|yarn\.lock|\.min\.js|\.map$"
MAX_FILE_SIZE=1048576  # 1MB in bytes

# Secret patterns - ADD NEW PATTERNS HERE
declare -a PATTERNS=(
    # API Keys
    "api[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
    "apikey['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"

    # AWS
    "AKIA[0-9A-Z]{16}"
    "aws[_-]?access[_-]?key[_-]?id['\"]?\s*[:=]\s*['\"][A-Z0-9]{20}['\"]"
    "aws[_-]?secret[_-]?access[_-]?key['\"]?\s*[:=]\s*['\"][A-Za-z0-9/+=]{40}['\"]"

    # GitHub
    "gh[ps]_[A-Za-z0-9_]{36}"
    "github[_-]?token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{40}['\"]"

    # Private Keys
    "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
    "-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----"
    "-----BEGIN\s+DSA\s+PRIVATE\s+KEY-----"
    "-----BEGIN\s+EC\s+PRIVATE\s+KEY-----"

    # Generic Secrets
    "secret[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{16,}['\"]"
    "password['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "passwd['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "auth[_-]?token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{16,}['\"]"

    # Database URLs
    "mongodb://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@"
    "mysql://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@"
    "postgres://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@"

    # JWT Tokens
    "eyJ[A-Za-z0-9_-]*\\.eyJ[A-Za-z0-9_-]*\\.[A-Za-z0-9_-]*"

    # Google API
    "AIza[0-9A-Za-z_-]{35}"

    # Slack
    "xox[baprs]-[0-9]{12}-[0-9]{12}-[a-zA-Z0-9]{24}"

    # Stripe
    "sk_live_[0-9a-zA-Z]{24}"
    "pk_live_[0-9a-zA-Z]{24}"

    # Generic high-entropy strings (might have false positives)
    # "['\"][a-zA-Z0-9_-]{32,}['\"]"
)

# File extensions to check - ADD NEW EXTENSIONS HERE
declare -a EXTENSIONS=(
    "py" "js" "ts" "jsx" "tsx" "json" "yaml" "yml"
    "env" "cfg" "conf" "config" "ini" "toml"
    "sh" "bash" "zsh" "fish"
    "php" "rb" "go" "java" "scala" "kt"
    "cs" "cpp" "c" "h" "hpp"
    "rs" "swift" "dart"
    "sql" "xml" "html" "css" "scss" "sass"
    "dockerfile" "makefile"
    "tf" "tfvars" "hcl"
)

# Function to check if file should be scanned
should_scan_file() {
    local file="$1"

    # Skip if file matches exclude patterns
    if echo "$file" | grep -qE "$EXCLUDE_PATTERNS"; then
        return 1
    fi

    # Skip if file is too large
    if [ -f "$file" ] && [ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt $MAX_FILE_SIZE ]; then
        return 1
    fi

    # Check if file has relevant extension
    local ext="${file##*.}"
    for valid_ext in "${EXTENSIONS[@]}"; do
        if [ "$ext" = "$valid_ext" ]; then
            return 0
        fi
    done

    # Also check files without extensions (like Dockerfile, Makefile)
    if [[ "$file" =~ (Dockerfile|Makefile|Rakefile)$ ]]; then
        return 0
    fi

    return 1
}

# Function to scan a single file
scan_file() {
    local file="$1"
    local found_secrets=0

    if [ ! -f "$file" ]; then
        return 0
    fi

    for pattern in "${PATTERNS[@]}"; do
        local matches=$(grep -nHE "$pattern" "$file" 2>/dev/null || true)
        if [ -n "$matches" ]; then
            if [ $found_secrets -eq 0 ]; then
                echo -e "${RED}🚨 Potential secrets found in: $file${NC}"
                found_secrets=1
            fi
            echo -e "${YELLOW}$matches${NC}"
        fi
    done

    return $found_secrets
}

# Main execution
main() {
    local exit_code=0
    local files_to_check=()

    echo -e "${GREEN}🔍 Scanning for secrets, passwords, and tokens...${NC}"

    # Get list of files to check
    if [ $# -eq 0 ]; then
        # No arguments, check all staged files
        while IFS= read -r -d '' file; do
            if should_scan_file "$file"; then
                files_to_check+=("$file")
            fi
        done < <(git diff --cached --name-only -z)
    else
        # Arguments provided, check those files
        for file in "$@"; do
            if should_scan_file "$file"; then
                files_to_check+=("$file")
            fi
        done
    fi

    if [ ${#files_to_check[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ No relevant files to scan${NC}"
        return 0
    fi

    echo -e "${GREEN}📁 Scanning ${#files_to_check[@]} files...${NC}"

    # Scan each file
    for file in "${files_to_check[@]}"; do
        if ! scan_file "$file"; then
            exit_code=1
        fi
    done

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ No secrets detected!${NC}"
    else
        echo ""
        echo -e "${RED}❌ Secrets detected! Please review and remove them before committing.${NC}"
        echo -e "${YELLOW}💡 Tips:${NC}"
        echo -e "${YELLOW}   • Use environment variables instead of hardcoded secrets${NC}"
        echo -e "${YELLOW}   • Use .env files (and add them to .gitignore)${NC}"
        echo -e "${YELLOW}   • Use secret management tools like HashiCorp Vault${NC}"
        echo -e "${YELLOW}   • Consider using git-crypt for encrypted secrets${NC}"
    fi

    return $exit_code
}

# Run main function
main "$@"
