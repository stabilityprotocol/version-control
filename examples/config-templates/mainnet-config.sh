#!/bin/bash

# -------------------------------------------
# Stability Blockchain Version Control Configuration
# Template: Production Mainnet Setup
# -------------------------------------------

# Network Configuration (Mainnet)
export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt"
export STABILITY_NETWORK="mainnet"

# Smart Contract Configuration
# IMPORTANT: Deploy your own contract for production use:
# bash scripts/deploy-contract.sh deploy mainnet
export STABILITY_CONTRACT_ADDRESS="0x0000000000000000000000000000000000000000"

# API Configuration
# RECOMMENDED: Use private API key for production
# Get your API key from: https://stability.dev/dashboard
export STABILITY_API_KEY=""  # Set your private API key here

# Project Configuration
export PROJECT_NAME="Production Project"  # Use descriptive, non-sensitive name
export PROJECT_ID=""  # Optional: Your project identifier

# Production Settings
export LOG_LEVEL="INFO"  # Reduce verbosity in production
export TIMEOUT_SECONDS="60"  # Longer timeout for reliability
export RETRY_ATTEMPTS="5"  # More retries for reliability

# Security Notes:
# - Keep this file secure (chmod 600)
# - Never commit API keys to version control
# - Use environment variables in CI/CD: export STABILITY_API_KEY="$STABILITY_KEY"
# - Deploy private contracts for sensitive projects
# - Monitor logs regularly: tail -f logs/stability-hook.log

# Example Production Setup:
# 1. Deploy contract: bash scripts/deploy-contract.sh deploy mainnet
# 2. Copy and secure config: cp examples/config-templates/mainnet-config.sh config/stability-config.sh && chmod 600 config/stability-config.sh
# 3. Set API key: export STABILITY_API_KEY="your-key-here"
# 4. Install hook: bash scripts/install-hook.sh
# 5. Verify setup: bash scripts/quick-test.sh
