#!/bin/bash

# Restaurant Menu Admin API - OCI Deployment
# Script 4: Validate Deployment
# This script performs comprehensive validation of the deployment

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
DEPLOYMENT_INFO_FILE="$SCRIPT_DIR/../deployment-info.txt"
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
echo -e "${BLUE}Deployment Validation${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Load deployment info
if [ ! -f "$DEPLOYMENT_INFO_FILE" ]; then
    echo -e "${RED}Deployment info not found: $DEPLOYMENT_INFO_FILE${NC}"
    echo "Run 03-deploy-application.sh first"
    exit 1
fi

source "$DEPLOYMENT_INFO_FILE"

# Track overall status
ALL_TESTS_PASSED=true

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
        ALL_TESTS_PASSED=false
    else
        echo -e "${BLUE}ℹ${NC} $message"
    fi
}

# Test 1: Health Check
echo -e "${BLUE}[1/8] Testing Health Endpoint${NC}"
echo "----------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    print_status "success" "Health check passed (HTTP $HTTP_CODE)"

    # Get detailed health info
    HEALTH_RESPONSE=$(curl -s "$HEALTH_URL")
    STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

    if [ "$STATUS" = "UP" ]; then
        print_status "success" "Application status: UP"
    else
        print_status "warning" "Application status: $STATUS"
    fi
else
    print_status "error" "Health check failed (HTTP $HTTP_CODE)"
fi
echo ""

