# OCI Deployment Troubleshooting Guide

## Current Status

The Restaurant Menu Admin API deployment infrastructure is ready, but we're experiencing an OCI capacity constraint.

### What's Working ✅

1. **All network infrastructure created successfully**:
   - VCN (Virtual Cloud Network)
   - Internet Gateway
   - Route Table
   - Security List (ports 22, 80, 443, 8080 open)
   - Subnet

2. **Scripts are fully functional and idempotent**:
   - Environment variables load from .env automatically
   - All scripts can be run multiple times safely
   - Resources are reused if they already exist

3. **Resource allocation optimized**:
   - quiz-app-server reduced from 2 OCPUs + 12GB to 1 OCPU + 6GB
   - restaurant-menu-admin-api configured for 1 OCPU + 2GB
   - Total: 2 OCPUs + 8GB (within 4 OCPU + 24GB free tier)

### Current Issue ❌

**Error**: "Out of host capacity" when creating compute instance

**Root Cause**: Mumbai AD-1 (rWnQ:AP-MUMBAI-1-AD-1) has no available capacity for new ARM instances.

## Solution Options

### Option 1: Wait and Retry (Recommended)

OCI capacity fluctuates. The "Out of host capacity" error is temporary and usually resolves within hours or days.

**Steps**:
```bash
cd oci-deployment/scripts

# Try every few hours
./02-create-infrastructure.sh

# The script is idempotent - it will:
# - Reuse existing network resources (VCN, subnet, etc.)
# - Only attempt to create the missing compute instance
# - Exit cleanly if instance already exists
```

**Tips for Success**:
- Try during off-peak hours (late night IST / early morning IST)
- Try on weekends when demand is lower
- OCI restocks capacity regularly

### Option 2: Deploy on Existing quiz-app-server Instance

Since the quiz-app-server is already running, you can deploy both applications on the same instance.

**Pros**:
- Immediate deployment
- No capacity issues
- Both apps share resources efficiently

**Cons**:
- Both applications on one instance (less isolation)
- Need to manage port conflicts

**Steps**:

1. **Get quiz-app-server IP**:
```bash
oci compute instance list \
    --compartment-id "$COMPARTMENT_ID" \
    --display-name "quiz-app-server" \
    --query 'data[0]."primary-public-ip"' \
    --raw-output
```

2. **SSH to quiz-app-server**:
```bash
ssh -i ~/.ssh/id_ed25519 opc@<IP_ADDRESS>
```

3. **Create deployment directory**:
```bash
sudo mkdir -p /opt/restaurant-menu-admin
sudo chown opc:opc /opt/restaurant-menu-admin
cd /opt/restaurant-menu-admin
```

4. **Copy deployment files from local machine**:
```bash
# On your local machine
cd /Users/schouksey/Documents/personal-projects/claude-projects/restaurant-menu/restaurant-menu-admin-api

scp -i ~/.ssh/id_ed25519 oci-deployment/configs/docker-compose.yml opc@<IP>:/opt/restaurant-menu-admin/
scp -i ~/.ssh/id_ed25519 oci-deployment/configs/Dockerfile opc@<IP>:/opt/restaurant-menu-admin/
scp -i ~/.ssh/id_ed25519 .env opc@<IP>:/opt/restaurant-menu-admin/
```

5. **Build and deploy on quiz-app-server**:
```bash
# On quiz-app-server via SSH
cd /opt/restaurant-menu-admin
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

6. **Update firewall (if needed)**:
```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

7. **Access the API**:
```
http://<QUIZ_APP_SERVER_IP>:8080
```

### Option 3: Try Different Region

Deploy to a different OCI region that might have capacity.

**Available Free Tier Regions**:
- ap-hyderabad-1 (Hyderabad, India)
- ap-seoul-1 (Seoul, South Korea)
- sa-saopaulo-1 (Sao Paulo, Brazil)
- eu-marseille-1 (Marseille, France)

**Steps**:

1. **Check OCI console for region availability**
2. **Update your OCI CLI profile** to use different region
3. **Create new VCN and resources** in that region (script will handle this)
4. **Run deployment script**

**Note**: You'll need to create all networking resources from scratch in the new region.

