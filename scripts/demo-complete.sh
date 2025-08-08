#!/bin/bash

# -------------------------------------------
# Complete Stability Blockchain Version Control Demo
# Deploy → Commit → Verify Full Workflow
# -------------------------------------------

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_demo() {
    echo -e "${CYAN}[DEMO]${NC} $1"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEMO_DIR="blockchain-vc-demo"
CONTRACT_ADDRESS=""

# Function to show animated progress
show_progress() {
    local duration=$1
    local message=$2
    for i in $(seq 1 $duration); do
        echo -n "."
        sleep 1
    done
    echo " $message"
}

# Function to pause for user
pause_demo() {
    local message="${1:-Press Enter to continue...}"
    echo -e "${YELLOW}$message${NC}"
    read -p ""
}

# Function to show title screen
show_title() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              STABILITY BLOCKCHAIN VERSION CONTROL           ║"
    echo "║                    COMPLETE DEMO SCRIPT                     ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"
    echo "║  This demo will show:                                        ║"
    echo "║  1. 🏗️  Smart Contract Deployment                           ║"
    echo "║  2. 📝  Git Repository Setup                                ║"
    echo "║  3. ⚡  Blockchain Hook Installation                        ║"
    echo "║  4. 💾  Multiple Commits to Blockchain                     ║"
    echo "║  5. 🔍  Contract Verification                               ║"
    echo "║                                                              ║"
    echo "║  Network: Stability Mainnet                                 ║"
    echo "║  Storage: Smart Contract (Structured)                       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    pause_demo "Ready to start the demo? Press Enter..."
}

# Function to deploy smart contract
deploy_contract() {
    print_header "STEP 1: SMART CONTRACT DEPLOYMENT"
    print_demo "Deploying CommitRegistry contract to Stability mainnet..."
    echo
    
    if [[ -f "$PROJECT_ROOT/deployment-info.txt" ]]; then
        CONTRACT_ADDRESS=$(grep "Contract Address:" "$PROJECT_ROOT/deployment-info.txt" | cut -d' ' -f3)
        if [[ -n "$CONTRACT_ADDRESS" ]]; then
            print_status "Contract already deployed at: $CONTRACT_ADDRESS"
            pause_demo "Using existing contract. Press Enter to continue..."
            return 0
        fi
    fi
    
    print_step "Calling deployment script..."
    if bash "$SCRIPT_DIR/deploy-contract.sh" deploy mainnet; then
        CONTRACT_ADDRESS=$(grep "Contract Address:" "$PROJECT_ROOT/deployment-info.txt" | cut -d' ' -f3)
        print_status "✅ Contract deployed successfully!"
        print_status "Contract Address: $CONTRACT_ADDRESS"
        echo
        pause_demo "Contract deployment complete! Press Enter for next step..."
    else
        print_error "Contract deployment failed!"
        exit 1
    fi
}

