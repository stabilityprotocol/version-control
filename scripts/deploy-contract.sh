#!/bin/bash

# -------------------------------------------
# Simple Contract Deployment to Stability (No jq required)
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

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACT_FILE="$SCRIPT_DIR/../contracts/CommitRegistry.sol"
CONFIG_FILE="$SCRIPT_DIR/../config/stability-config.sh"

# ZKT endpoints
TESTNET_ENDPOINT="https://rpc.testnet.stabilityprotocol.com/zkt/try-it-out"
MAINNET_ENDPOINT="https://rpc.stabilityprotocol.com/zkt/try-it-out"

# Function to deploy contract
deploy_contract() {
    local network="$1"
    local endpoint="$2"
    
    print_status "Deploying CommitRegistry contract to $network..."
    
    # Read the Solidity contract
    if [[ ! -f "$CONTRACT_FILE" ]]; then
        print_error "Contract file not found: $CONTRACT_FILE"
        return 1
    fi
    
    local contract_code=$(cat "$CONTRACT_FILE")
    
    # Create deployment payload (manually format JSON to avoid jq dependency)
    local temp_file="deploy_payload.json"
    cat > "$temp_file" << EOF
{
  "code": "$(echo "$contract_code" | sed 's/"/\\"/g' | tr '\n' ' ')",
  "arguments": []
}
EOF
    
    print_status "Submitting contract deployment to: $endpoint"
    
    # Deploy via ZKT
    local response_file="deploy_response.txt"
    local http_code=$(curl -s -w "%{http_code}" -o "$response_file" \
        -X POST "$endpoint" \
        -H "Content-Type: application/json" \
        -H "User-Agent: Stability-VC-Deploy/1.0.0" \
        --data-binary "@$temp_file")
    
    # Clean up temp file
    rm -f "$temp_file"
    
    print_status "HTTP Status: $http_code"
    
    if [[ "$http_code" -eq 200 ]]; then
        local response=$(cat "$response_file")
        print_status "Raw Response: $response"
        
        # Simple pattern matching to extract contract address (no jq needed)
        if echo "$response" | grep -q '"success":true'; then
            # Try to extract contract address using basic tools
            local contract_address=$(echo "$response" | sed -n 's/.*"contractAddress":"\([^"]*\)".*/\1/p')
            local tx_hash=$(echo "$response" | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p')
            
            if [[ -n "$contract_address" ]]; then
                print_status "✅ Contract deployed successfully!"
                print_status "Contract Address: $contract_address"
                print_status "Transaction Hash: $tx_hash"
                print_status "Network: $network"
                
                # Update configuration file
                if [[ -f "$CONFIG_FILE" ]]; then
                    print_status "Updating configuration file..."
                    
                    # Simple sed replacement to update contract address
                    if grep -q "STABILITY_CONTRACT_ADDRESS=" "$CONFIG_FILE"; then
                        sed -i.bak "s|export STABILITY_CONTRACT_ADDRESS=\".*\"|export STABILITY_CONTRACT_ADDRESS=\"$contract_address\"|g" "$CONFIG_FILE"
                    else
                        echo "export STABILITY_CONTRACT_ADDRESS=\"$contract_address\"" >> "$CONFIG_FILE"
                    fi
                    
                    rm -f "$CONFIG_FILE.bak"
                    print_status "Configuration updated with contract address"
                fi
                
                # Save deployment info
                local deploy_info_file="$SCRIPT_DIR/../deployment-info.txt"
                cat > "$deploy_info_file" << EOF
Contract Address: $contract_address
Transaction Hash: $tx_hash
Network: $network
Deployed At: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Deployer: Stability-VC-Deploy/1.0.0
EOF
                print_status "Deployment info saved to: $deploy_info_file"
                
                # Clean up response file
                rm -f "$response_file"
                return 0
            else
                print_error "Could not extract contract address from response"
                print_status "Response: $response"
                rm -f "$response_file"
                return 1
            fi
        else
            print_error "Contract deployment failed"
            print_error "Response: $(cat "$response_file")"
            rm -f "$response_file"
            return 1
        fi
    else
        print_error "HTTP request failed with status: $http_code"
        print_error "Response: $(cat "$response_file")"
        rm -f "$response_file"
        return 1
    fi
}

# Function to test contract interaction
test_contract() {
    local contract_address="$1"
    local network="$2"
    
    print_header "=== Testing Contract Interaction ==="
    
    local endpoint
    if [[ "$network" == "testnet" ]]; then
        endpoint="$TESTNET_ENDPOINT"
    else
        endpoint="$MAINNET_ENDPOINT"
    fi
    
    # Test contract interaction with getTotalCommits
    local test_file="test_payload.json"
    cat > "$test_file" << EOF
{
  "abi": [
    "function getTotalCommits() view returns (uint256)"
  ],
  "to": "$contract_address",
  "method": "getTotalCommits",
  "arguments": []
}
EOF
    
    print_status "Testing contract at: $contract_address"
    
    local response_file="test_response.txt"
    local http_code=$(curl -s -w "%{http_code}" -o "$response_file" \
        -X POST "$endpoint" \
        -H "Content-Type: application/json" \
        --data-binary "@$test_file")
    
    rm -f "$test_file"
    
    if [[ "$http_code" -eq 200 ]]; then
        local response=$(cat "$response_file")
        if echo "$response" | grep -q '"success":true'; then
            print_status "✅ Contract test successful!"
            print_status "Response: $response"
        else
            print_error "Contract test failed"
            print_error "Response: $response"
        fi
    else
        print_error "Contract test HTTP error: $http_code"
        print_error "Response: $(cat "$response_file")"
    fi
    
    rm -f "$response_file"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND] [NETWORK]

Commands:
    deploy [testnet|mainnet]    Deploy contract to specified network
    test <address> <network>    Test deployed contract
    help                        Show this help message

Examples:
    $0 deploy mainnet
    $0 deploy testnet
    $0 test 0x1234... mainnet

EOF
}

# Main function
main() {
    print_header "=== Stability CommitRegistry Contract Deployment ==="
    echo
    
    local command="${1:-deploy}"
    local network="${2:-mainnet}"
    
    case "$command" in
        "deploy")
            if [[ "$network" != "testnet" && "$network" != "mainnet" ]]; then
                print_error "Invalid network: $network. Use 'testnet' or 'mainnet'"
                exit 1
            fi
            
            local endpoint
            if [[ "$network" == "testnet" ]]; then
                endpoint="$TESTNET_ENDPOINT"
            else
                endpoint="$MAINNET_ENDPOINT"
            fi
            
            if deploy_contract "$network" "$endpoint"; then
                print_status "Deployment completed successfully!"
                
                # Extract contract address for testing
                if [[ -f "$SCRIPT_DIR/../deployment-info.txt" ]]; then
                    local contract_address=$(grep "Contract Address:" "$SCRIPT_DIR/../deployment-info.txt" | cut -d' ' -f3)
                    if [[ -n "$contract_address" ]]; then
                        echo
                        test_contract "$contract_address" "$network"
                    fi
                fi
            else
                print_error "Deployment failed"
                exit 1
            fi
            ;;
        "test")
            local contract_address="${2:-}"
            local test_network="${3:-mainnet}"
            
            if [[ -z "$contract_address" ]]; then
                print_error "Contract address required for testing"
                show_usage
                exit 1
            fi
            
            test_contract "$contract_address" "$test_network"
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
