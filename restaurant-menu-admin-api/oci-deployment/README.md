# OCI Deployment - Restaurant Menu Admin API

Complete deployment package for deploying the Restaurant Menu Admin API to Oracle Cloud Infrastructure (OCI) using the Always Free tier.

## 🚨 Current Status: 95% Complete - Capacity Issue

**All configuration is ready!** Network infrastructure is deployed. The only remaining step is creating the compute instance, which is currently blocked by OCI Mumbai capacity constraints ("Out of host capacity" error).

### ✅ What's Complete

**Environment & Configuration:**
- ✅ `.env` file configured with all required variables
- ✅ GitHub token configured and validated
- ✅ JWT secret configured (44 characters)
- ✅ Admin credentials configured
- ✅ OCI compartment ID configured

**Infrastructure:**
- ✅ VCN (Virtual Cloud Network) created
- ✅ Internet Gateway created
- ✅ Route Table configured
- ✅ Security List configured (ports 22, 80, 443, 8080)
- ✅ Subnet created and configured

**Scripts & Configuration:**
- ✅ All 4 deployment scripts ready and idempotent
- ✅ Docker configuration optimized (1 OCPU + 2GB RAM)
- ✅ JVM heap tuned for 2GB instance
- ✅ Scripts load .env automatically

**Resource Optimization:**
- ✅ quiz-app-server reduced: 2 OCPU + 12GB → 1 OCPU + 6GB
- ✅ restaurant-menu-admin-api configured: 1 OCPU + 2GB
- ✅ Total allocation: 2 OCPU + 8GB (within 4 OCPU + 24GB free tier)

### ⏳ What's Pending

**Compute Instance Creation:**
- Status: Blocked by OCI capacity in Mumbai AD-1
- Error: "Out of host capacity"
- What it means: OCI's Mumbai region temporarily has no available ARM instances
- Is this normal?: Yes, capacity constraints are common for Always Free ARM instances

### 🔄 Solutions

1. **Wait and retry** - Capacity typically returns within hours/days
   ```bash
   cd scripts && ./02-create-infrastructure.sh
   ```

2. **Automated retry** - Runs every 30 minutes until successful
   ```bash
   cd scripts && ./retry-instance-creation.sh
   ```

3. **Deploy on existing instance** - Use quiz-app-server
   - See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) Option 2

### 📊 Resource Allocation

| Instance | OCPUs | Memory | Status |
|----------|-------|--------|--------|
| quiz-app-server | 1 | 6GB | ✅ Running |
| restaurant-menu-admin-api | 1 | 2GB | ⏳ Pending |
| **Total** | **2** | **8GB** | - |
| **Free Tier Limit** | **4** | **24GB** | - |
| **Remaining** | **2** | **16GB** | - |

**Utilization**: 50% OCPU, 33% Memory

For detailed troubleshooting, see:
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Solutions for capacity issue
- [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) - Environment configuration details

---

## Quick Start

```bash
cd restaurant-menu-admin-api

# Step 0: Set up environment variables (one-time setup)
# Your .env file already exists with GitHub token and JWT secret!
# The deployment scripts will automatically load it.
# (Optional: Review and update .env if needed)

cd oci-deployment/scripts

# Step 1: Verify prerequisites
./01-verify-prerequisites.sh

# Step 2: Create OCI infrastructure
./02-create-infrastructure.sh

# Step 3: Deploy application
./03-deploy-application.sh

# Step 4: Validate deployment
./04-validate-deployment.sh
```

### Environment Variables Setup

All deployment scripts automatically load environment variables from the `.env` file located at:
```
restaurant-menu-admin-api/.env
```

**Your .env file already contains:**
- ✅ `GITHUB_TOKEN` - GitHub Personal Access Token
- ✅ `JWT_SECRET` - JWT signing secret
- ✅ `ADMIN_USERNAME` - Admin username (default: admin)
- ✅ `ADMIN_PASSWORD` - Admin password
- ✅ `CORS_ALLOWED_ORIGINS` - CORS configuration

**No manual exports needed!** The scripts will automatically use these values.

If you need to create a new .env file or want to see all available options, see:
```bash
cat oci-deployment/.env.example
```

## Directory Structure

