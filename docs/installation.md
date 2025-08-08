# Installation Guide

This guide walks you through installing the Stability Blockchain Git Hook in your repository.

## Prerequisites

### Required Software

- **Git** (version 2.0 or higher)
- **curl** (for API communication)
- **SHA-256 utility**:
  - Linux: `sha256sum` (usually pre-installed)
  - macOS: `shasum` (pre-installed) or `gsha256sum` (via `brew install coreutils`)
  - Windows: Use Git Bash which includes these utilities

### Stability API Access

- Stability blockchain API endpoint
- Valid API key with write permissions

## Quick Installation

### Automatic Installation (Recommended)

1. Clone or download this repository
2. Navigate to your project directory
3. Run the installer:

```bash
# From your project root directory
bash /path/to/stability-version-control/scripts/install-hook.sh
```

The installer will:

- Check dependencies
- Backup any existing post-commit hook
- Install the Stability blockchain hook
- Set up configuration files
- Prompt for API credentials

### Manual Installation

If you prefer manual installation or need to customize the setup:

#### Step 1: Copy Hook File

```bash
# Copy the hook to your repository
cp stability-version-control/hooks/post-commit .git/hooks/
chmod +x .git/hooks/post-commit
```

#### Step 2: Set Up Configuration

```bash
# Create configuration directory
mkdir -p stability-vc/config
mkdir -p stability-vc/logs

# Copy configuration template
cp stability-version-control/config/stability-config.sh stability-vc/config/
```

#### Step 3: Configure API Settings

Edit `stability-vc/config/stability-config.sh`:

```bash
export STABILITY_API_ENDPOINT="https://api.stabilitychain.io/codebase/hash"
export STABILITY_API_KEY="your-api-key-here"
export PROJECT_NAME="Your Project Name"
```

## Configuration

### API Configuration

The main configuration is in `stability-vc/config/stability-config.sh`:

| Variable                 | Description                  | Required |
| ------------------------ | ---------------------------- | -------- |
| `STABILITY_API_ENDPOINT` | Stability blockchain API URL | Yes      |
| `STABILITY_API_KEY`      | Your API key                 | Yes      |
| `PROJECT_NAME`           | Project identifier           | No       |
| `PROJECT_ID`             | Project ID for Stability     | No       |

### Advanced Configuration

| Variable                   | Description              | Default |
| -------------------------- | ------------------------ | ------- |
| `ENABLE_VERBOSE_LOGGING`   | Enable detailed logging  | `true`  |
| `ENABLE_HASH_VERIFICATION` | Enable hash verification | `true`  |
| `TIMEOUT_SECONDS`          | API request timeout      | `30`    |
| `RETRY_ATTEMPTS`           | Number of retry attempts | `3`     |
| `RETRY_DELAY_SECONDS`      | Delay between retries    | `2`     |

## Testing the Installation

### Using the Test Script

```bash
bash stability-version-control/scripts/test-hook.sh
```

This will:

- Create a test repository
- Install the hook
- Make test commits
- Validate hash generation
- Test API connectivity

### Manual Testing

1. Make a test commit in your repository:

```bash
echo "Test file" > test.txt
git add test.txt
git commit -m "Test commit for Stability blockchain"
```

2. Check the log file:

```bash
cat stability-vc/logs/stability-hook.log
```

3. Verify the commit was recorded to the blockchain via API

## Platform-Specific Notes

### Windows

- Use Git Bash for the best compatibility
- Ensure Git Bash is in your PATH
- The hook will work with PowerShell commits

### macOS

- Install `coreutils` for consistent SHA-256 hashing:

```bash
brew install coreutils
```

### Linux

- Should work out of the box with most distributions
- Ensure `curl` and `sha256sum` are installed

## Troubleshooting

### Common Issues

**Hook not executing:**

- Check if `.git/hooks/post-commit` is executable
- Verify you're in a Git repository
- Check for syntax errors in the hook script

**API errors:**

- Verify your API key is correct
- Check network connectivity
- Confirm API endpoint URL
- Review logs in `stability-vc/logs/stability-hook.log`

**Hash generation errors:**

- Ensure SHA-256 utility is available
- Check file permissions
- Verify Git repository integrity

### Log Files

Check these locations for debugging:

- `stability-vc/logs/stability-hook.log` - Main hook log
- `.git/hooks/post-commit` - Hook script itself

### Getting Help

1. Check the log files first
2. Verify configuration settings
3. Test with the provided test script
4. Review API documentation

## Security Considerations

### API Key Security

- Never commit API keys to version control
- Use environment variables for sensitive data
- Restrict API key permissions to minimum required
- Rotate API keys regularly

### Network Security

- Use HTTPS endpoints only
- Validate SSL certificates
- Consider network timeouts and retries
- Monitor API usage for anomalies

## Uninstallation

To remove the Stability blockchain hook:

1. Remove the Git hook:

```bash
rm .git/hooks/post-commit
```

2. Remove configuration (optional):

```bash
rm -rf stability-vc/
```

3. Restore backup if it exists:

```bash
# If you have a backup from installation
cp .git/hooks/post-commit.backup.* .git/hooks/post-commit
```

The blockchain records will remain immutable even after uninstalling the hook.
