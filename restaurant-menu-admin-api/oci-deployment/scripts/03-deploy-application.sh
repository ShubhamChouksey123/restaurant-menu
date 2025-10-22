#!/bin/bash

# Restaurant Menu Admin API - OCI Deployment
# Script 3: Deploy Application
# This script deploys the application to the OCI instance

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
INSTANCE_DETAILS_FILE="$SCRIPT_DIR/../instance-details.txt"
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
echo -e "${BLUE}Application Deployment${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check for required environment variables
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo -e "${RED}GITHUB_TOKEN environment variable not set${NC}"
    echo "Export it before running:"
    echo "  export GITHUB_TOKEN='your-github-token'"
    exit 1
fi

if [ -z "${JWT_SECRET:-}" ]; then
    echo -e "${YELLOW}JWT_SECRET not set. Generating one...${NC}"
    JWT_SECRET=$(openssl rand -base64 32)
    echo -e "${GREEN}Generated JWT_SECRET: ${JWT_SECRET:0:20}...${NC}"
    echo ""
fi

if [ -z "${ADMIN_PASSWORD:-}" ]; then
    echo -e "${YELLOW}ADMIN_PASSWORD not set. Using default 'admin123'${NC}"
    echo -e "${RED}WARNING: Change this in production!${NC}"
    ADMIN_PASSWORD="admin123"
    echo ""
fi

# Load instance details
if [ ! -f "$INSTANCE_DETAILS_FILE" ]; then
    echo -e "${RED}Instance details file not found: $INSTANCE_DETAILS_FILE${NC}"
    echo "Run 02-create-infrastructure.sh first"
    exit 1
fi

source "$INSTANCE_DETAILS_FILE"

if [ -z "$PUBLIC_IP" ]; then
    echo -e "${RED}PUBLIC_IP not found in instance details${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Target instance: $PUBLIC_IP${NC}"
echo ""

# Test SSH connection
echo -e "${BLUE}[1/8] Testing SSH connection...${NC}"
if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new opc@$PUBLIC_IP "echo 'SSH OK'" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ SSH connection successful${NC}"
else
    echo -e "${RED}Failed to connect via SSH${NC}"
    echo "Check:"
    echo "  1. Instance is running: oci compute instance get --instance-id $INSTANCE_ID"
    echo "  2. Security list allows SSH from your IP"
    echo "  3. SSH key is correct"
    exit 1
fi
echo ""

# Wait for cloud-init completion
echo -e "${BLUE}[2/8] Checking cloud-init completion...${NC}"
echo "This may take up to 15 minutes if cloud-init is still running..."
echo ""

MAX_WAIT=900  # 15 minutes
ELAPSED=0
INTERVAL=30

while [ $ELAPSED -lt $MAX_WAIT ]; do
    if ssh opc@$PUBLIC_IP "test -f /opt/restaurant-menu-admin/cloud-init-completed.txt" 2>/dev/null; then
        echo -e "${GREEN}✓ Cloud-init completed${NC}"
        CLOUD_INIT_TIME=$(ssh opc@$PUBLIC_IP "cat /opt/restaurant-menu-admin/cloud-init-completed.txt" 2>/dev/null)
        echo "  $CLOUD_INIT_TIME"
        break
    else
        echo -n "."
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
    fi
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo -e "${RED}Cloud-init did not complete in time${NC}"
    echo "Check cloud-init logs:"
    echo "  ssh opc@$PUBLIC_IP 'tail -100 /var/log/cloud-init-output.log'"
    exit 1
fi
echo ""

# Verify Docker installation
echo -e "${BLUE}[3/8] Verifying Docker installation...${NC}"
if ssh opc@$PUBLIC_IP "docker --version" > /dev/null 2>&1; then
    DOCKER_VERSION=$(ssh opc@$PUBLIC_IP "docker --version")
    echo -e "${GREEN}✓ $DOCKER_VERSION${NC}"
else
    echo -e "${RED}Docker not installed${NC}"
    exit 1
fi
echo ""

# Clone repository to instance
echo -e "${BLUE}[4/8] Cloning repository to instance...${NC}"
ssh opc@$PUBLIC_IP "sudo -u appuser bash -c 'cd /opt/restaurant-menu-admin/app && \
    if [ -d .git ]; then \
        echo \"Repository exists, pulling latest changes...\"; \
        git pull origin admin-api; \
    else \
        echo \"Cloning repository...\"; \
        git clone https://github.com/ShubhamChouksey123/restaurant-menu.git .; \
        git checkout admin-api; \
    fi'"

echo -e "${GREEN}✓ Repository cloned${NC}"
echo ""

# Create .env file on instance
echo -e "${BLUE}[5/8] Creating environment configuration...${NC}"

ENV_CONTENT=$(cat <<EOF
# GitHub Configuration
GITHUB_REPOSITORY_URL=https://github.com/ShubhamChouksey123/restaurant-menu.git
GITHUB_REPOSITORY_BRANCH=master
GITHUB_TOKEN=$GITHUB_TOKEN

# Git User Configuration
GITHUB_USER_NAME=Restaurant Admin Bot
GITHUB_USER_EMAIL=admin@bapukikutia.com

# JWT Security
JWT_SECRET=$JWT_SECRET
JWT_EXPIRATION=86400000

# Admin Credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=$ADMIN_PASSWORD
ADMIN_EMAIL=admin@bapukikutia.com

# Application Configuration
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
GITHUB_LOCAL_CLONE_DIRECTORY=/opt/repo
EOF
)

