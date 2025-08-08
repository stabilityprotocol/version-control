#!/bin/bash

# -------------------------------------------
# Quick Test Setup for Stability Version Control
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to create test repository
create_test_repo() {
    local test_dir="$1"
    
    print_status "Creating test repository: $test_dir"
    
    if [[ -d "$test_dir" ]]; then
        print_warning "Test directory already exists: $test_dir"
        read -p "Remove and recreate? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$test_dir"
        else
            print_status "Using existing directory"
            cd "$test_dir"
            return 0
        fi
    fi
    
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Initialize git repo
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial files
    cat > README.md << EOF
# Test Repository for Stability Blockchain Version Control

This is a test repository to validate the Stability blockchain integration.

## Test Information

- Created: $(date)
- Purpose: Testing ZKT API integration
- Network: Testnet (by default)

## Files

- README.md: This file
- test-file.txt: Sample content file
- .gitignore: Git ignore patterns

EOF
    
    cat > test-file.txt << EOF
This is a test file for Stability blockchain version control.

Content timestamp: $(date)
Random content: $(head -c 20 /dev/urandom | base64)

This file will be used to test:
1. Initial commit recording
2. Modification tracking
3. Hash generation
4. Blockchain submission

EOF
    
    cat > .gitignore << EOF
# Stability Version Control
stability-vc/logs/*.log
*.backup.*
deployment-info.json
zkt-test-*.json
verification-report-*.txt

# OS Files
.DS_Store
Thumbs.db

# IDE Files
.vscode/
.idea/
*.swp
*.swo

EOF
    
    # Initial commit
    git add .
    git commit -m "Initial commit for Stability blockchain testing"
    
    print_status "✅ Test repository created successfully"
    print_status "Repository path: $(pwd)"
    
    return 0
}

# Function to install hook in test repo
install_hook() {
    print_status "Installing Stability blockchain hook..."
    
    # Manual installation for testing (more reliable)
    # Use absolute path to avoid issues when changing directories
    local hook_source="$PROJECT_ROOT/hooks/post-commit"
    local hook_destination=".git/hooks/post-commit"
    
    # Check if source hook exists
    if [[ ! -f "$hook_source" ]]; then
        print_error "Source hook file not found: $hook_source"
        return 1
    fi
    
    # Backup existing hook if it exists
    if [[ -f "$hook_destination" ]]; then
        local backup_path="$hook_destination.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backing up existing hook to: $backup_path"
        cp "$hook_destination" "$backup_path"
    fi
    
    # Install the hook
    print_status "Installing hook..."
    cp "$hook_source" "$hook_destination"
    chmod +x "$hook_destination"
    
    # Create configuration directory and files
    local config_dir="stability-vc"
    local config_path="$config_dir/config"
    local log_path="$config_dir/logs"
    
    mkdir -p "$config_path"
    mkdir -p "$log_path"
    
    # Copy and configure the config file
    cp "$PROJECT_ROOT/config/stability-config.sh" "$config_path/"
    
    # Update configuration for testing
    local config_file="$config_path/stability-config.sh"
    
    # Set mainnet configuration by default (Windows-compatible approach)
    if command -v sed >/dev/null 2>&1; then
        # Use sed if available
        sed -i.bak 's|export STABILITY_ZKT_ENDPOINT=".*"|export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt"|g' "$config_file"
        sed -i.bak 's|export STABILITY_NETWORK=".*"|export STABILITY_NETWORK="mainnet"|g' "$config_file"
        sed -i.bak 's|export PROJECT_NAME=".*"|export PROJECT_NAME="Stability Test Project"|g' "$config_file"
        rm -f "$config_file.bak"
        
        # Update hook to point to correct config location
        sed -i.bak 's|../config/stability-config.sh|../../stability-vc/config/stability-config.sh|g' "$hook_destination"
        sed -i.bak 's|../logs/stability-hook.log|../../stability-vc/logs/stability-hook.log|g' "$hook_destination"
        rm -f "$hook_destination.bak"
    else
        # Fallback: rewrite config file manually
        cat > "$config_file" << 'EOF'
#!/bin/bash

# Stability ZKT API Configuration
export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt"
export STABILITY_API_KEY=""

# Smart Contract Configuration
export STABILITY_CONTRACT_ADDRESS=""
export STABILITY_NETWORK="mainnet"

# Project Configuration
export PROJECT_NAME="Stability Test Project"
export PROJECT_ID=""

# Hook Configuration
export ENABLE_VERBOSE_LOGGING="true"
export ENABLE_HASH_VERIFICATION="true"
export TIMEOUT_SECONDS="30"
export RETRY_ATTEMPTS="3"
export RETRY_DELAY_SECONDS="2"

validate_config() {
    local errors=0
    local warnings=0
    
    if [[ -z "$STABILITY_ZKT_ENDPOINT" ]]; then
        echo "ERROR: STABILITY_ZKT_ENDPOINT is not set"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$STABILITY_API_KEY" ]]; then
        echo "WARNING: STABILITY_API_KEY is not set - will use public ZKT endpoint"
        warnings=$((warnings + 1))
    fi
    
    if [[ -z "$STABILITY_CONTRACT_ADDRESS" || "$STABILITY_CONTRACT_ADDRESS" == "0x0000000000000000000000000000000000000000" ]]; then
        echo "WARNING: No smart contract address configured - using simple message format"
        warnings=$((warnings + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        echo "Configuration validation failed with $errors error(s) and $warnings warning(s)"
        return 1
    fi
    
    echo "Configuration validation passed with $warnings warning(s)"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_config
fi
EOF
        
        # Manually update hook paths
        cp "$hook_destination" "$hook_destination.tmp"
        cat "$hook_destination.tmp" | \
            sed 's|../config/stability-config.sh|../../stability-vc/config/stability-config.sh|g' | \
            sed 's|../logs/stability-hook.log|../../stability-vc/logs/stability-hook.log|g' > "$hook_destination"
        rm -f "$hook_destination.tmp"
        chmod +x "$hook_destination"
    fi
    
    print_status "✅ Hook installed and configured for testing"
    print_status "Configuration: Using mainnet with public endpoint"
    
    return 0
}

# Function to test basic functionality
test_basic_functionality() {
    print_header "=== Testing Basic Functionality ==="
    
    # Test 1: Create a new file and commit
    print_status "Test 1: Creating and committing new file..."
    
    echo "Test content $(date)" > new-file.txt
    git add new-file.txt
    git commit -m "Add new test file for blockchain verification"
    
    # Check if log file was created
    if [[ -f "stability-vc/logs/stability-hook.log" ]]; then
        print_status "✅ Log file created"
        print_status "Recent log entries:"
        tail -5 "stability-vc/logs/stability-hook.log"
    else
        print_warning "⚠️  Log file not found"
    fi
    
    echo
    
    # Test 2: Modify existing file and commit
    print_status "Test 2: Modifying existing file..."
    
    echo "" >> README.md
    echo "## Test Update" >> README.md
    echo "Modified at: $(date)" >> README.md
    
    git add README.md
    git commit -m "Update README with test modification"
    
    echo
    
    # Test 3: Multiple file commit
    print_status "Test 3: Multiple file commit..."
    
    echo "Additional test data $(date)" > another-file.txt
    echo "More content for test-file.txt" >> test-file.txt
    
    git add .
    git commit -m "Multiple file update for comprehensive testing"
    
    print_status "✅ Basic functionality tests completed"
}

# Function to run verification tests
test_verification() {
    print_header "=== Testing Verification ==="
    
    # Test hash generation
    if command -v sha256sum >/dev/null 2>&1; then
        local current_hash=$(git archive HEAD | sha256sum | awk '{print $1}')
        print_status "Current repository hash: $current_hash"
    elif command -v shasum >/dev/null 2>&1; then
        local current_hash=$(git archive HEAD | shasum -a 256 | awk '{print $1}')
        print_status "Current repository hash: $current_hash"
    else
        print_warning "SHA-256 tool not available for verification"
    fi
    
    # Run verification script if available
    if [[ -f "$PROJECT_ROOT/examples/verify-integrity.sh" ]]; then
        print_status "Running integrity verification..."
        bash "$PROJECT_ROOT/examples/verify-integrity.sh" current || true
    fi
}

# Function to test ZKT API directly
test_zkt_api() {
    print_header "=== Testing ZKT API ==="
    
    if [[ -f "$PROJECT_ROOT/examples/test-zkt-api.sh" ]]; then
        print_status "Running ZKT API tests..."
        bash "$PROJECT_ROOT/examples/test-zkt-api.sh" simple testnet || true
    else
        print_warning "ZKT API test script not found"
    fi
}

# Function to show test results
show_test_results() {
    print_header "=== Test Results Summary ==="
    
    # Check git log
    print_status "Git commit history:"
    git log --oneline -5
    echo
    
    # Check hook log
    if [[ -f "stability-vc/logs/stability-hook.log" ]]; then
        print_status "Hook execution log (last 10 lines):"
        tail -10 "stability-vc/logs/stability-hook.log"
        echo
        
        # Count successful submissions
        local success_count=$(grep -c "Successfully submitted to blockchain" "stability-vc/logs/stability-hook.log" || echo "0")
        print_status "Successful blockchain submissions: $success_count"
    fi
    
    # Show generated files
    print_status "Generated files:"
    ls -la *.json *.txt 2>/dev/null || print_status "No additional files generated"
    
    # Show configuration
    if [[ -f "stability-vc/config/stability-config.sh" ]]; then
        print_status "Configuration:"
        grep "export" "stability-vc/config/stability-config.sh" | grep -v "API_KEY" || true
    fi
}

# Function to show cleanup instructions
show_cleanup_instructions() {
    print_header "=== Cleanup Instructions ==="
    print_status "To clean up this test:"
    echo
    echo "1. Uninstall the hook:"
    echo "   bash $PROJECT_ROOT/scripts/uninstall-hook.sh complete"
    echo
    echo "2. Remove test directory:"
    echo "   cd .."
    echo "   rm -rf $(basename "$(pwd)")"
    echo
    echo "3. Or keep for further testing:"
    echo "   - Modify files and commit to test more"
    echo "   - Check logs: cat stability-vc/logs/stability-hook.log"
    echo "   - Run verification: bash $PROJECT_ROOT/examples/verify-integrity.sh current"
    echo
    print_warning "Note: Blockchain records are permanent and cannot be removed"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TEST_DIR]

Options:
    --install-only      Only install hook, don't run tests
    --test-only         Only run tests (assumes hook is installed)
    --api-test          Test ZKT API directly
    --help              Show this help message

Arguments:
    TEST_DIR           Directory name for test repository (default: stability-test)

Examples:
    $0                          # Full test in ./stability-test
    $0 my-test                  # Full test in ./my-test  
    $0 --install-only           # Just install hook
    $0 --test-only              # Run tests only
    $0 --api-test               # Test ZKT API directly

EOF
}

# Main function
main() {
    print_header "=== Stability Blockchain Version Control Quick Test ==="
    echo
    
    local install_only=false
    local test_only=false
    local api_test=false
    local test_dir="stability-test"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-only)
                install_only=true
                shift
                ;;
            --test-only)
                test_only=true
                shift
                ;;
            --api-test)
                api_test=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                test_dir="$1"
                shift
                ;;
        esac
    done
    
    # API test only
    if [[ "$api_test" == true ]]; then
        test_zkt_api
        exit 0
    fi
    
    # Create/enter test repository
    if [[ "$test_only" != true ]]; then
        create_test_repo "$test_dir"
    else
        if [[ ! -d "$test_dir" ]]; then
            print_error "Test directory not found: $test_dir"
            exit 1
        fi
        cd "$test_dir"
    fi
    
    # Install hook
    if [[ "$test_only" != true ]]; then
        if ! install_hook; then
            print_error "Hook installation failed"
            exit 1
        fi
    fi
    
    # Run tests
    if [[ "$install_only" != true ]]; then
        test_basic_functionality
        echo
        test_verification
        echo
        show_test_results
        echo
        show_cleanup_instructions
    else
        print_status "✅ Hook installation completed"
        print_status "Test repository ready: $(pwd)"
        echo
        print_status "To run tests manually:"
        echo "  cd $(pwd)"
        echo "  echo 'test' > file.txt && git add file.txt && git commit -m 'test'"
    fi
}

# Run main function
main "$@"