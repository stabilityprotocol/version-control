#!/bin/bash

# -------------------------------------------
# Stability Blockchain Integrity Verification
# -------------------------------------------

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Function to get SHA-256 command
get_hash_command() {
    if command -v sha256sum >/dev/null 2>&1; then
        echo "sha256sum"
    elif command -v shasum >/dev/null 2>&1; then
        echo "shasum -a 256"
    elif command -v gsha256sum >/dev/null 2>&1; then
        echo "gsha256sum"
    else
        print_error "No SHA-256 command found"
        exit 1
    fi
}

# Function to verify a specific commit
verify_commit() {
    local commit_hash="$1"
    local blockchain_hash="$2"
    
    print_status "Verifying commit: $commit_hash"
    
    # Check out the specific commit
    git checkout "$commit_hash" >/dev/null 2>&1
    
    # Generate hash
    local hash_command=$(get_hash_command)
    local local_hash=$(git archive HEAD | $hash_command | awk '{print $1}')
    
    print_status "Local hash:      $local_hash"
    print_status "Blockchain hash: $blockchain_hash"
    
    if [[ "$local_hash" == "$blockchain_hash" ]]; then
        print_status "✅ Verification PASSED - Hashes match"
        return 0
    else
        print_error "❌ Verification FAILED - Hashes do not match"
        return 1
    fi
}

# Function to verify current commit
verify_current_commit() {
    print_header "=== Verifying Current Commit ==="
    
    local commit_hash=$(git rev-parse HEAD)
    print_status "Current commit: $commit_hash"
    
    # Generate current hash
    local hash_command=$(get_hash_command)
    local current_hash=$(git archive HEAD | $hash_command | awk '{print $1}')
    
    print_status "Current codebase hash: $current_hash"
    
    # Check if this commit has blockchain record
    local config_file="stability-vc/config/stability-config.sh"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        
        print_status "Checking blockchain for this commit..."
        
        # Query blockchain (this would be a real API call)
        print_status "API Endpoint: $STABILITY_API_ENDPOINT"
        
        # Simulate API call (replace with actual API call)
        print_warning "Note: This is a simulation - replace with actual API call"
        print_status "curl -H \"API-Key: [REDACTED]\" \"$STABILITY_API_ENDPOINT/$commit_hash\""
        
    else
        print_warning "No Stability configuration found"
    fi
}

# Function to verify repository integrity
verify_repository_integrity() {
    print_header "=== Repository Integrity Check ==="
    
    # Check for any uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "Repository has uncommitted changes"
        print_warning "Verification will be based on last committed state"
    else
        print_status "Repository is clean - no uncommitted changes"
    fi
    
    # Check Git repository integrity
    print_status "Running Git fsck..."
    if git fsck --full --strict > /dev/null 2>&1; then
        print_status "✅ Git repository integrity check passed"
    else
        print_error "❌ Git repository integrity check failed"
        return 1
    fi
    
    # Verify refs
    print_status "Verifying Git references..."
    if git show-ref --verify --quiet refs/heads/$(git rev-parse --abbrev-ref HEAD); then
        print_status "✅ Current branch reference is valid"
    else
        print_error "❌ Current branch reference is invalid"
        return 1
    fi
}

# Function to generate verification report
generate_verification_report() {
    print_header "=== Verification Report ==="
    
    local report_file="verification-report-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Stability Blockchain Verification Report"
        echo "========================================"
        echo "Generated: $(date)"
        echo "Repository: $(pwd)"
        echo "Commit: $(git rev-parse HEAD)"
        echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
        echo "Author: $(git log -1 --pretty=format:'%an <%ae>')"
        echo "Date: $(git log -1 --pretty=format:'%cd')"
        echo "Message: $(git log -1 --pretty=format:'%s')"
        echo ""
        echo "Codebase Hash:"
        local hash_command=$(get_hash_command)
        git archive HEAD | $hash_command
        echo ""
        echo "Git Status:"
        git status --porcelain
        echo ""
        echo "Repository Statistics:"
        echo "- Total commits: $(git rev-list --all --count)"
        echo "- Total files: $(git ls-tree -r --name-only HEAD | wc -l)"
        echo "- Repository size: $(du -sh .git | cut -f1)"
    } > "$report_file"
    
    print_status "Verification report saved: $report_file"
}

# Function to compare two commits
compare_commits() {
    local commit1="$1"
    local commit2="$2"
    
    print_header "=== Comparing Commits ==="
    print_status "Commit 1: $commit1"
    print_status "Commit 2: $commit2"
    
    # Generate hashes for both commits
    local hash_command=$(get_hash_command)
    
    git checkout "$commit1" >/dev/null 2>&1
    local hash1=$(git archive HEAD | $hash_command | awk '{print $1}')
    
    git checkout "$commit2" >/dev/null 2>&1
    local hash2=$(git archive HEAD | $hash_command | awk '{print $1}')
    
    print_status "Hash 1: $hash1"
    print_status "Hash 2: $hash2"
    
    if [[ "$hash1" == "$hash2" ]]; then
        print_warning "⚠️  Hashes are identical - no changes detected"
    else
        print_status "✅ Hashes are different - changes detected as expected"
    fi
    
    # Show file differences
    print_status "File changes:"
    git diff --name-status "$commit1" "$commit2" || true
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
    current                 Verify current commit
    commit <hash>           Verify specific commit  
    compare <hash1> <hash2> Compare two commits
    integrity               Check repository integrity
    report                  Generate verification report
    help                    Show this help message

Options:
    -v, --verbose          Enable verbose output
    -q, --quiet           Suppress non-error output

Examples:
    $0 current
    $0 commit abc123def456
    $0 compare HEAD~1 HEAD
    $0 integrity
    $0 report

EOF
}

# Main function
main() {
    local command="${1:-current}"
    
    case "$command" in
        "current")
            check_git_repo
            verify_current_commit
            ;;
        "commit")
            if [[ $# -lt 2 ]]; then
                print_error "Commit hash required"
                show_usage
                exit 1
            fi
            check_git_repo
            # This would verify against blockchain data
            print_status "Commit verification for: $2"
            print_warning "Note: Blockchain verification requires API implementation"
            ;;
        "compare")
            if [[ $# -lt 3 ]]; then
                print_error "Two commit hashes required"
                show_usage
                exit 1
            fi
            check_git_repo
            compare_commits "$2" "$3"
            ;;
        "integrity")
            check_git_repo
            verify_repository_integrity
            ;;
        "report")
            check_git_repo
            generate_verification_report
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"