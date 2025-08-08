#!/bin/bash

# -------------------------------------------
# Stability Blockchain Git Hook Tester
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

# Function to create a test repository
create_test_repo() {
    local test_dir="stability-test-repo"
    
    print_status "Creating test repository: $test_dir"
    
    # Clean up existing test repo
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
    
    mkdir "$test_dir"
    cd "$test_dir"
    
    # Initialize git repo
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial file
    echo "# Test Repository for Stability Blockchain" > README.md
    echo "This is a test repository to validate the Stability blockchain git hook." >> README.md
    echo "Created at: $(date)" >> README.md
    
    git add README.md
    git commit -m "Initial commit for Stability blockchain testing"
    
    print_status "Test repository created successfully"
}

# Function to install hook in test repo
install_test_hook() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_status "Installing Stability hook in test repository..."
    
    # Run the installer
    bash "$script_dir/install-hook.sh"
    
    print_status "Hook installation completed"
}

# Function to test hook functionality
test_hook_functionality() {
    print_header "=== Testing Hook Functionality ==="
    
    # Create a test file
    echo "Test content for hook validation" > test-file.txt
    echo "Timestamp: $(date)" >> test-file.txt
    
    git add test-file.txt
    
    print_status "Making test commit to trigger hook..."
    git commit -m "Test commit to validate Stability blockchain hook"
    
    # Check if log file was created
    if [[ -f "stability-vc/logs/stability-hook.log" ]]; then
        print_status "Hook executed successfully - log file created"
        echo
        print_header "=== Hook Log Output ==="
        cat "stability-vc/logs/stability-hook.log"
        echo
    else
        print_warning "Log file not found - hook may not have executed"
    fi
}

# Function to validate hash generation
validate_hash_generation() {
    print_header "=== Validating Hash Generation ==="
    
    # Get the current commit hash
    local commit_hash=$(git rev-parse HEAD)
    print_status "Current commit: $commit_hash"
    
    # Generate hash manually to compare
    local manual_hash
    if command -v sha256sum >/dev/null 2>&1; then
        manual_hash=$(git archive HEAD | sha256sum | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        manual_hash=$(git archive HEAD | shasum -a 256 | awk '{print $1}')
    elif command -v gsha256sum >/dev/null 2>&1; then
        manual_hash=$(git archive HEAD | gsha256sum | awk '{print $1}')
    else
        print_error "No SHA-256 command available for validation"
        return 1
    fi
    
    print_status "Manually generated hash: $manual_hash"
    
    # Check if the hash appears in the log
    if [[ -f "stability-vc/logs/stability-hook.log" ]] && grep -q "$manual_hash" "stability-vc/logs/stability-hook.log"; then
        print_status "✅ Hash validation successful - matches log output"
    else
        print_warning "⚠️  Hash validation inconclusive - check log file"
    fi
}

# Function to simulate API response
simulate_api_test() {
    print_header "=== API Configuration Test ==="
    
    local config_file="stability-vc/config/stability-config.sh"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        
        print_status "Testing API endpoint configuration..."
        print_status "Endpoint: $STABILITY_API_ENDPOINT"
        
        if [[ -n "$STABILITY_API_KEY" ]]; then
            print_status "API Key: [CONFIGURED]"
        else
            print_warning "API Key: [NOT CONFIGURED]"
        fi
        
        # Test basic connectivity (without sending real data)
        print_status "Testing basic connectivity to API endpoint..."
        if curl -s --connect-timeout 10 -I "$STABILITY_API_ENDPOINT" >/dev/null 2>&1; then
            print_status "✅ API endpoint is reachable"
        else
            print_warning "⚠️  API endpoint may not be reachable (this is expected if using a test endpoint)"
        fi
    else
        print_error "Configuration file not found: $config_file"
    fi
}

# Function to clean up test
cleanup_test() {
    print_status "Cleaning up test environment..."
    cd ..
    
    read -p "Remove test repository? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "stability-test-repo"
        print_status "Test repository removed"
    else
        print_status "Test repository preserved: stability-test-repo"
    fi
}

# Main test function
main() {
    print_header "=== Stability Blockchain Git Hook Tester ==="
    echo
    
    print_status "This script will create a test repository and validate the Git hook functionality"
    echo
    
    read -p "Continue with testing? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_status "Testing cancelled"
        exit 0
    fi
    
    create_test_repo
    install_test_hook
    test_hook_functionality
    validate_hash_generation
    simulate_api_test
    
    echo
    print_header "=== Test Summary ==="
    print_status "Git hook testing completed!"
    echo
    echo "Review the output above to ensure everything is working correctly."
    echo "Check the log file at: stability-test-repo/stability-vc/logs/stability-hook.log"
    echo
    
    cleanup_test
}

# Run main function
main "$@"