```
oci-deployment/
├── README.md                           # This file - Deployment guide with status
├── ENVIRONMENT_VARIABLES.md            # Environment variables documentation
├── docs/
│   └── TROUBLESHOOTING.md              # Solutions for capacity issues
├── configs/
│   ├── cloud-init.yaml                # Instance initialization config
│   ├── docker-compose.yml             # Container orchestration
│   └── Dockerfile                     # Application container image
└── scripts/
    ├── 01-verify-prerequisites.sh     # Prerequisites check
    ├── 02-create-infrastructure.sh    # Create OCI resources (idempotent)
    ├── 03-deploy-application.sh       # Deploy application
    ├── 04-validate-deployment.sh      # Validate deployment
    └── retry-instance-creation.sh     # Automated retry for capacity issues
```

## Prerequisites

### Local Machine Requirements

1. **OCI CLI** - Oracle Cloud Infrastructure CLI
   ```bash
   # Mac
   brew install oci-cli

   # Linux
   bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

   # Configure
   oci setup config
   ```

2. **Git** - Version control
   ```bash
   git --version
   ```

3. **SSH Key** - For instance access
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

4. **GitHub Personal Access Token** ✅ Already configured in .env
   - Your .env file already contains a valid GitHub token
   - Token has repo access for: ShubhamChouksey123/restaurant-menu
   - No action needed unless you want to rotate the token

5. **JWT Secret** ✅ Already configured in .env
   - Your .env file already contains a JWT secret
   - Length: 44 characters (✓ exceeds minimum 32)
   - No action needed unless you want to regenerate it

### OCI Requirements

- Active OCI account with Always Free tier access
- Compartment with permissions to create:
  - Compute instances (VM.Standard.A1.Flex)
  - Virtual Cloud Networks (VCN)
  - Security Lists
  - Route Tables
  - Internet Gateways

## Deployment Steps

### Phase 1: Prerequisites Verification (15 minutes)

Run the prerequisites verification script:

```bash
./scripts/01-verify-prerequisites.sh
```

This checks:
- OCI CLI installation and configuration
- Git installation
- SSH key availability
- GitHub token (if set)
- JWT secret (if set)
- Required project files

**Fix any issues before proceeding.**

### Phase 2: Infrastructure Creation (20 minutes)

Create OCI infrastructure:

```bash
# Optional: Set custom values
export INSTANCE_NAME="restaurant-menu-admin-api"
export COMPARTMENT_ID="ocid1.compartment.oc1..."  # Auto-detected if not set

./scripts/02-create-infrastructure.sh
```

This creates:
- Virtual Cloud Network (VCN) with CIDR 10.0.0.0/16
- Public subnet with CIDR 10.0.1.0/24
- Internet Gateway for internet access
- Route Table for routing
- Security List with firewall rules
- Compute instance (VM.Standard.A1.Flex, 2 OCPUs, 4GB RAM)

**Wait 10-15 minutes for cloud-init to complete.**

Check cloud-init progress:
```bash
ssh opc@<PUBLIC_IP> 'tail -f /var/log/cloud-init-output.log'
```

### Phase 3: Application Deployment (15 minutes)

Deploy the application:

```bash
# Environment variables are automatically loaded from .env file
# No manual exports needed!

./scripts/03-deploy-application.sh
```

The script will automatically use:
- `GITHUB_TOKEN` from your .env file
- `JWT_SECRET` from your .env file
- `ADMIN_PASSWORD` from your .env file (default: admin123)

This:
- Clones repository to instance
- Creates environment configuration
- Builds Docker image on instance (remote build)
- Starts application container
- Performs initial health check

### Phase 4: Validation (10 minutes)

Validate the deployment:

```bash
./scripts/04-validate-deployment.sh
```

This tests:
- Health endpoint
- Authentication
- Categories API
- Container status
- Git repository
- Application logs
- Resource usage

## Configuration

### Environment Variables

Required variables for deployment:

```bash
# Required
export GITHUB_TOKEN='ghp_xxxxxxxxxxxxx'          # GitHub Personal Access Token
export JWT_SECRET='your-32-char-secret'          # JWT signing secret

# Optional (with defaults)
export ADMIN_PASSWORD='admin123'                 # Admin panel password
export INSTANCE_NAME='restaurant-menu-admin-api' # OCI instance name
export COMPARTMENT_ID='auto-detected'            # OCI compartment
```