ssh opc@$PUBLIC_IP "sudo -u appuser bash -c 'echo \"$ENV_CONTENT\" > /opt/restaurant-menu-admin/app/.env'"
ssh opc@$PUBLIC_IP "sudo -u appuser chmod 600 /opt/restaurant-menu-admin/app/.env"

echo -e "${GREEN}✓ Environment variables configured${NC}"
echo ""

# Copy docker-compose.yml and Dockerfile to instance
echo -e "${BLUE}[6/8] Copying Docker configurations...${NC}"

# Copy files
scp -q "$CONFIG_DIR/docker-compose.yml" "opc@$PUBLIC_IP:/tmp/docker-compose.yml"
scp -q "$CONFIG_DIR/Dockerfile" "opc@$PUBLIC_IP:/tmp/Dockerfile"

# Move to correct locations
ssh opc@$PUBLIC_IP "sudo -u appuser bash -c ' \
    mv /tmp/docker-compose.yml /opt/restaurant-menu-admin/app/restaurant-menu-admin-api/oci-deployment/configs/ && \
    mv /tmp/Dockerfile /opt/restaurant-menu-admin/app/restaurant-menu-admin-api/oci-deployment/configs/ && \
    ln -sf /opt/restaurant-menu-admin/app/restaurant-menu-admin-api/oci-deployment/configs/docker-compose.yml /opt/restaurant-menu-admin/app/docker-compose.yml'"

echo -e "${GREEN}✓ Docker configurations copied${NC}"
echo ""

# Build Docker image on instance (remote build)
echo -e "${BLUE}[7/8] Building Docker image on instance...${NC}"
echo "This may take 5-10 minutes (downloading dependencies, compiling)..."
echo ""

ssh opc@$PUBLIC_IP "sudo -u appuser bash -c ' \
    cd /opt/restaurant-menu-admin/app && \
    docker compose build 2>&1 | tee /tmp/docker-build.log'" || {
    echo -e "${RED}Docker build failed${NC}"
    echo "Check build logs:"
    echo "  ssh opc@$PUBLIC_IP 'cat /tmp/docker-build.log'"
    exit 1
}

echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""

# Start containers
echo -e "${BLUE}[8/8] Starting application containers...${NC}"
ssh opc@$PUBLIC_IP "sudo -u appuser bash -c ' \
    cd /opt/restaurant-menu-admin/app && \
    docker compose up -d'"

echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# Wait for application startup
echo -e "${BLUE}Waiting for application to start (60 seconds)...${NC}"
sleep 60
echo ""

# Health check
echo -e "${BLUE}Performing health check...${NC}"
HEALTH_URL="http://$PUBLIC_IP:8080/actuator/health"

MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Application is healthy${NC}"
        break
    else
        echo -n "."
        sleep 10
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo ""
    echo -e "${YELLOW}⚠ Health check did not return 200 (got $HTTP_CODE)${NC}"
    echo "Check application logs:"
    echo "  ssh opc@$PUBLIC_IP 'docker logs restaurant-menu-admin-api'"
else
    echo ""
fi

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Deployment Complete!${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${GREEN}Application URLs:${NC}"
echo "  Health Check: http://$PUBLIC_IP:8080/actuator/health"
echo "  Login: http://$PUBLIC_IP:8080/api/auth/login"
echo "  Categories: http://$PUBLIC_IP:8080/api/categories"
echo ""
echo -e "${GREEN}Admin Credentials:${NC}"
echo "  Username: admin"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo -e "${GREEN}Useful Commands:${NC}"
echo "  SSH into instance:"
echo "    ssh opc@$PUBLIC_IP"
echo ""
echo "  View logs:"
echo "    ssh opc@$PUBLIC_IP 'docker logs restaurant-menu-admin-api -f'"
echo ""
echo "  Restart application:"
echo "    ssh opc@$PUBLIC_IP 'cd /opt/restaurant-menu-admin/app && docker compose restart'"
echo ""
echo "  Check container status:"
echo "    ssh opc@$PUBLIC_IP 'docker ps'"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Test authentication: curl -X POST http://$PUBLIC_IP:8080/api/auth/login \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"username\":\"admin\",\"password\":\"$ADMIN_PASSWORD\"}'"
echo ""
echo "  2. Run validation script: ./04-validate-deployment.sh"
echo ""
echo "  3. Configure SSL (optional): See docs/DEPLOYMENT_PLAN.md Section 5 Phase 5"
echo ""

# Save deployment info
DEPLOYMENT_INFO_FILE="$SCRIPT_DIR/../deployment-info.txt"
cat > "$DEPLOYMENT_INFO_FILE" <<EOF
# Restaurant Menu Admin API - Deployment Info
# Deployed: $(date)

PUBLIC_IP=$PUBLIC_IP
HEALTH_URL=http://$PUBLIC_IP:8080/actuator/health
LOGIN_URL=http://$PUBLIC_IP:8080/api/auth/login
ADMIN_USERNAME=admin
ADMIN_PASSWORD=$ADMIN_PASSWORD

# Container Info
CONTAINER_NAME=restaurant-menu-admin-api
IMAGE_NAME=restaurant-menu-admin-api:latest

# SSH Connection
ssh opc@$PUBLIC_IP

# View Logs
ssh opc@$PUBLIC_IP 'docker logs restaurant-menu-admin-api -f'
EOF

echo -e "${GREEN}✓ Deployment info saved to: $DEPLOYMENT_INFO_FILE${NC}"
echo ""
