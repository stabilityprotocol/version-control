# Stability Blockchain Git Hook Installer for Windows
# PowerShell version for Windows users

param(
    [string]$ApiKey = "",
    [string]$ApiEndpoint = "https://api.stabilitychain.io/codebase/hash",
    [string]$ProjectName = ""
)

# Colors for PowerShell output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Header {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Blue
}

# Check if we're in a Git repository
function Test-GitRepository {
    try {
        git rev-parse --git-dir | Out-Null
        return $true
    }
    catch {
        Write-Error "Not in a git repository. Please run this script from within a git repository."
        return $false
    }
}

# Check required dependencies
function Test-Dependencies {
    $missingDeps = @()
    
    try { git --version | Out-Null } catch { $missingDeps += "git" }
    try { curl --version | Out-Null } catch { $missingDeps += "curl" }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error "Missing required dependencies:"
        foreach ($dep in $missingDeps) {
            Write-Host "  - $dep" -ForegroundColor Red
        }
        Write-Host "Please install Git for Windows which includes these utilities." -ForegroundColor Red
        return $false
    }
    return $true
}

# Create the Git hook
function Install-GitHook {
    $hookPath = ".git\hooks\post-commit"
    
    # Backup existing hook if it exists
    if (Test-Path $hookPath) {
        $backupPath = "$hookPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Warning "Existing post-commit hook found. Backing up to: $backupPath"
        Copy-Item $hookPath $backupPath
    }
    
    # Create the hook content (bash script for Git Bash)
    $hookContent = @"
#!/bin/bash

# Stability Blockchain Git Hook (Windows Version)
set -euo pipefail

# Configuration
CONFIG_DIR="stability-vc/config"
LOG_DIR="stability-vc/logs"
CONFIG_FILE="`$CONFIG_DIR/stability-config.sh"
LOG_FILE="`$LOG_DIR/stability-hook.log"

# Ensure directories exist
mkdir -p "`$LOG_DIR"

# Function to log messages
log() {
    echo "[`$(date '+%Y-%m-%d %H:%M:%S')] `$1" | tee -a "`$LOG_FILE"
}

log_error() {
    echo "[`$(date '+%Y-%m-%d %H:%M:%S')] ERROR: `$1" | tee -a "`$LOG_FILE" >&2
}

# Load configuration
if [[ -f "`$CONFIG_FILE" ]]; then
    source "`$CONFIG_FILE"
    log "Loaded configuration from `$CONFIG_FILE"
else
    log_error "Configuration file not found: `$CONFIG_FILE"
    exit 1
fi

# Validate configuration
if [[ -z "`${STABILITY_API_ENDPOINT:-}" ]]; then
    log_error "STABILITY_API_ENDPOINT not configured"
    exit 1
fi

if [[ -z "`${STABILITY_API_KEY:-}" ]]; then
    log_error "STABILITY_API_KEY not configured"
    exit 1
fi

log "🟢 Starting Stability blockchain commit hook..."

# Generate commit metadata
COMMIT_HASH=`$(git rev-parse HEAD)
AUTHOR=`$(git log -1 --pretty=format:'%an')
AUTHOR_EMAIL=`$(git log -1 --pretty=format:'%ae')
COMMIT_MESSAGE=`$(git log -1 --pretty=format:'%s')
TIMESTAMP=`$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=`$(git rev-parse --abbrev-ref HEAD)

log "Commit Hash: `$COMMIT_HASH"
log "Author: `$AUTHOR <`$AUTHOR_EMAIL>"
log "Branch: `$BRANCH"

# Generate SHA-256 hash of entire codebase
log "🟢 Generating SHA-256 hash of the entire codebase..."

# Use appropriate hash command
if command -v sha256sum >/dev/null 2>&1; then
    CODEBASE_HASH=`$(git archive HEAD | sha256sum | awk '{print `$1}')
elif command -v shasum >/dev/null 2>&1; then
    CODEBASE_HASH=`$(git archive HEAD | shasum -a 256 | awk '{print `$1}')
else
    log_error "No SHA-256 command found"
    exit 1
fi

log "Codebase Hash: `$CODEBASE_HASH"

# Create JSON payload
read -r -d '' PAYLOAD << EOF || true
{
  "commitHash": "`$COMMIT_HASH",
  "codebaseHash": "`$CODEBASE_HASH",
  "timestamp": "`$TIMESTAMP",
  "author": "`$AUTHOR",
  "authorEmail": "`$AUTHOR_EMAIL",
  "branch": "`$BRANCH",
  "message": "`$COMMIT_MESSAGE"
}
EOF

