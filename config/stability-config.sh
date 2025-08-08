#!/bin/bash

# -------------------------------------------
# Stability Blockchain Configuration
# -------------------------------------------

# Stability ZKT API Configuration
export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt"  # Testnet by default
export STABILITY_API_KEY=""  # Optional: Set your API key for private endpoint

# Smart Contract Configuration
export STABILITY_CONTRACT_ADDRESS="0x0000000000000000000000000000000000000000"  # Deploy your own contract or use shared instance
export STABILITY_NETWORK="mainnet"    # "testnet" or "mainnet"

# Optional: Project Configuration
export PROJECT_NAME=""       # Optional project identifier
export PROJECT_ID=""         # Optional project ID for Stability

# Hook Configuration
export ENABLE_VERBOSE_LOGGING="true"
export ENABLE_HASH_VERIFICATION="true"

# Advanced Configuration
export TIMEOUT_SECONDS="30"
export RETRY_ATTEMPTS="3"
export RETRY_DELAY_SECONDS="2"

# -------------------------------------------
# Configuration Validation
# -------------------------------------------

validate_config() {
    local errors=0
    local warnings=0
    
    if [[ -z "$STABILITY_ZKT_ENDPOINT" ]]; then
        echo "ERROR: STABILITY_ZKT_ENDPOINT is not set"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$STABILITY_API_KEY" ]]; then
        echo "WARNING: STABILITY_API_KEY is not set - will use public ZKT endpoint"
        echo "For production use, consider getting an API key from https://portal.stabilityprotocol.com"
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

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_config
fi