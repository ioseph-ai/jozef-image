#!/bin/bash
set -e

echo "=== Extended integration tests ==="

# These tests run in CI after the image is built
# They require Docker to be available

if ! command -v docker &> /dev/null; then
    echo "SKIP: Docker not available"
    exit 0
fi

IMAGE_TAG=${1:-"jozef-image:test"}

echo "Testing image: $IMAGE_TAG"

# Test 1: Image exists
echo "Test 1: Checking if image exists..."
if ! docker image inspect "$IMAGE_TAG" &> /dev/null; then
    echo "FAIL: Image $IMAGE_TAG not found"
    exit 1
fi
echo "PASS: Image exists"

# Test 2: Check OpenClaw version
echo "Test 2: Checking OpenClaw version..."
OPENCLAW_VERSION=$(docker run --rm "$IMAGE_TAG" node openclaw.mjs --version 2>&1 || true)
if echo "$OPENCLAW_VERSION" | grep -q "OpenClaw"; then
    echo "  OpenClaw: $OPENCLAW_VERSION"
    echo "PASS: OpenClaw responds"
else
    echo "FAIL: OpenClaw not responding"
    exit 1
fi

# Test 3: Check required tools in container
echo "Test 3: Checking tools in container..."
docker run --rm "$IMAGE_TAG" bash -c "
    node --version
    python3 --version
    pip3 --version | head -1
    vim --version | head -1
    git --version
    curl --version | head -1
    ssh -V 2>&1
" > /dev/null 2>&1 && echo "PASS: All tools available" || {
    echo "FAIL: Some tools missing"
    exit 1
}

# Test 4: Check workspace directory exists
echo "Test 4: Checking workspace directory..."
docker run --rm "$IMAGE_TAG" test -d /home/node/.openclaw/workspace && echo "PASS: Workspace exists" || {
    echo "FAIL: Workspace directory missing"
    exit 1
}

# Test 5: Check user is node (not root)
echo "Test 5: Checking user..."
USER=$(docker run --rm "$IMAGE_TAG" whoami)
if [ "$USER" = "node" ]; then
    echo "PASS: Running as node user"
else
    echo "FAIL: Running as $USER (expected node)"
    exit 1
fi

echo ""
echo "=== All integration tests passed ==="