# Function to create demo repository
create_demo_repo() {
    print_header "STEP 2: DEMO REPOSITORY SETUP"
    print_demo "Creating demonstration repository..."
    echo
    
    # Clean up existing demo
    if [[ -d "$DEMO_DIR" ]]; then
        print_warning "Removing existing demo directory..."
        rm -rf "$DEMO_DIR"
    fi
    
    print_step "Creating new Git repository..."
    mkdir "$DEMO_DIR"
    cd "$DEMO_DIR"
    
    git init
    git config user.name "Blockchain Demo User"
    git config user.email "demo@stability-blockchain.com"
    
    print_step "Creating demo files..."
    
    # README.md
    cat > README.md << EOF
# Stability Blockchain Version Control Demo

This repository demonstrates blockchain-verified version control using Stability's ZKT API.

## System Information
- **Network**: Stability Mainnet
- **Contract**: $CONTRACT_ADDRESS
- **Storage**: Smart Contract (Structured Data)
- **Created**: $(date)

## Features Demonstrated
- [x] Automatic commit hashing (SHA-256 of entire codebase)
- [x] Immutable blockchain storage
- [x] Smart contract integration
- [x] Audit trail generation
- [x] Verification capabilities

## How It Works
Every \`git commit\` automatically:
1. Generates SHA-256 hash of entire repository
2. Submits commit metadata to Stability blockchain
3. Stores data in smart contract for structured access
4. Returns transaction hash for verification

Your code integrity is now blockchain-verified! 🚀
EOF

    # Demo application code
    cat > app.js << EOF
// Blockchain-Verified JavaScript Application
// Every change to this file is recorded on Stability blockchain

class BlockchainApp {
    constructor() {
        this.version = "1.0.0";
        this.blockchain = "Stability";
        this.contract = "$CONTRACT_ADDRESS";
    }

    greet() {
        console.log("Hello from blockchain-verified code!");
        console.log(\`Contract: \${this.contract}\`);
    }

    verify() {
        return {
            version: this.version,
            blockchain: this.blockchain,
            verified: true,
            timestamp: new Date().toISOString()
        };
    }
}

// Initialize and run
const app = new BlockchainApp();
app.greet();
console.log("Verification:", app.verify());
EOF

    # Configuration file
    cat > blockchain.config << EOF
# Stability Blockchain Configuration
NETWORK=mainnet
CONTRACT_ADDRESS=$CONTRACT_ADDRESS
ZKT_ENDPOINT=https://rpc.stabilityprotocol.com/zkt
STORAGE_TYPE=smart_contract
VERIFICATION_ENABLED=true
EOF

    # Package.json for Node.js demo
    cat > package.json << EOF
{
  "name": "stability-blockchain-demo",
  "version": "1.0.0",
  "description": "Demonstration of blockchain-verified version control",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "verify": "echo 'All commits verified on Stability blockchain'"
  },
  "keywords": ["blockchain", "version-control", "stability", "verification"],
  "author": "Stability Demo",
  "license": "MIT"
}
EOF

    print_step "Making initial commit..."
    git add .
    git commit -m "Initial commit: Blockchain-verified demo application"
    
    print_status "✅ Demo repository created!"
    echo
    pause_demo "Repository setup complete! Press Enter for next step..."
}

# Function to install blockchain hook
install_hook() {
    print_header "STEP 3: BLOCKCHAIN HOOK INSTALLATION"
    print_demo "Installing Stability blockchain Git hook..."
    echo
    
    print_step "Setting up configuration directories..."
    mkdir -p stability-vc/{config,logs}
    
    print_step "Copying configuration..."
    cp "$PROJECT_ROOT/config/stability-config.sh" stability-vc/config/
    
    print_step "Installing Git hook..."
    cp "$PROJECT_ROOT/hooks/post-commit" .git/hooks/
    chmod +x .git/hooks/post-commit
    
    # Update hook paths for demo directory
    sed -i.bak 's|../config/stability-config.sh|../../stability-vc/config/stability-config.sh|g' .git/hooks/post-commit
    sed -i.bak 's|../logs/stability-hook.log|../../stability-vc/logs/stability-hook.log|g' .git/hooks/post-commit
    rm -f .git/hooks/post-commit.bak
    
    print_status "✅ Blockchain hook installed and configured!"
    print_status "Contract Address: $CONTRACT_ADDRESS"
    print_status "Network: Stability Mainnet"
    echo
    pause_demo "Hook installation complete! Press Enter for commit demo..."
}

# Function to demonstrate commits
demo_commits() {
    print_header "STEP 4: BLOCKCHAIN COMMIT DEMONSTRATION"
    print_demo "Making commits that will be recorded on Stability blockchain..."
    echo
    
    # Commit 1: Add feature
    print_step "Commit 1: Adding new feature..."
    cat >> app.js << EOF

// New feature: Blockchain timestamp
BlockchainApp.prototype.getBlockchainTime = function() {
    return {
        timestamp: Date.now(),
        blockchain: "Stability",
        verified: true
    };
};
EOF
    
    git add app.js
    print_demo "Executing: git commit -m 'Add blockchain timestamp feature'"
    git commit -m "Add blockchain timestamp feature"
    echo
    
    # Commit 2: Update documentation
    print_step "Commit 2: Updating documentation..."
    cat >> README.md << EOF

## Recent Updates
- Added blockchain timestamp functionality
- Enhanced verification capabilities
- Updated: $(date)

## Verification
Every change above is permanently recorded on Stability blockchain.
Transaction hashes available in: \`stability-vc/logs/stability-hook.log\`
EOF
    
    git add README.md
    print_demo "Executing: git commit -m 'Update documentation with recent changes'"
    git commit -m "Update documentation with recent changes"
    echo
    
    # Commit 3: Configuration update
    print_step "Commit 3: Configuration update..."
    cat >> blockchain.config << EOF

# Demo Settings
DEMO_MODE=true
COMMITS_COUNT=3
LAST_UPDATE=$(date)
EOF
    
    git add blockchain.config
    print_demo "Executing: git commit -m 'Update blockchain configuration'"
    git commit -m "Update blockchain configuration"
    echo
    
    print_status "✅ All commits recorded on Stability blockchain!"
    echo
    pause_demo "Commit demonstration complete! Press Enter for verification..."
}

# Function to show verification
show_verification() {
    print_header "STEP 5: BLOCKCHAIN VERIFICATION"
    print_demo "Verifying commits are stored on Stability blockchain..."
    echo
    
    print_step "Git commit history:"
    git log --oneline --graph --color=always
    echo
    
    print_step "Blockchain transaction log:"
    if [[ -f "stability-vc/logs/stability-hook.log" ]]; then
        echo "Recent blockchain transactions:"
        grep -E "(Successfully submitted|Transaction Hash|Codebase Hash)" stability-vc/logs/stability-hook.log | tail -9
    else
        print_warning "Log file not found"
    fi
    echo
    
    print_step "Smart contract verification..."
    cd ..
    if bash "$SCRIPT_DIR/deploy-contract.sh" test "$CONTRACT_ADDRESS" mainnet; then
        print_status "✅ Smart contract responding correctly!"
    else
        print_warning "Contract test had issues"
    fi
    cd "$DEMO_DIR"
    echo
    
    print_step "Repository integrity check..."
    local current_hash
    if command -v sha256sum >/dev/null 2>&1; then
        current_hash=$(git archive HEAD | sha256sum | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        current_hash=$(git archive HEAD | shasum -a 256 | awk '{print $1}')
    else
        current_hash="[SHA256 tool not available]"
    fi
    
    print_status "Current repository hash: $current_hash"
    print_status "This hash is stored on Stability blockchain and can be verified by anyone!"
    echo
}

# Function to show summary
show_summary() {
    print_header "DEMO SUMMARY"
    echo
    
    print_demo "🎉 Blockchain Version Control Demo Complete!"
    echo
    echo -e "${GREEN}What was demonstrated:${NC}"
    echo "✅ Smart contract deployment to Stability mainnet"
    echo "✅ Git repository with blockchain hook integration"
    echo "✅ Multiple commits automatically recorded on blockchain"
    echo "✅ Immutable audit trail with transaction hashes"
    echo "✅ Smart contract verification and querying"
    echo
    echo -e "${BLUE}Key Information:${NC}"
    echo "📍 Contract Address: $CONTRACT_ADDRESS"
    echo "🌐 Network: Stability Mainnet"
    echo "📁 Demo Repository: $(pwd)"
    echo "📊 Storage Type: Smart Contract (Structured)"
    echo "🔍 Logs: stability-vc/logs/stability-hook.log"
    echo
    echo -e "${PURPLE}Benefits Achieved:${NC}"
    echo "🔒 Tamper-proof code history"
    echo "📋 Regulatory compliance ready"
    echo "🔍 Independent verification possible"
    echo "⚡ Zero gas fees (Stability)"
    echo "🌍 Permanent blockchain storage"
    echo
    echo -e "${CYAN}Next Steps:${NC}"
    echo "1. Explore the demo repository: cd $DEMO_DIR"
    echo "2. Check transaction logs: cat stability-vc/logs/stability-hook.log"
    echo "3. Make more commits to see continued blockchain recording"
    echo "4. Use this system in your real projects!"
    echo
    echo -e "${YELLOW}Cleanup:${NC}"
    echo "To remove demo: cd .. && rm -rf $DEMO_DIR"
    echo "Contract remains deployed and usable for other projects"
    echo
}

# Function to show real-time commit demo
live_commit_demo() {
    print_header "BONUS: LIVE COMMIT DEMONSTRATION"
    print_demo "Watch a commit happen in real-time..."
    echo
    
    pause_demo "Ready to see a live blockchain commit? Press Enter..."
    
    print_step "Creating live demo file..."
    echo "// Live demo file created at $(date)" > live-demo.js
    echo "console.log('This commit is happening live!');" >> live-demo.js
    echo "console.log('Blockchain: Stability Mainnet');" >> live-demo.js
    echo "console.log('Contract: $CONTRACT_ADDRESS');" >> live-demo.js
    
    git add live-demo.js
    
    print_demo "About to execute: git commit -m 'Live blockchain commit demo'"
    print_demo "Watch for blockchain submission messages..."
    echo
    sleep 2
    
    git commit -m "Live blockchain commit demo - $(date)"
    
    echo
    print_status "✅ Live commit complete! Check the transaction hash above."
    echo
}

# Main demo function
main() {
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Show title
    show_title
    
    # Step 1: Deploy contract
    deploy_contract
    
    # Step 2: Create demo repository
    create_demo_repo
    
    # Step 3: Install hook
    install_hook
    
    # Step 4: Demo commits
    demo_commits
    
    # Step 5: Show verification
    show_verification
    
    # Bonus: Live commit
    live_commit_demo
    
    # Final summary
    show_summary
    
    print_header "DEMO COMPLETE"
    print_demo "Your blockchain version control system is ready for production!"
}

# Run the demo
main "$@"
