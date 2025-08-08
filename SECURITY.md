# Security Policy

## 🛡️ Security Overview

The Stability Blockchain Version Control system is designed with security as a foundational principle. This document outlines our security practices, known considerations, and how to report security issues.

## 🔒 Security Model

### What We Store on Blockchain

**✅ Safe Data (Stored on Blockchain):**

- Git commit hashes (SHA-1)
- Repository content hashes (SHA-256)
- Author names and email addresses
- Commit timestamps
- Branch names
- Commit messages
- Project names

**❌ Never Stored:**

- Source code content
- File contents
- Directory structures
- Sensitive configuration data
- API keys or credentials
- Personal identification beyond Git metadata

### Cryptographic Security

- **SHA-256 Hashing**: All repository content is hashed using SHA-256 for integrity verification
- **Immutable Records**: Blockchain storage ensures tamper-proof historical records
- **Transaction Signing**: All blockchain transactions are cryptographically signed
- **Zero Gas Architecture**: Stability's ZKT prevents MEV attacks and gas manipulation

## 🚨 Supported Versions

| Version | Supported  | Security Updates |
| ------- | ---------- | ---------------- |
| 1.0.x   | ✅ Yes     | ✅ Active        |
| 0.9.x   | ⚠️ Limited | 🔄 Critical Only |
| < 0.9   | ❌ No      | ❌ None          |

## 🔐 Security Best Practices

### For Users

#### API Key Management

```bash
# ✅ Good: Use environment variables
export STABILITY_API_KEY="your-key-here"

# ❌ Bad: Hardcode in scripts
STABILITY_API_KEY="your-key-here"  # Never do this
```

#### Configuration Security

```bash
# ✅ Good: Secure permissions
chmod 600 config/stability-config.sh

# ✅ Good: Use private endpoints for sensitive projects
export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt/$STABILITY_API_KEY"

# ✅ Good: Deploy private contracts for confidential work
bash scripts/deploy-contract.sh deploy mainnet
```

#### Repository Security

```bash
# ✅ Good: Regular verification
bash scripts/verify-commits.sh

# ✅ Good: Monitor blockchain logs
tail -f logs/stability-hook.log

# ✅ Good: Use .gitignore for sensitive files
echo "*.key" >> .gitignore
echo "secrets/" >> .gitignore
```

### For Developers

#### Input Validation

```bash
# Always validate inputs
validate_commit_hash() {
    local hash="$1"
    if [[ ! "$hash" =~ ^[a-f0-9]{40}$ ]]; then
        log_error "Invalid commit hash format"
        return 1
    fi
}
```

#### Secure Defaults

```bash
# Use secure defaults
STABILITY_ZKT_ENDPOINT="${STABILITY_ZKT_ENDPOINT:-https://rpc.stabilityprotocol.com/zkt}"
USE_PUBLIC_ENDPOINT="${USE_PUBLIC_ENDPOINT:-true}"
```

#### Error Handling

```bash
# Don't expose sensitive data in errors
if ! curl -s "$api_endpoint"; then
    log_error "API request failed"  # ✅ Good
    # log_error "Failed: $api_key"  # ❌ Bad
fi
```

## 🔍 Security Considerations

### Data Privacy

**Public Blockchain Storage:**

- All commit metadata is permanently public on Stability blockchain
- Author information becomes part of public record
- Consider pseudonymous Git configurations for privacy-sensitive projects

**Network Communication:**

- All API calls use HTTPS encryption
- Public endpoints may log request metadata
- Private endpoints provide additional security layers

### Access Control

**Git Hook Security:**

- Hooks execute with user's Git permissions
- No elevation of privileges required
- Isolated from system-critical operations

**Smart Contract Security:**

- Immutable once deployed (by design)
- No admin functions or backdoors
- Open source and auditable

### Threat Model

**Mitigated Threats:**

- ✅ **Commit History Tampering**: Blockchain immutability prevents alteration
- ✅ **Data Integrity**: SHA-256 hashing detects any content changes
- ✅ **Replay Attacks**: Unique commit hashes prevent duplication
- ✅ **Man-in-the-Middle**: HTTPS encryption protects API communication

**Remaining Considerations:**

- ⚠️ **API Key Exposure**: Secure storage of private API keys required
- ⚠️ **Public Data**: All metadata becomes permanently public
- ⚠️ **Network Dependency**: Requires internet connectivity for blockchain submission

