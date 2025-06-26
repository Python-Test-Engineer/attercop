#!/usr/bin/env bash

# Comprehensive Secret Scanner for src folder
# Scans all files in src/ directory for passwords, secrets, tokens, and sensitive data

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
# Handle pre-commit context where files might be passed as arguments
if [ $# -gt 0 ] && [ -f "$1" ]; then
    # Files were passed as arguments (likely from pre-commit)
    SCAN_DIR="src"  # Default to src folder
    SCAN_FILES=("$@")  # Store passed files
    USE_PASSED_FILES=true
else
    # Directory was passed or use default
    SCAN_DIR="${1:-src}"  # Default to 'src' folder, or use first argument
    USE_PASSED_FILES=false
fi
EXCLUDE_PATTERNS="\.git/|node_modules/|\.min\.js|\.map$|\.lock$|__pycache__/|\.pyc$|\.class$|target/|build/|dist/|\.jpg$|\.jpeg$|\.png$|\.gif$|\.ico$|\.svg$|\.pdf$|\.zip$|\.tar$|\.gz$"
MAX_FILE_SIZE=10485760  # 10MB in bytes
OUTPUT_FILE="secret_scan_report.txt"

# Comprehensive secret patterns
declare -A PATTERN_CATEGORIES=(
    ["API_KEYS"]="API Keys and Access Tokens"
    ["AWS"]="AWS Credentials"
    ["AZURE"]="Azure Credentials"
    ["GCP"]="Google Cloud Credentials"
    ["GITHUB"]="GitHub Tokens"
    ["GITLAB"]="GitLab Tokens"
    ["SLACK"]="Slack Tokens"
    ["STRIPE"]="Stripe Keys"
    ["PAYPAL"]="PayPal Credentials"
    ["TWILIO"]="Twilio Credentials"
    ["SENDGRID"]="SendGrid Keys"
    ["MAILGUN"]="MailGun Keys"
    ["PRIVATE_KEYS"]="Private Keys"
    ["CERTIFICATES"]="Certificates"
    ["PASSWORDS"]="Passwords"
    ["TOKENS"]="Generic Tokens"
    ["DATABASE"]="Database Credentials"
    ["JWT"]="JWT Tokens"
    ["OAUTH"]="OAuth Credentials"
    ["WEBHOOKS"]="Webhook URLs"
    ["HIGH_ENTROPY"]="High Entropy Strings"
)

# Secret patterns organized by category
declare -A PATTERNS

# API Keys and Access Tokens
PATTERNS["API_KEYS"]='
api[_-]?key['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
apikey['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
access[_-]?key['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
client[_-]?secret['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
app[_-]?secret['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
'

# AWS Credentials
PATTERNS["AWS"]='
AKIA[0-9A-Z]{16}
aws[_-]?access[_-]?key[_-]?id['\''"]?\s*[:=]\s*['\''"][A-Z0-9]{20}['\''"]
aws[_-]?secret[_-]?access[_-]?key['\''"]?\s*[:=]\s*['\''"][A-Za-z0-9/+=]{40}['\''"]
aws[_-]?session[_-]?token['\''"]?\s*[:=]\s*['\''"][A-Za-z0-9/+=]{100,}['\''"]
AWS_ACCESS_KEY_ID['\''"]?\s*[:=]\s*['\''"][A-Z0-9]{20}['\''"]
AWS_SECRET_ACCESS_KEY['\''"]?\s*[:=]\s*['\''"][A-Za-z0-9/+=]{40}['\''"]
'

# Azure Credentials
PATTERNS["AZURE"]='
[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
azure[_-]?client[_-]?secret['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_~.-]{34,}['\''"]
AZURE_CLIENT_SECRET['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_~.-]{34,}['\''"]
'

# Google Cloud Credentials
PATTERNS["GCP"]='
AIza[0-9A-Za-z_-]{35}
[0-9]+-[0-9A-Za-z_-]{32}\.apps\.googleusercontent\.com
ya29\.[0-9A-Za-z_-]{68}
"type":\s*"service_account"
'

# GitHub Tokens
PATTERNS["GITHUB"]='
gh[ps]_[A-Za-z0-9_]{36}
github[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{40}['\''"]
ghp_[A-Za-z0-9]{36}
gho_[A-Za-z0-9]{36}
ghu_[A-Za-z0-9]{36}
ghs_[A-Za-z0-9]{36}
ghr_[A-Za-z0-9]{36}
'

# GitLab Tokens
PATTERNS["GITLAB"]='
glpat-[A-Za-z0-9_-]{20}
gitlab[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
'

# Slack Tokens
PATTERNS["SLACK"]='
xox[baprs]-[0-9]{12}-[0-9]{12}-[a-zA-Z0-9]{24}
xox[baprs]-[0-9]{10,12}-[0-9]{10,12}-[a-zA-Z0-9]{24,32}
'

# Stripe Keys
PATTERNS["STRIPE"]='
sk_live_[0-9a-zA-Z]{24}
pk_live_[0-9a-zA-Z]{24}
sk_test_[0-9a-zA-Z]{24}
pk_test_[0-9a-zA-Z]{24}
rk_live_[0-9a-zA-Z]{24}
'

# PayPal
PATTERNS["PAYPAL"]='
paypal[_-]?client[_-]?id['\''"]?\s*[:=]\s*['\''"][A-Za-z0-9_-]{80}['\''"]
paypal[_-]?secret['\''"]?\s*[:=]\s*['\''"][A-Za-z0-9_-]{80}['\''"]
'

# Twilio
PATTERNS["TWILIO"]='
SK[a-z0-9]{32}
AC[a-z0-9]{32}
twilio[_-]?auth[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9]{32}['\''"]
'

# SendGrid
PATTERNS["SENDGRID"]='
SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}
sendgrid[_-]?api[_-]?key['\''"]?\s*[:=]\s*['\''"]SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}['\''"]
'

# MailGun
PATTERNS["MAILGUN"]='
key-[a-zA-Z0-9]{32}
mailgun[_-]?api[_-]?key['\''"]?\s*[:=]\s*['\''"]key-[a-zA-Z0-9]{32}['\''"]
'

# Private Keys
PATTERNS["PRIVATE_KEYS"]='
-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----
-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----
-----BEGIN\s+DSA\s+PRIVATE\s+KEY-----
-----BEGIN\s+EC\s+PRIVATE\s+KEY-----
-----BEGIN\s+PGP\s+PRIVATE\s+KEY\s+BLOCK-----
-----BEGIN\s+ENCRYPTED\s+PRIVATE\s+KEY-----
'

# Certificates
PATTERNS["CERTIFICATES"]='
-----BEGIN\s+CERTIFICATE-----
-----BEGIN\s+PUBLIC\s+KEY-----
-----BEGIN\s+RSA\s+PUBLIC\s+KEY-----
'

# Passwords
PATTERNS["PASSWORDS"]='
password['\''"]?\s*[:=]\s*['\''"][^'\''"\s]{8,}['\''"]
passwd['\''"]?\s*[:=]\s*['\''"][^'\''"\s]{8,}['\''"]
pwd['\''"]?\s*[:=]\s*['\''"][^'\''"\s]{8,}['\''"]
pass['\''"]?\s*[:=]\s*['\''"][^'\''"\s]{8,}['\''"]
secret[_-]?key['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{16,}['\''"]
auth[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{16,}['\''"]
'

# Generic Tokens
PATTERNS["TOKENS"]='
token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
bearer['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
authorization['\''"]?\s*[:=]\s*['\''"]Bearer\s+[a-zA-Z0-9_-]{20,}['\''"]
'

# Database Credentials
PATTERNS["DATABASE"]='
mongodb://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@
mysql://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@
postgres://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@
redis://[a-zA-Z0-9_.-]+:[a-zA-Z0-9_.-]+@
sqlite://[^\s]+
database[_-]?url['\''"]?\s*[:=]\s*['\''"][^'\''"]+://[^'\''"]+['\''"]
db[_-]?password['\''"]?\s*[:=]\s*['\''"][^'\''"\s]{6,}['\''"]
'

# JWT Tokens
PATTERNS["JWT"]='
eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*
'

# OAuth Credentials
PATTERNS["OAUTH"]='
client[_-]?id['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
client[_-]?secret['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
oauth[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
refresh[_-]?token['\''"]?\s*[:=]\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]
'

# Webhook URLs
PATTERNS["WEBHOOKS"]='
webhook[_-]?url['\''"]?\s*[:=]\s*['\''"]https?://[^'\''"]+['\''"]
hook[_-]?url['\''"]?\s*[:=]\s*['\''"]https?://[^'\''"]+['\''"]
'

# High Entropy Strings (potential secrets)
PATTERNS["HIGH_ENTROPY"]='
['\''"][a-zA-Z0-9+/]{40,}={0,2}['\''"]
['\''"][a-zA-Z0-9_-]{32,}['\''"]
'

# Statistics
declare -A STATS
TOTAL_FILES=0
SCANNED_FILES=0
ISSUES_FOUND=0

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

    # Skip binary files
    if [ -f "$file" ] && file "$file" | grep -q "binary"; then
        return 1
    fi

    return 0
}

# Function to scan a single file
scan_file() {
    local file="$1"
    local file_issues=0

    if [ ! -f "$file" ]; then
        return 0
    fi

    echo -e "${CYAN}The file is read: $file${NC}"
    ((SCANNED_FILES++))

    for category in "${!PATTERNS[@]}"; do
        local patterns="${PATTERNS[$category]}"

        # Process each pattern in the category
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue

            local matches=$(grep -nHE "$pattern" "$file" 2>/dev/null || true)
            if [ -n "$matches" ]; then
                if [ $file_issues -eq 0 ]; then
                    echo -e "${RED}🚨 ${PATTERN_CATEGORIES[$category]} found in: ${CYAN}$file${NC}"
                    file_issues=1
                    ((ISSUES_FOUND++))
                    STATS["$category"]=$((${STATS["$category"]:-0} + 1))
                fi
                echo -e "${YELLOW}   $matches${NC}"
            fi
        done <<< "$patterns"
    done

    return $file_issues
}

# Function to generate summary report
generate_report() {
    local report_file="$1"

    {
        echo "============================================="
        echo "      COMPREHENSIVE SECRET SCAN REPORT"
        echo "============================================="
        echo "Scan Date: $(date)"
        echo "Scanned Directory: $SCAN_DIR"
        echo "Total Files Found: $TOTAL_FILES"
        echo "Files Scanned: $SCANNED_FILES"
        echo "Files with Issues: $ISSUES_FOUND"
        echo ""

        if [ $ISSUES_FOUND -gt 0 ]; then
            echo "ISSUES BY CATEGORY:"
            echo "==================="
            for category in "${!STATS[@]}"; do
                if [ ${STATS["$category"]} -gt 0 ]; then
                    echo "- ${PATTERN_CATEGORIES[$category]}: ${STATS[$category]} files"
                fi
            done
            echo ""

            echo "SECURITY RECOMMENDATIONS:"
            echo "========================="
            echo "1. Remove hardcoded secrets immediately"
            echo "2. Use environment variables for sensitive data"
            echo "3. Implement secret management solutions (HashiCorp Vault, AWS Secrets Manager)"
            echo "4. Add .env files to .gitignore"
            echo "5. Use git-crypt or similar for encrypted secrets"
            echo "6. Implement pre-commit hooks to prevent future issues"
            echo "7. Rotate any exposed credentials"
            echo "8. Review git history for previously committed secrets"
        else
            echo "✅ No secrets detected in scanned files!"
        fi

        echo ""
        echo "============================================="
    } > "$report_file"
}

# Function to show progress
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))

    printf "\r${BLUE}Progress: ["
    printf "%${filled_length}s" | tr ' ' '='
    printf "%$((bar_length - filled_length))s" | tr ' ' '-'
    printf "] %d%% (%d/%d)${NC}" "$percent" "$current" "$total"
}

# Main execution
main() {
    echo -e "${GREEN}🔍 Comprehensive Secret Scanner${NC}"
    echo -e "${GREEN}================================${NC}"

    echo -e "${BLUE}📁 Scanning directory: $SCAN_DIR${NC}"
    echo -e "${BLUE}🔍 Looking for: ${#PATTERN_CATEGORIES[@]} types of secrets${NC}"
    echo ""

    # Get list of all files
    local files=()
    if [ "$USE_PASSED_FILES" = true ]; then
        # Use files passed as arguments, but filter for src/ files
        for file in "${SCAN_FILES[@]}"; do
            if [[ "$file" == src/* ]] || [[ "$file" == *src/* ]]; then
                files+=("$file")
                ((TOTAL_FILES++))
            fi
        done
    else
        # Scan directory normally
        if [ ! -d "$SCAN_DIR" ]; then
            echo -e "${RED}❌ Directory '$SCAN_DIR' not found!${NC}"
            echo -e "${YELLOW}Usage: $0 [directory]${NC}"
            exit 1
        fi

        while IFS= read -r -d '' file; do
            files+=("$file")
            ((TOTAL_FILES++))
        done < <(find "$SCAN_DIR" -type f -print0)
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No files found in $SCAN_DIR${NC}"
        exit 0
    fi

    echo -e "${GREEN}📊 Found $TOTAL_FILES files total${NC}"
    echo ""

    # Scan files with progress
    local current=0
    for file in "${files[@]}"; do
        ((current++))
        show_progress $current ${#files[@]}

        if should_scan_file "$file"; then
            scan_file "$file"
        fi
    done

    echo "" # New line after progress bar
    echo ""

    # Generate and display summary
    echo -e "${GREEN}📋 Generating report...${NC}"
    generate_report "$OUTPUT_FILE"

    # Show summary
    echo -e "${GREEN}✅ Scan completed!${NC}"
    echo -e "${CYAN}📊 SUMMARY:${NC}"
    echo -e "   Total files: $TOTAL_FILES"
    echo -e "   Scanned files: $SCANNED_FILES"
    echo -e "   Files with issues: $ISSUES_FOUND"
    echo ""

    if [ $ISSUES_FOUND -gt 0 ]; then
        echo -e "${RED}⚠️  Issues found by category:${NC}"
        for category in "${!STATS[@]}"; do
            if [ ${STATS["$category"]} -gt 0 ]; then
                echo -e "   ${YELLOW}• ${PATTERN_CATEGORIES[$category]}: ${STATS[$category]} files${NC}"
            fi
        done
        echo ""
        echo -e "${YELLOW}📄 Detailed report saved to: $OUTPUT_FILE${NC}"
        echo -e "${RED}🚨 Please review and remediate the issues found!${NC}"
        exit 1
    else
        echo -e "${GREEN}🎉 No secrets detected! Your code looks clean.${NC}"
        echo -e "${YELLOW}📄 Report saved to: $OUTPUT_FILE${NC}"
        exit 0
    fi
}

# Run main function
main "$@"
