#!/bin/bash

# Restaurant Menu Admin API - OCI Deployment
# Script 1: Verify Prerequisites
# This script checks all prerequisites before deployment

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../configs"
DOCS_DIR="$SCRIPT_DIR/../docs"
ENV_FILE="$PROJECT_ROOT/.env"

# Function to load environment variables from .env file
load_env_file() {
    if [ -f "$ENV_FILE" ]; then
        echo -e "${GREEN}✓ Loading environment variables from .env file${NC}"
        set -a  # Automatically export all variables
        source "$ENV_FILE"
        set +a
        return 0
    else
        echo -e "${YELLOW}⚠ .env file not found at: $ENV_FILE${NC}"
        echo -e "${YELLOW}  Environment variables must be set manually${NC}"
        return 1
    fi
}

# Load environment variables
load_env_file || true  # Don't fail if .env doesn't exist

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Restaurant Menu Admin API${NC}"
echo -e "${BLUE}OCI Deployment - Prerequisites Check${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Track overall status
ALL_CHECKS_PASSED=true

# Function to print status
print_status() {
    local status=$1
    local message=$2

    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}✗${NC} $message"
        ALL_CHECKS_PASSED=false
    else
        echo -e "${BLUE}ℹ${NC} $message"
    fi
}

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check file exists
file_exists() {
    [ -f "$1" ]
}

echo -e "${BLUE}[1/7] Checking OCI CLI Installation${NC}"
echo "-----------------------------------"
if command_exists oci; then
    OCI_VERSION=$(oci --version 2>&1 | head -n1)
    print_status "success" "OCI CLI installed: $OCI_VERSION"

    # Check OCI configuration
    if [ -f "$HOME/.oci/config" ]; then
        print_status "success" "OCI config file exists: $HOME/.oci/config"
    else
        print_status "error" "OCI config not found. Run: oci setup config"
    fi
else
    print_status "error" "OCI CLI not installed. Install from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
fi
echo ""

echo -e "${BLUE}[2/7] Checking Git Installation${NC}"
echo "--------------------------------"
if command_exists git; then
    GIT_VERSION=$(git --version)
    print_status "success" "$GIT_VERSION"
else
    print_status "error" "Git not installed"
fi
echo ""

echo -e "${BLUE}[3/7] Checking SSH Key${NC}"
echo "-----------------------"
if [ -f "$HOME/.ssh/id_rsa.pub" ] || [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
    else
        SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
    fi
    print_status "success" "SSH public key found: $SSH_KEY_PATH"
    print_status "info" "Key fingerprint: $(ssh-keygen -lf $SSH_KEY_PATH | awk '{print $2}')"
else
    print_status "error" "SSH key not found. Generate with: ssh-keygen -t ed25519"
fi
echo ""

echo -e "${BLUE}[4/7] Checking GitHub Access${NC}"
echo "----------------------------"
if [ -n "${GITHUB_TOKEN:-}" ]; then
    print_status "success" "GITHUB_TOKEN environment variable is set"

    # Test GitHub API access
    if command_exists curl; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: token $GITHUB_TOKEN" \
            https://api.github.com/user)

        if [ "$HTTP_CODE" = "200" ]; then
            print_status "success" "GitHub token is valid"
        else
            print_status "error" "GitHub token is invalid (HTTP $HTTP_CODE)"
        fi
    fi
else
    print_status "warning" "GITHUB_TOKEN not set. You'll need it for deployment."
    print_status "info" "Generate at: https://github.com/settings/tokens"
    print_status "info" "Required scopes: repo (all), workflow (if needed)"
fi
echo ""

echo -e "${BLUE}[5/7] Checking JWT Secret${NC}"
echo "--------------------------"
if [ -n "${JWT_SECRET:-}" ]; then
    JWT_LENGTH=${#JWT_SECRET}
    if [ $JWT_LENGTH -ge 32 ]; then
        print_status "success" "JWT_SECRET is set (length: $JWT_LENGTH chars)"
    else
        print_status "warning" "JWT_SECRET is too short ($JWT_LENGTH chars). Minimum: 32 chars"
    fi
else
    print_status "warning" "JWT_SECRET not set. Generate with:"
    print_status "info" "  openssl rand -base64 32"
fi
echo ""

echo -e "${BLUE}[6/7] Checking Project Files${NC}"
echo "-----------------------------"
REQUIRED_FILES=(
    "$PROJECT_ROOT/pom.xml"
    "$PROJECT_ROOT/src/main/java/com/bapukikutia/menuadmin/MenuAdminApplication.java"
    "$CONFIG_DIR/cloud-init.yaml"
    "$CONFIG_DIR/docker-compose.yml"
    "$CONFIG_DIR/Dockerfile"
    "$DOCS_DIR/DEPLOYMENT_PLAN.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if file_exists "$file"; then
        print_status "success" "Found: $(basename $file)"
    else
        print_status "error" "Missing: $file"
    fi
done
echo ""

echo -e "${BLUE}[7/7] Checking OCI Free Tier Availability${NC}"
echo "------------------------------------------"
if command_exists oci; then
    print_status "info" "Checking OCI tenancy and compartment..."

    # Get default compartment from config
    if COMPARTMENT_ID=$(oci iam compartment list --all 2>/dev/null | grep -m1 '"id"' | cut -d'"' -f4); then
        print_status "success" "OCI connection successful"
        print_status "info" "Default compartment: ${COMPARTMENT_ID:0:20}..."
    else
        print_status "warning" "Could not verify OCI connection. Check your config."
    fi

    print_status "info" "Manual check: Visit OCI Console → Compute → Create Instance"
    print_status "info" "Verify VM.Standard.A1.Flex availability in your region"
else
    print_status "warning" "Cannot check OCI availability without CLI"
fi
echo ""

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Prerequisites Check Summary${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}All critical checks passed!${NC}"
    echo ""
    echo -e "${GREEN}You're ready to proceed with infrastructure setup.${NC}"
    echo -e "${GREEN}Next step:${NC}"
    echo -e "  ${BLUE}./02-create-infrastructure.sh${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}Some checks failed. Please fix the issues above.${NC}"
    echo ""
    echo -e "${YELLOW}Common fixes:${NC}"
    echo "  1. Install OCI CLI: brew install oci-cli (Mac)"
    echo "  2. Configure OCI: oci setup config"
    echo "  3. Generate SSH key: ssh-keygen -t ed25519"
    echo "  4. Generate GitHub token: https://github.com/settings/tokens"
    echo "  5. Generate JWT secret: openssl rand -base64 32"
    echo ""
    echo -e "${YELLOW}Set environment variables:${NC}"
    echo "  export GITHUB_TOKEN='your-token'"
    echo "  export JWT_SECRET='your-32-char-secret'"
    echo ""
    exit 1
fi