### Security Configuration

**GitHub Token Permissions:**
- Repository: Read and Write
- Contents: Read and Write
- (Optional) Workflows: Read

**JWT Secret Generation:**
```bash
openssl rand -base64 32
```

**Admin Password:**
- Default: `admin123`
- **Change in production!**
- Set via `ADMIN_PASSWORD` environment variable

## Architecture

### Deployed Components

```
OCI Instance (VM.Standard.A1.Flex)
├── Docker
│   └── restaurant-menu-admin-api:latest
│       ├── Spring Boot 3.4.1
│       ├── Java 21
│       └── Port 8080
├── Nginx (reverse proxy)
│   ├── Port 80 → 8080
│   └── Port 443 → 8080 (SSL)
└── Git Repository
    └── /opt/repo (menu data storage)
```

### Network Flow

```
Internet
    ↓
OCI Security List (Firewall)
    ↓
Nginx (80/443)
    ↓
Spring Boot API (8080)
    ↓
Git Operations → GitHub
    ↓
GitHub Actions → GitHub Pages
```

## Resource Specifications

### Always Free Tier Limits

| Resource | Allocation | Free Tier Limit |
|----------|-----------|-----------------|
| Shape | VM.Standard.A1.Flex | 4 OCPUs total |
| OCPUs | 2 | ✓ Within limit |
| Memory | 4 GB | ✓ Within limit (24GB total) |
| Boot Volume | 50 GB | ✓ Within limit |
| Network | Public IP | ✓ 1 free |
| Bandwidth | 10 TB/month | ✓ Within limit |

**Monthly Cost: $0** (within Always Free tier)

## Operations

### Access Instance

```bash
# SSH access
ssh opc@<PUBLIC_IP>

# View application logs
ssh opc@<PUBLIC_IP> 'docker logs restaurant-menu-admin-api -f'

# Check container status
ssh opc@<PUBLIC_IP> 'docker ps'

# Check resource usage
ssh opc@<PUBLIC_IP> 'docker stats'
```

### Application Management

```bash
# Restart application
ssh opc@<PUBLIC_IP> 'cd /opt/restaurant-menu-admin/app && docker compose restart'

# Stop application
ssh opc@<PUBLIC_IP> 'cd /opt/restaurant-menu-admin/app && docker compose down'

# Start application
ssh opc@<PUBLIC_IP> 'cd /opt/restaurant-menu-admin/app && docker compose up -d'

# Rebuild and restart
ssh opc@<PUBLIC_IP> 'cd /opt/restaurant-menu-admin/app && docker compose build && docker compose up -d'
```

### Update Application

```bash
# SSH into instance
ssh opc@<PUBLIC_IP>

# Pull latest code
cd /opt/restaurant-menu-admin/app
git pull origin admin-api

# Rebuild and restart
docker compose build
docker compose up -d

# Verify
curl http://localhost:8080/actuator/health
```

### View Logs

```bash
# Application logs (live)
ssh opc@<PUBLIC_IP> 'docker logs restaurant-menu-admin-api -f'

# Application logs (last 100 lines)
ssh opc@<PUBLIC_IP> 'docker logs restaurant-menu-admin-api --tail 100'

# Git operations log
ssh opc@<PUBLIC_IP> 'tail -f /opt/restaurant-menu-admin/logs/git-operations.log'

# Cloud-init log
ssh opc@<PUBLIC_IP> 'tail -f /var/log/cloud-init-output.log'

# Nginx access log
ssh opc@<PUBLIC_IP> 'sudo tail -f /var/log/nginx/access.log'
```

### Monitor Resources

```bash
# Container stats
ssh opc@<PUBLIC_IP> 'docker stats restaurant-menu-admin-api'

# Disk usage
ssh opc@<PUBLIC_IP> 'df -h'

# Memory usage
ssh opc@<PUBLIC_IP> 'free -h'

# Git repository size
ssh opc@<PUBLIC_IP> 'du -sh /opt/repo'
```

## Troubleshooting

### Common Issues

#### 1. Cloud-init Taking Too Long

**Symptom:** Script 03 hangs waiting for cloud-init

