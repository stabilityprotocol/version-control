#!/bin/bash

# -------------------------------------------
# Stability Blockchain Version Control Configuration
# Template: Testnet Development Setup
# -------------------------------------------

# Network Configuration (Testnet)
export STABILITY_ZKT_ENDPOINT="https://rpc.testnet.stabilityprotocol.com/zkt"
export STABILITY_NETWORK="testnet"

# Smart Contract Configuration
# Deploy your own contract for testing:
# bash scripts/deploy-contract.sh deploy testnet
export STABILITY_CONTRACT_ADDRESS="0x0000000000000000000000000000000000000000"

# API Configuration (Optional)
# Get your API key from: https://stability.dev/dashboard
export STABILITY_API_KEY=""  # Leave empty for public endpoint

# Project Configuration
export PROJECT_NAME="My Test Project"
export PROJECT_ID=""

# Development Settings
export LOG_LEVEL="DEBUG"
export TIMEOUT_SECONDS="30"
export RETRY_ATTEMPTS="3"

# Example Usage:
# 1. Copy this file to your project: cp examples/config-templates/testnet-config.sh config/stability-config.sh
# 2. Edit values above for your project
# 3. Install the Git hook: bash scripts/install-hook.sh
# 4. Start committing: git commit -m "Blockchain-verified commit"