### Option 4: Contact OCI Support

Open a support ticket requesting capacity in Mumbai region.

**Steps**:
1. Go to OCI Console → Support → Create Support Request
2. Subject: "Request for ARM instance capacity in Mumbai AD-1"
3. Describe: "Unable to create VM.Standard.A1.Flex instance (1 OCPU, 2GB) in Mumbai AD-1. Getting 'Out of host capacity' error."
4. Provide the request ID from the error

## Retry Strategy

Create a simple retry script:

```bash
#!/bin/bash
# oci-deployment/scripts/retry-instance-creation.sh

cd "$(dirname "$0")"

echo "Attempting to create instance with retry logic..."
echo "Will retry every 30 minutes until successful"
echo ""

RETRY_COUNT=0
MAX_RETRIES=20

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES at $(date)"

    if ./02-create-infrastructure.sh; then
        echo ""
        echo "SUCCESS! Instance created."
        exit 0
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo ""
        echo "Failed. Waiting 30 minutes before retry..."
        sleep 1800  # 30 minutes
    fi
done

echo ""
echo "Max retries reached. Please try Option 2 or contact OCI support."
```

Make it executable and run:
```bash
chmod +x oci-deployment/scripts/retry-instance-creation.sh
./oci-deployment/scripts/retry-instance-creation.sh
```

## What Happens After Instance Creation

Once the instance is created (via any option), the remaining steps are:

1. **Get instance public IP**:
```bash
oci compute instance list \
    --compartment-id "$COMPARTMENT_ID" \
    --display-name "restaurant-menu-admin-api" \
    --query 'data[0]."primary-public-ip"' \
    --raw-output
```

2. **Run deployment script**:
```bash
cd oci-deployment/scripts
./03-deploy-application.sh
```

3. **Validate deployment**:
```bash
./04-validate-deployment.sh
```

4. **Access your API**:
```
http://<INSTANCE_IP>:8080
```

## Environment Variables Summary

All required environment variables are now properly configured in `.env`:

### Required for Deployment:
- ✅ `GITHUB_REPOSITORY_URL` - Repository URL
- ✅ `GITHUB_REPOSITORY_BRANCH` - Branch to deploy (master)
- ✅ `GITHUB_TOKEN` - GitHub personal access token
- ✅ `GITHUB_USER_NAME` - Git commit author name
- ✅ `GITHUB_USER_EMAIL` - Git commit author email
- ✅ `JWT_SECRET` - JWT signing secret
- ✅ `JWT_EXPIRATION` - Token expiration time
- ✅ `ADMIN_USERNAME` - Admin login username
- ✅ `ADMIN_PASSWORD` - Admin login password
- ✅ `ADMIN_EMAIL` - Admin email address
- ✅ `COMPARTMENT_ID` - OCI compartment ID
- ✅ `INSTANCE_NAME` - OCI instance name

## Files Ready for Deployment

All configuration files are ready:

1. ✅ `.env` - Environment variables (cleaned up, no duplicates)
2. ✅ `oci-deployment/configs/Dockerfile` - Container build config (optimized for 2GB RAM)
3. ✅ `oci-deployment/configs/docker-compose.yml` - Container orchestration (optimized for 1 OCPU)
4. ✅ `oci-deployment/configs/cloud-init.yaml` - Instance initialization
5. ✅ `oci-deployment/scripts/01-verify-prerequisites.sh` - Pre-deployment checks
6. ✅ `oci-deployment/scripts/02-create-infrastructure.sh` - Infrastructure creation (idempotent)
7. ✅ `oci-deployment/scripts/03-deploy-application.sh` - Application deployment
8. ✅ `oci-deployment/scripts/04-validate-deployment.sh` - Post-deployment validation

## Summary

**You're 95% done!** All configuration is correct, scripts are ready, and network infrastructure exists.

**The only blocker** is OCI Mumbai capacity. Use Option 1 (wait and retry) or Option 2 (deploy on quiz-app-server) to complete the deployment.

**Recommended approach**: Try Option 1 (retry) for a day or two. If still failing, use Option 2 (shared instance) as it's the quickest path to production.