**Solution:**
```bash
# Check cloud-init status
ssh opc@<PUBLIC_IP> 'cloud-init status'

# View cloud-init logs
ssh opc@<PUBLIC_IP> 'tail -f /var/log/cloud-init-output.log'

# If stuck, manually complete setup
ssh opc@<PUBLIC_IP>
sudo systemctl restart docker
```

#### 2. Docker Build Fails

**Symptom:** Maven build errors during Docker image creation

**Solution:**
```bash
# SSH into instance
ssh opc@<PUBLIC_IP>

# Check Java version
java -version  # Should be 21

# Manual build with verbose output
cd /opt/restaurant-menu-admin/app
docker compose build --no-cache
```

#### 3. Application Won't Start

**Symptom:** Container exits immediately or health checks fail

**Solution:**
```bash
# Check container logs
ssh opc@<PUBLIC_IP> 'docker logs restaurant-menu-admin-api'

# Check environment variables
ssh opc@<PUBLIC_IP> 'cat /opt/restaurant-menu-admin/app/.env'

# Verify GitHub token
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user

# Restart with fresh configuration
ssh opc@<PUBLIC_IP> 'cd /opt/restaurant-menu-admin/app && docker compose down && docker compose up -d'
```

#### 4. Git Push Fails

**Symptom:** Changes not appearing on GitHub

**Solution:**
```bash
# Check Git configuration
ssh opc@<PUBLIC_IP> 'cd /opt/repo && git config --list'

# Test Git push manually
ssh opc@<PUBLIC_IP> 'cd /opt/repo && git push origin master'

# Verify GitHub token permissions
# Token needs: repo (all), contents (read/write)
```

#### 5. Cannot SSH to Instance

**Symptom:** SSH connection refused or times out

**Solution:**
```bash
# Verify instance is running
oci compute instance get --instance-id <INSTANCE_ID> | grep "lifecycle-state"

# Check security list allows SSH from your IP
curl ifconfig.me  # Your public IP

# Update security list if needed (via OCI Console)

# Try with verbose SSH
ssh -vvv opc@<PUBLIC_IP>
```

## Security Hardening

### Production Checklist

- [ ] Change default admin password
- [ ] Configure SSL/TLS (Let's Encrypt)
- [ ] Restrict SSH to specific IP addresses
- [ ] Close port 8080 direct access (use Nginx only)
- [ ] Set up firewall rules (iptables)
- [ ] Enable automatic security updates
- [ ] Set up log monitoring and alerts
- [ ] Configure Git token expiration reminders
- [ ] Review and minimize GitHub token permissions
- [ ] Set up backup strategy for Git repository

### SSL Configuration (Optional)

```bash
# SSH into instance
ssh opc@<PUBLIC_IP>

# Install certbot
sudo dnf install -y certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
sudo systemctl status certbot-renew.timer
```

## Support & Documentation

- **Deployment Plan:** [docs/DEPLOYMENT_PLAN.md](docs/DEPLOYMENT_PLAN.md)
- **Project README:** [../README.md](../README.md)
- **OCI Documentation:** https://docs.oracle.com/en-us/iaas/
- **Spring Boot Docs:** https://docs.spring.io/spring-boot/
- **Docker Compose:** https://docs.docker.com/compose/

## Cost Analysis

### Always Free Resources Used

| Resource | Quantity | Free Tier Limit | Status |
|----------|----------|-----------------|--------|
| Compute (ARM) | 2 OCPUs | 4 OCPUs | ✓ Free |
| Memory | 4 GB | 24 GB | ✓ Free |
| Storage | 50 GB | 200 GB | ✓ Free |
| Public IP | 1 | 2 | ✓ Free |
| Outbound Network | <10 TB/month | 10 TB/month | ✓ Free |

**Expected Monthly Cost: $0**

### Potential Additional Costs

Only if you exceed free tier limits:
- Additional storage: ~$0.025/GB/month
- Load balancer: ~$0.01/hour (~$7.20/month)
- Backup: ~$0.0255/GB/month

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-22 | Initial deployment package |

## License

This deployment package is part of the Restaurant Menu Admin API project.

---

**Status:** ✅ Ready for Production Deployment

For questions or issues, refer to the main project documentation.
