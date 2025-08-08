# Contributing to Stability Blockchain Version Control

Thank you for your interest in contributing to this project! We welcome contributions from the community and are grateful for any help you can provide.

## 🤝 How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Great bug reports include:**

- **Clear description** of the problem
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Git version, bash version)
- **Log files** from `logs/stability-hook.log`
- **Screenshots** if applicable

**Bug Report Template:**

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Environment:**

- OS: [e.g. Windows 11, macOS 12, Ubuntu 20.04]
- Git Version: [e.g. 2.34.1]
- Bash Version: [e.g. Git Bash 4.4.23]
- Project Version: [e.g. v1.0.0]

**Logs**
Please include relevant logs from `logs/stability-hook.log`

**Additional context**
Add any other context about the problem here.
```

### Suggesting Features

We love feature suggestions! Please open an issue with:

- **Clear description** of the feature
- **Use case** - why would this be useful?
- **Implementation ideas** (if you have any)
- **Alternative solutions** you've considered

### Pull Requests

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes
4. **Test** thoroughly (see Testing section below)
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** to the branch (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

#### Pull Request Guidelines

- **Keep PRs focused** - one feature/fix per PR
- **Write clear commit messages** following [Conventional Commits](https://conventionalcommits.org/)
- **Include tests** for new functionality
- **Update documentation** if needed
- **Follow code style** guidelines below

## 🧪 Testing

### Running Tests

```bash
# Quick integration test
bash scripts/quick-test.sh

# Smart contract deployment test (testnet)
bash scripts/deploy-contract.sh deploy testnet

# Full demo workflow
bash scripts/demo-complete.sh

# Manual testing
cd test-repo
bash ../scripts/install-hook.sh
# Make commits and verify blockchain submission
```

### Test Coverage Areas

- **Git hook functionality** - post-commit trigger
- **Blockchain integration** - ZKT API calls
- **Smart contract interaction** - deployment and calls
- **Cross-platform compatibility** - Windows, macOS, Linux
- **Error handling** - network failures, invalid configs
- **Configuration management** - various network/endpoint setups

### Adding Tests

When adding new features, please include:

- **Unit tests** for individual functions
- **Integration tests** for end-to-end workflows
- **Error case testing** for failure scenarios
- **Documentation examples** that work as tests

## 📝 Code Style

### Bash Scripts

```bash
#!/bin/bash

# Use strict error handling
set -euo pipefail

# Function naming: lowercase with underscores
function_name() {
    local param1="$1"
    local param2="${2:-default_value}"

    # Use meaningful variable names
    # Quote variables to prevent word splitting
    echo "Processing: $param1"
}

# Constants: uppercase
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="$SCRIPT_DIR/config.sh"

# Logging with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}
```

### Solidity Contracts

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ContractName
 * @dev Brief description of contract purpose
 */
contract ContractName {
    // State variables
    mapping(string => bool) public commitExists;

    // Events
    event CommitStored(
        string indexed commitHash,
        address indexed submitter,
        uint256 timestamp
    );

    /**
     * @dev Function description
     * @param param1 Description of parameter
     * @return Description of return value
     */
    function functionName(string memory param1)
        external
        returns (bool)
    {
        require(bytes(param1).length > 0, "Parameter required");

        // Function logic
        emit CommitStored(param1, msg.sender, block.timestamp);

        return true;
    }
}
```

### Documentation

- **Comments** for complex logic
- **Function documentation** with parameters and return values
- **README updates** for new features
- **Changelog entries** for all changes
- **API documentation** for new endpoints/functions

## 🗂️ Project Structure

```
stability-version-control/
├── scripts/                # Installation and utility scripts
│   ├── install-hook.sh     # Main installation script
│   ├── deploy-contract.sh  # Smart contract deployment
│   ├── quick-test.sh       # Testing utility
│   └── demo-complete.sh    # Full demonstration
├── hooks/                  # Git hooks
│   └── post-commit         # Main blockchain integration hook
├── config/                 # Configuration files
│   └── stability-config.sh # Main configuration
├── contracts/              # Smart contracts
│   └── CommitRegistry.sol  # Main storage contract
├── docs/                   # Documentation
│   ├── api-reference.md    # API documentation
│   └── zkt-integration.md  # ZKT usage guide
├── examples/               # Usage examples
├── logs/                   # Log files (created at runtime)
├── README.md               # Main documentation
├── CONTRIBUTING.md         # This file
├── LICENSE                 # MIT License
├── CHANGELOG.md            # Version history
└── .gitignore             # Git ignore rules
```

## 🔧 Development Setup

### Initial Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/stability-blockchain-version-control.git
cd stability-blockchain-version-control

# Create feature branch
git checkout -b feature/your-feature-name

# Test setup
bash scripts/quick-test.sh
```

### Development Workflow

1. **Make changes** in appropriate files
2. **Test locally** with `scripts/quick-test.sh`
3. **Test on testnet** if blockchain changes
4. **Update documentation** if needed
5. **Run full demo** to ensure nothing breaks
6. **Commit and push** changes

### Environment Variables

For development, you may need:

```bash
# For testnet development
export STABILITY_NETWORK="testnet"
export STABILITY_ZKT_ENDPOINT="https://rpc.testnet.stabilityprotocol.com/zkt"

# For debugging
export DEBUG=1
export VERBOSE_LOGGING=1
```

## 🛡️ Security

### Security Policy

- **No sensitive data** in commits (API keys, private keys)
- **Validate all inputs** in scripts
- **Use secure defaults** in configuration
- **Test on testnet first** for blockchain changes

### Reporting Security Issues

**Do not** open public issues for security vulnerabilities.

Instead, email: security@[project-domain] with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact assessment
- Suggested fix (if any)

## 📋 Code Review Process

### For Maintainers

- **Review within 48 hours** when possible
- **Test changes** locally before approval
- **Check documentation** updates
- **Verify blockchain functionality** on testnet
- **Ensure backward compatibility**

### Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass and cover new functionality
- [ ] Documentation is updated
- [ ] No security vulnerabilities introduced
- [ ] Backward compatibility maintained
- [ ] Changelog updated
- [ ] Commit messages are clear

## 🏷️ Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backward-compatible functionality
- **PATCH** version for backward-compatible bug fixes

### Release Steps

1. **Update CHANGELOG.md** with new version
2. **Update version** in relevant files
3. **Create release branch** (`release/v1.1.0`)
4. **Test thoroughly** on testnet and mainnet
5. **Create tag** (`git tag v1.1.0`)
6. **Push tag** and create GitHub release
7. **Update documentation** if needed

## 🎯 Areas Looking for Help

We especially welcome contributions in these areas:

- **Testing on different platforms** (various Linux distributions, older macOS)
- **Performance optimization** (faster hashing, efficient API calls)
- **Error handling improvements** (better error messages, recovery mechanisms)
- **Documentation** (tutorials, examples, translations)
- **Integration tools** (IDE plugins, CI/CD workflows)
- **Multi-chain support** (Ethereum, Polygon integration)

## 💬 Getting Help

- **Questions?** Open a [GitHub Discussion](https://github.com/your-username/stability-blockchain-version-control/discussions)
- **Chat:** Join our community channels
- **Documentation:** Check the [docs/](docs/) directory
- **Examples:** Look at [examples/](examples/) directory

## 🙏 Recognition

Contributors will be:

- **Listed** in CONTRIBUTORS.md
- **Mentioned** in release notes
- **Thanked** in our documentation

We appreciate all contributions, no matter how small!

---

**Happy contributing! 🚀**
