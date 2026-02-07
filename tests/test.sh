#!/bin/bash
set -e

echo "=== Running tests ==="

# Test 1: Dockerfile syntax check
echo "Test 1: Checking Dockerfile exists..."
if [ ! -f Dockerfile ]; then
    echo "FAIL: Dockerfile not found"
    exit 1
fi
echo "PASS: Dockerfile exists"

# Test 2: Check required tools are mentioned in Dockerfile
echo "Test 2: Checking required tools in Dockerfile..."
for tool in vim python3 pip node curl git ssh; do
    if grep -iq "$tool" Dockerfile; then
        echo "  FOUND: $tool"
    else
        echo "  WARNING: $tool not explicitly mentioned"
    fi
done
echo "PASS: Tool check complete"

# Test 3: Workflow file validation
echo "Test 3: Checking GitHub Actions workflow..."
if [ ! -f .github/workflows/ci.yml ]; then
    echo "FAIL: CI workflow not found"
    exit 1
fi
if ! grep -q "docker/build-push-action" .github/workflows/ci.yml; then
    echo "FAIL: Missing docker build-push action"
    exit 1
fi
if ! grep -q "ghcr.io" .github/workflows/ci.yml; then
    echo "FAIL: GHCR registry not configured"
    exit 1
fi
echo "PASS: Workflow file OK"

# Test 4: YAML syntax check (basic)
echo "Test 4: YAML syntax check..."
if grep -q $'\t' .github/workflows/ci.yml; then
    echo "FAIL: Workflow contains tabs (YAML requires spaces)"
    exit 1
fi
echo "PASS: YAML syntax OK"

# Test 5: Check Dockerfile has multi-stage build
echo "Test 5: Checking multi-stage build..."
if ! grep -q "AS builder" Dockerfile; then
    echo "FAIL: No multi-stage build (AS builder) found"
    exit 1
fi
if ! grep -q "COPY --from=builder" Dockerfile; then
    echo "FAIL: No COPY --from=builder found"
    exit 1
fi
echo "PASS: Multi-stage build configured"

# Test 6: Check OpenClaw is installed
echo "Test 6: Checking OpenClaw installation..."
if ! grep -q "openclaw.mjs" Dockerfile; then
    echo "FAIL: openclaw.mjs not referenced in Dockerfile"
    exit 1
fi
if ! grep -q "openclaw/openclaw" Dockerfile; then
    echo "FAIL: OpenClaw repo not cloned in Dockerfile"
    exit 1
fi
echo "PASS: OpenClaw installation configured"

# Test 7: Check for security best practices
echo "Test 7: Checking security best practices..."
if ! grep -q "USER node" Dockerfile; then
    echo "WARNING: No USER node found (running as root)"
fi
if ! grep -q "apt-get clean" Dockerfile; then
    echo "WARNING: No apt-get clean found"
fi
echo "PASS: Security check complete"

echo ""
echo "=== All tests passed ==="