# Submit to Stability Blockchain
log "🟢 Submitting to Stability Blockchain API..."

HTTP_STATUS=`$(curl -s -o "`$LOG_FILE.response" -w "%{http_code}" \
    -X POST "`$STABILITY_API_ENDPOINT" \
    -H "API-Key: `$STABILITY_API_KEY" \
    -H "Content-Type: application/json" \
    -H "User-Agent: Stability-VC-Hook/1.0.0" \
    -d "`$PAYLOAD")

if [[ "`$HTTP_STATUS" -ge 200 && "`$HTTP_STATUS" -lt 300 ]]; then
    log "✅ Successfully submitted to blockchain (HTTP `$HTTP_STATUS)"
    if [[ -f "`$LOG_FILE.response" ]]; then
        RESPONSE=`$(cat "`$LOG_FILE.response")
        log "API Response: `$RESPONSE"
        rm -f "`$LOG_FILE.response"
    fi
else
    log_error "Failed to submit to blockchain (HTTP `$HTTP_STATUS)"
    if [[ -f "`$LOG_FILE.response" ]]; then
        RESPONSE=`$(cat "`$LOG_FILE.response")
        log_error "API Response: `$RESPONSE"
        rm -f "`$LOG_FILE.response"
    fi
fi

log "🟢 Stability blockchain hook completed"
"@

    # Write hook file
    $hookContent | Out-File -FilePath $hookPath -Encoding UTF8
    Write-Status "Git hook installed at: $hookPath"
}

# Create configuration files
function New-Configuration {
    $configDir = "stability-vc\config"
    $logDir = "stability-vc\logs"
    
    # Create directories
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    
    $configPath = "$configDir\stability-config.sh"
    
    # Create configuration file
    $configContent = @"
#!/bin/bash

# Stability Blockchain Configuration (Windows)
export STABILITY_API_ENDPOINT="$ApiEndpoint"
export STABILITY_API_KEY="$ApiKey"
export PROJECT_NAME="$ProjectName"

# Hook Configuration
export ENABLE_VERBOSE_LOGGING="true"
export TIMEOUT_SECONDS="30"
export RETRY_ATTEMPTS="3"

# Validation function
validate_config() {
    if [[ -z "`$STABILITY_API_ENDPOINT" ]]; then
        echo "ERROR: STABILITY_API_ENDPOINT not set"
        return 1
    fi
    
    if [[ -z "`$STABILITY_API_KEY" ]]; then
        echo "ERROR: STABILITY_API_KEY not set"
        return 1
    fi
    
    return 0
}
"@

    $configContent | Out-File -FilePath $configPath -Encoding UTF8
    Write-Status "Configuration created at: $configPath"
    
    return $configPath
}

# Test the installation
function Test-Installation {
    Write-Header "=== Testing Installation ==="
    
    $configPath = "stability-vc\config\stability-config.sh"
    
    if (Test-Path $configPath) {
        Write-Status "Configuration file found"
        
        if ($ApiKey -ne "") {
            Write-Status "API key configured"
        } else {
            Write-Warning "API key not configured - please edit $configPath"
        }
        
        if (Test-Path ".git\hooks\post-commit") {
            Write-Status "Git hook installed successfully"
        } else {
            Write-Error "Git hook installation failed"
            return $false
        }
    } else {
        Write-Error "Configuration file not found"
        return $false
    }
    
    return $true
}

# Main installation process
function Main {
    Write-Header "=== Stability Blockchain Git Hook Installer (Windows) ==="
    Write-Host ""
    
    if (-not (Test-GitRepository)) {
        exit 1
    }
    
    if (-not (Test-Dependencies)) {
        exit 1
    }
    
    # Prompt for API key if not provided
    if ($ApiKey -eq "") {
        Write-Host "Please provide your Stability API configuration:" -ForegroundColor Yellow
        $ApiKey = Read-Host "API Key"
    }
    
    if ($ProjectName -eq "") {
        $ProjectName = Read-Host "Project Name (optional)"
    }
    
    Install-GitHook
    $configPath = New-Configuration
    
    if (Test-Installation) {
        Write-Host ""
        Write-Header "=== Installation Complete ==="
        Write-Status "Stability blockchain git hook has been successfully installed!"
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Make a test commit to verify everything works"
        Write-Host "2. Check logs in: stability-vc\logs\stability-hook.log"
        Write-Host "3. Edit configuration if needed: $configPath"
        Write-Host ""
        Write-Status "Every commit will now be recorded on the Stability blockchain!"
    } else {
        Write-Error "Installation completed with errors. Please check the configuration."
        exit 1
    }
}

# Run the installer
Main