## 🚨 Reporting Security Vulnerabilities

### Do NOT:

- Open public GitHub issues for security problems
- Discuss vulnerabilities in public forums
- Attempt to exploit vulnerabilities on mainnet

### Do:

1. **Email us immediately** at: `security@[project-domain]`
2. **Include detailed information:**

   - Vulnerability description
   - Steps to reproduce
   - Potential impact assessment
   - Affected versions
   - Suggested remediation (if any)

3. **Wait for our response** before public disclosure

### Response Timeline

| Timeframe | Action                          |
| --------- | ------------------------------- |
| 24 hours  | Initial acknowledgment          |
| 72 hours  | Preliminary assessment          |
| 7 days    | Detailed analysis and fix plan  |
| 30 days   | Public disclosure (coordinated) |

### Responsible Disclosure

We follow coordinated disclosure principles:

- Work with reporters to understand and fix issues
- Provide credit to security researchers (unless requested otherwise)
- Coordinate public disclosure timing
- Release patches before public disclosure

## 🛠️ Security Testing

### Automated Security Checks

```bash
# Run security linting
shellcheck scripts/*.sh

# Check for sensitive data leaks
git secrets --scan

# Verify configuration security
bash scripts/security-check.sh
```

### Manual Security Review

Regular security practices include:

- **Code review** for all changes touching security-sensitive areas
- **Dependency auditing** for any external tools or libraries
- **Penetration testing** of API integrations
- **Smart contract auditing** before mainnet deployment

## 🔧 Security Configuration

### Hardening Checklist

- [ ] **API keys stored securely** (environment variables, not files)
- [ ] **Configuration files have restricted permissions** (`chmod 600`)
- [ ] **Log files don't contain sensitive data**
- [ ] **Git hooks are properly secured** (`chmod +x` only)
- [ ] **Network endpoints use HTTPS**
- [ ] **Error messages don't leak sensitive information**

### Production Security

```bash
# Production configuration template
export STABILITY_NETWORK="mainnet"
export STABILITY_ZKT_ENDPOINT="https://rpc.stabilityprotocol.com/zkt"
export STABILITY_API_KEY=""  # Use your private key for production
export PROJECT_NAME="Production Project"  # Use descriptive, non-sensitive name

# Additional security settings
export LOG_LEVEL="INFO"  # Reduce verbose logging in production
export TIMEOUT_SECONDS="30"  # Set reasonable API timeouts
export RETRY_ATTEMPTS="3"  # Limited retry attempts
```

## 📊 Security Monitoring

### What to Monitor

- **Unusual API activity** in logs
- **Failed blockchain submissions** patterns
- **Git hook execution errors**
- **Unexpected file modifications**

### Log Analysis

```bash
# Monitor for security events
grep -i "error\|fail\|warn" logs/stability-hook.log

# Check for unusual patterns
awk '/ERROR/ {print $0}' logs/stability-hook.log | sort | uniq -c

# Monitor API response codes
grep "HTTP" logs/stability-hook.log | awk '{print $NF}' | sort | uniq -c
```

## 🆘 Incident Response

### If Security Issue Detected

1. **Immediately** stop using affected systems
2. **Document** the issue with screenshots/logs
3. **Report** following our vulnerability reporting process
4. **Preserve** evidence for analysis
5. **Wait** for guidance before resuming operations

### Recovery Procedures

- **API Key Compromise**: Immediately revoke and regenerate keys
- **Configuration Exposure**: Update all affected configurations
- **System Compromise**: Reinstall from clean sources

## 🔗 Security Resources

### External Security Information

- **Stability Protocol Security**: [https://docs.stble.io/security](https://docs.stble.io/security)
- **Git Security Best Practices**: [https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- **OWASP Secure Coding Practices**: [https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)

### Security Tools

- **ShellCheck**: Static analysis for bash scripts
- **git-secrets**: Prevent committing secrets
- **Gitleaks**: Detect and prevent secrets in git repos

## 📝 Security Updates

Security updates are released as needed and announced through:

- GitHub Security Advisories
- Release notes with [SECURITY] tags
- Email notifications to users (if registered)

---

**Remember: Security is a shared responsibility. Please report any concerns promptly.**