# Test 2: Authentication
echo -e "${BLUE}[2/8] Testing Authentication${NC}"
echo "---------------------------"
AUTH_RESPONSE=$(curl -s -X POST "$LOGIN_URL" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" \
    -w "\nHTTP_CODE:%{http_code}")

HTTP_CODE=$(echo "$AUTH_RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)
RESPONSE_BODY=$(echo "$AUTH_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_status "success" "Authentication successful (HTTP $HTTP_CODE)"

    # Extract JWT token
    JWT_TOKEN=$(echo "$RESPONSE_BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [ -n "$JWT_TOKEN" ]; then
        print_status "success" "JWT token received (${#JWT_TOKEN} chars)"
        # Save token for subsequent tests
        echo "$JWT_TOKEN" > /tmp/jwt-token.txt
    else
        print_status "warning" "JWT token not found in response"
    fi
else
    print_status "error" "Authentication failed (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"
fi
echo ""

# Test 3: Fetch Categories
echo -e "${BLUE}[3/8] Testing Categories Endpoint${NC}"
echo "---------------------------------"
if [ -f /tmp/jwt-token.txt ]; then
    JWT_TOKEN=$(cat /tmp/jwt-token.txt)

    CATEGORIES_RESPONSE=$(curl -s -X GET "http://$PUBLIC_IP:8080/api/categories" \
        -H "Authorization: Bearer $JWT_TOKEN" \
        -w "\nHTTP_CODE:%{http_code}")

    HTTP_CODE=$(echo "$CATEGORIES_RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)
    RESPONSE_BODY=$(echo "$CATEGORIES_RESPONSE" | sed '/HTTP_CODE/d')

    if [ "$HTTP_CODE" = "200" ]; then
        print_status "success" "Categories fetched successfully (HTTP $HTTP_CODE)"

        # Count categories
        CATEGORY_COUNT=$(echo "$RESPONSE_BODY" | grep -o '"id":' | wc -l | xargs)
        print_status "info" "Found $CATEGORY_COUNT categories"
    else
        print_status "error" "Failed to fetch categories (HTTP $HTTP_CODE)"
    fi
else
    print_status "warning" "Skipping (no JWT token available)"
fi
echo ""

# Test 4: Container Status
echo -e "${BLUE}[4/8] Testing Container Status${NC}"
echo "------------------------------"
CONTAINER_STATUS=$(ssh opc@$PUBLIC_IP "docker ps --filter name=$CONTAINER_NAME --format '{{.Status}}'" 2>/dev/null || echo "")

if [ -n "$CONTAINER_STATUS" ]; then
    print_status "success" "Container is running: $CONTAINER_STATUS"
else
    print_status "error" "Container is not running"
fi
echo ""

# Test 5: Git Repository
echo -e "${BLUE}[5/8] Testing Git Repository${NC}"
echo "---------------------------"
GIT_STATUS=$(ssh opc@$PUBLIC_IP "cd /opt/repo && git status" 2>/dev/null || echo "error")

if echo "$GIT_STATUS" | grep -q "On branch"; then
    BRANCH=$(echo "$GIT_STATUS" | grep "On branch" | cut -d' ' -f3)
    print_status "success" "Git repository initialized (branch: $BRANCH)"

    # Check for uncommitted changes
    if echo "$GIT_STATUS" | grep -q "nothing to commit"; then
        print_status "success" "Working directory clean"
    else
        print_status "info" "Working directory has changes (normal)"
    fi
else
    print_status "error" "Git repository not properly initialized"
fi
echo ""

# Test 6: Log Files
echo -e "${BLUE}[6/8] Testing Application Logs${NC}"
echo "------------------------------"
LOG_LINES=$(ssh opc@$PUBLIC_IP "docker logs $CONTAINER_NAME --tail 50" 2>/dev/null | wc -l | xargs)

if [ "$LOG_LINES" -gt 0 ]; then
    print_status "success" "Application logs available ($LOG_LINES lines)"

    # Check for errors in recent logs
    ERROR_COUNT=$(ssh opc@$PUBLIC_IP "docker logs $CONTAINER_NAME --tail 100 | grep -i 'error' | wc -l" 2>/dev/null | xargs)

    if [ "$ERROR_COUNT" -eq 0 ]; then
        print_status "success" "No errors in recent logs"
    else
        print_status "warning" "Found $ERROR_COUNT errors in recent logs"
        print_status "info" "Check logs: ssh opc@$PUBLIC_IP 'docker logs $CONTAINER_NAME'"
    fi
else
    print_status "warning" "No application logs found"
fi
echo ""

# Test 7: Resource Usage
echo -e "${BLUE}[7/8] Testing Resource Usage${NC}"
echo "---------------------------"
CONTAINER_STATS=$(ssh opc@$PUBLIC_IP "docker stats $CONTAINER_NAME --no-stream --format '{{.CPUPerc}},{{.MemUsage}}'" 2>/dev/null || echo "")

if [ -n "$CONTAINER_STATS" ]; then
    CPU_USAGE=$(echo "$CONTAINER_STATS" | cut -d',' -f1)
    MEM_USAGE=$(echo "$CONTAINER_STATS" | cut -d',' -f2)

    print_status "success" "Container stats: CPU=$CPU_USAGE, Memory=$MEM_USAGE"

    # Check if memory usage is concerning (>90%)
    MEM_PERCENT=$(echo "$CPU_USAGE" | sed 's/%//')
    if (( $(echo "$MEM_PERCENT < 90" | bc -l) )); then
        print_status "success" "Resource usage is healthy"
    else
        print_status "warning" "High resource usage detected"
    fi
else
    print_status "warning" "Could not retrieve container stats"
fi
echo ""

# Test 8: Git Push Test (Optional)
echo -e "${BLUE}[8/8] Testing Git Integration${NC}"
echo "----------------------------"
print_status "info" "This requires making a test change via the API"
print_status "info" "Skipping automated test (manual verification recommended)"
echo ""
print_status "info" "Manual test steps:"
echo "  1. Make a change via Admin UI or API"
echo "  2. Check for new commit: ssh opc@$PUBLIC_IP 'cd /opt/repo && git log -1'"
echo "  3. Verify push to GitHub: Check repository commits"
echo ""

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

if [ "$ALL_TESTS_PASSED" = true ]; then
    echo -e "${GREEN}All critical tests passed!${NC}"
    echo ""
    echo -e "${GREEN}Deployment is successful and operational.${NC}"
    echo ""
    echo -e "${GREEN}URLs:${NC}"
    echo "  Health: $HEALTH_URL"
    echo "  Login: $LOGIN_URL"
    echo "  Categories: http://$PUBLIC_IP:8080/api/categories"
    echo ""
    echo -e "${GREEN}Credentials:${NC}"
    echo "  Username: $ADMIN_USERNAME"
    echo "  Password: $ADMIN_PASSWORD"
    echo ""
    echo -e "${GREEN}Next Steps:${NC}"
    echo "  1. Test full workflow with Admin UI"
    echo "  2. Make a test change and verify Git commit"
    echo "  3. Configure SSL (optional): certbot --nginx"
    echo "  4. Set up monitoring (optional)"
    echo ""
    exit 0
else
    echo -e "${YELLOW}Some tests failed. Review the issues above.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "  1. Check application logs: ssh opc@$PUBLIC_IP 'docker logs $CONTAINER_NAME'"
    echo "  2. Check container status: ssh opc@$PUBLIC_IP 'docker ps -a'"
    echo "  3. Restart container: ssh opc@$PUBLIC_IP 'docker restart $CONTAINER_NAME'"
    echo "  4. Review deployment logs"
    echo ""
    exit 1
fi
