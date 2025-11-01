#!/bin/bash

# Restaurant Menu Admin API - OCI Deployment
# Script 2: Create Infrastructure
# This script creates all OCI infrastructure resources

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
echo -e "${BLUE}OCI Infrastructure Creation${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Configuration (customize these)
INSTANCE_NAME="${INSTANCE_NAME:-restaurant-menu-admin-api}"
COMPARTMENT_ID="${COMPARTMENT_ID:-}"  # Will auto-detect if empty
AVAILABILITY_DOMAIN="${AVAILABILITY_DOMAIN:-}"  # Will auto-detect if empty
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-$HOME/.ssh/id_ed25519.pub}"
CLOUD_INIT_FILE="$CONFIG_DIR/cloud-init.yaml"

# VM Configuration (Always Free tier)
SHAPE="VM.Standard.A1.Flex"
OCPUS=1
MEMORY_GB=2
BOOT_VOLUME_SIZE_GB=50

# Network Configuration
VCN_NAME="restaurant-menu-vcn"
VCN_CIDR="10.0.0.0/16"
SUBNET_NAME="restaurant-menu-subnet"
SUBNET_CIDR="10.0.1.0/24"
INTERNET_GATEWAY_NAME="restaurant-menu-igw"
ROUTE_TABLE_NAME="restaurant-menu-rt"
SECURITY_LIST_NAME="restaurant-menu-sl"

# Auto-detect compartment if not set
if [ -z "$COMPARTMENT_ID" ]; then
    echo -e "${BLUE}[1/10] Auto-detecting compartment...${NC}"
    COMPARTMENT_ID=$(oci iam compartment list --all \
        --query 'data[0].id' --raw-output 2>/dev/null || echo "")

    if [ -z "$COMPARTMENT_ID" ]; then
        echo -e "${RED}Could not auto-detect compartment.${NC}"
        echo "Set COMPARTMENT_ID environment variable:"
        echo "  export COMPARTMENT_ID='ocid1.compartment.oc1...'"
        exit 1
    fi

    echo -e "${GREEN}✓ Using compartment: ${COMPARTMENT_ID:0:30}...${NC}"
else
    echo -e "${GREEN}✓ Using provided compartment: ${COMPARTMENT_ID:0:30}...${NC}"
fi
echo ""

# Auto-detect availability domain if not set
if [ -z "$AVAILABILITY_DOMAIN" ]; then
    echo -e "${BLUE}[2/10] Auto-detecting availability domain...${NC}"
    AVAILABILITY_DOMAIN=$(oci iam availability-domain list \
        --compartment-id "$COMPARTMENT_ID" \
        --query 'data[0].name' --raw-output 2>/dev/null || echo "")

    if [ -z "$AVAILABILITY_DOMAIN" ]; then
        echo -e "${RED}Could not auto-detect availability domain.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Using availability domain: $AVAILABILITY_DOMAIN${NC}"
else
    echo -e "${GREEN}✓ Using provided availability domain: $AVAILABILITY_DOMAIN${NC}"
fi
echo ""

# Verify SSH key
echo -e "${BLUE}[3/10] Verifying SSH key...${NC}"
if [ ! -f "$SSH_PUBLIC_KEY" ]; then
    if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        SSH_PUBLIC_KEY="$HOME/.ssh/id_rsa.pub"
        echo -e "${YELLOW}⚠ Using RSA key: $SSH_PUBLIC_KEY${NC}"
    else
        echo -e "${RED}SSH public key not found: $SSH_PUBLIC_KEY${NC}"
        echo "Generate with: ssh-keygen -t ed25519"
        exit 1
    fi
fi
SSH_KEY_CONTENT=$(cat "$SSH_PUBLIC_KEY")
echo -e "${GREEN}✓ SSH key loaded${NC}"
echo ""

# Verify cloud-init file
echo -e "${BLUE}[4/10] Verifying cloud-init configuration...${NC}"
if [ ! -f "$CLOUD_INIT_FILE" ]; then
    echo -e "${RED}Cloud-init file not found: $CLOUD_INIT_FILE${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Cloud-init file found${NC}"
echo ""

# Create or get VCN
echo -e "${BLUE}[5/10] Checking for existing VCN...${NC}"
VCN_ID=$(oci network vcn list \
    --compartment-id "$COMPARTMENT_ID" \
    --display-name "$VCN_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$VCN_ID" ]; then
    echo -e "${YELLOW}⚠ VCN already exists, using existing: ${VCN_ID:0:30}...${NC}"
else
    echo -e "${BLUE}Creating new VCN...${NC}"
    VCN_ID=$(oci network vcn create \
        --compartment-id "$COMPARTMENT_ID" \
        --display-name "$VCN_NAME" \
        --cidr-block "$VCN_CIDR" \
        --dns-label "restaurantmenu" \
        --wait-for-state AVAILABLE \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$VCN_ID" ]; then
        echo -e "${RED}Failed to create VCN${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ VCN created: ${VCN_ID:0:30}...${NC}"
fi
echo ""

# Create or get Internet Gateway
echo -e "${BLUE}[6/10] Checking for existing Internet Gateway...${NC}"
IGW_ID=$(oci network internet-gateway list \
    --compartment-id "$COMPARTMENT_ID" \
    --vcn-id "$VCN_ID" \
    --display-name "$INTERNET_GATEWAY_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$IGW_ID" ]; then
    echo -e "${YELLOW}⚠ Internet Gateway already exists, using existing: ${IGW_ID:0:30}...${NC}"
else
    echo -e "${BLUE}Creating new Internet Gateway...${NC}"
    IGW_ID=$(oci network internet-gateway create \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_ID" \
        --is-enabled true \
        --display-name "$INTERNET_GATEWAY_NAME" \
        --wait-for-state AVAILABLE \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$IGW_ID" ]; then
        echo -e "${RED}Failed to create Internet Gateway${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Internet Gateway created: ${IGW_ID:0:30}...${NC}"
fi
echo ""

# Create or get Route Table
echo -e "${BLUE}[7/10] Checking for existing Route Table...${NC}"
RT_ID=$(oci network route-table list \
    --compartment-id "$COMPARTMENT_ID" \
    --vcn-id "$VCN_ID" \
    --display-name "$ROUTE_TABLE_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$RT_ID" ]; then
    echo -e "${YELLOW}⚠ Route Table already exists, using existing: ${RT_ID:0:30}...${NC}"
else
    echo -e "${BLUE}Creating new Route Table...${NC}"
    RT_ID=$(oci network route-table create \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_ID" \
        --display-name "$ROUTE_TABLE_NAME" \
        --route-rules "[{\"destination\":\"0.0.0.0/0\",\"networkEntityId\":\"$IGW_ID\"}]" \
        --wait-for-state AVAILABLE \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$RT_ID" ]; then
        echo -e "${RED}Failed to create Route Table${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Route Table created: ${RT_ID:0:30}...${NC}"
fi
echo ""

# Create or get Security List
echo -e "${BLUE}[8/10] Checking for existing Security List...${NC}"
SL_ID=$(oci network security-list list \
    --compartment-id "$COMPARTMENT_ID" \
    --vcn-id "$VCN_ID" \
    --display-name "$SECURITY_LIST_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$SL_ID" ]; then
    echo -e "${YELLOW}⚠ Security List already exists, using existing: ${SL_ID:0:30}...${NC}"
else
    echo -e "${BLUE}Creating new Security List...${NC}"

    # Get your public IP for SSH restriction
    MY_PUBLIC_IP=$(curl -s ifconfig.me || echo "0.0.0.0/0")

    SECURITY_RULES=$(cat <<EOF
{
  "ingressSecurityRules": [
    {
      "protocol": "6",
      "source": "$MY_PUBLIC_IP/32",
      "tcpOptions": {
        "destinationPortRange": {
          "max": 22,
          "min": 22
        }
      },
      "description": "SSH from my IP"
    },
    {
      "protocol": "6",
      "source": "0.0.0.0/0",
      "tcpOptions": {
        "destinationPortRange": {
          "max": 80,
          "min": 80
        }
      },
      "description": "HTTP"
    },
    {
      "protocol": "6",
      "source": "0.0.0.0/0",
      "tcpOptions": {
        "destinationPortRange": {
          "max": 443,
          "min": 443
        }
      },
      "description": "HTTPS"
    },
    {
      "protocol": "6",
      "source": "0.0.0.0/0",
      "tcpOptions": {
        "destinationPortRange": {
          "max": 8080,
          "min": 8080
        }
      },
      "description": "Admin API"
    }
  ],
  "egressSecurityRules": [
    {
      "protocol": "all",
      "destination": "0.0.0.0/0",
      "description": "Allow all outbound"
    }
  ]
}
EOF
)

    SL_ID=$(oci network security-list create \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_ID" \
        --display-name "$SECURITY_LIST_NAME" \
        --ingress-security-rules "$(echo $SECURITY_RULES | jq -c '.ingressSecurityRules')" \
        --egress-security-rules "$(echo $SECURITY_RULES | jq -c '.egressSecurityRules')" \
        --wait-for-state AVAILABLE \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$SL_ID" ]; then
        echo -e "${RED}Failed to create Security List${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Security List created: ${SL_ID:0:30}...${NC}"
fi
echo ""

# Create or get Subnet
echo -e "${BLUE}[9/10] Checking for existing Subnet...${NC}"
SUBNET_ID=$(oci network subnet list \
    --compartment-id "$COMPARTMENT_ID" \
    --vcn-id "$VCN_ID" \
    --display-name "$SUBNET_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$SUBNET_ID" ]; then
    echo -e "${YELLOW}⚠ Subnet already exists, using existing: ${SUBNET_ID:0:30}...${NC}"
else
    echo -e "${BLUE}Creating new Subnet...${NC}"
    SUBNET_ID=$(oci network subnet create \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_ID" \
        --availability-domain "$AVAILABILITY_DOMAIN" \
        --display-name "$SUBNET_NAME" \
        --cidr-block "$SUBNET_CIDR" \
        --route-table-id "$RT_ID" \
        --security-list-ids "[\"$SL_ID\"]" \
        --dns-label "subnet" \
        --wait-for-state AVAILABLE \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$SUBNET_ID" ]; then
        echo -e "${RED}Failed to create Subnet${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Subnet created: ${SUBNET_ID:0:30}...${NC}"
fi
echo ""

# Get Oracle Linux 8 ARM64 image
echo -e "${BLUE}[10/10] Finding Oracle Linux 8 ARM64 image...${NC}"
IMAGE_ID=$(oci compute image list \
    --compartment-id "$COMPARTMENT_ID" \
    --operating-system "Oracle Linux" \
    --operating-system-version "8" \
    --shape "$SHAPE" \
    --sort-by TIMECREATED \
    --sort-order DESC \
    --limit 1 \
    --query 'data[0].id' --raw-output 2>/dev/null)

if [ -z "$IMAGE_ID" ]; then
    echo -e "${RED}Could not find Oracle Linux 8 ARM64 image${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Image found: ${IMAGE_ID:0:30}...${NC}"
echo ""

# Create or get Compute Instance
echo -e "${BLUE}[11/10] Checking for existing Compute Instance...${NC}"
INSTANCE_ID=$(oci compute instance list \
    --compartment-id "$COMPARTMENT_ID" \
    --display-name "$INSTANCE_NAME" \
    --query 'data[0].id' --raw-output 2>/dev/null || echo "")

if [ -n "$INSTANCE_ID" ]; then
    INSTANCE_STATE=$(oci compute instance get \
        --instance-id "$INSTANCE_ID" \
        --query 'data."lifecycle-state"' --raw-output 2>/dev/null || echo "")

    echo -e "${YELLOW}⚠ Instance already exists: ${INSTANCE_ID:0:30}...${NC}"
    echo -e "${YELLOW}  State: $INSTANCE_STATE${NC}"

    if [ "$INSTANCE_STATE" != "RUNNING" ]; then
        echo -e "${YELLOW}  Instance is not running. Starting instance...${NC}"
        oci compute instance action \
            --instance-id "$INSTANCE_ID" \
            --action START \
            --wait-for-state RUNNING >/dev/null 2>&1 || true
    fi
else
    echo -e "${BLUE}Creating new Compute Instance...${NC}"
    echo "Configuration:"
    echo "  Shape: $SHAPE"
    echo "  OCPUs: $OCPUS"
    echo "  Memory: ${MEMORY_GB}GB"
    echo ""
    echo "This may take 5-10 minutes..."
    echo ""

    INSTANCE_ID=$(oci compute instance launch \
        --compartment-id "$COMPARTMENT_ID" \
        --availability-domain "$AVAILABILITY_DOMAIN" \
        --shape "$SHAPE" \
        --shape-config "{\"ocpus\":$OCPUS,\"memoryInGBs\":$MEMORY_GB}" \
        --image-id "$IMAGE_ID" \
        --subnet-id "$SUBNET_ID" \
        --display-name "$INSTANCE_NAME" \
        --assign-public-ip true \
        --ssh-authorized-keys-file "$SSH_PUBLIC_KEY" \
        --user-data-file "$CLOUD_INIT_FILE" \
        --boot-volume-size-in-gbs "$BOOT_VOLUME_SIZE_GB" \
        --wait-for-state RUNNING \
        --query 'data.id' --raw-output 2>/dev/null || echo "")

    if [ -z "$INSTANCE_ID" ]; then
        echo -e "${RED}Failed to create instance${NC}"
        echo ""
        echo -e "${YELLOW}Possible reasons:${NC}"
        echo "  1. Out of capacity in availability domain: $AVAILABILITY_DOMAIN"
        echo "  2. Exceeded Always Free tier limits (check existing instances)"
        echo "  3. Service limit reached"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "  - Check existing instances:"
        echo "    oci compute instance list --compartment-id $COMPARTMENT_ID"
        echo "  - Try different availability domain (set AVAILABILITY_DOMAIN in .env)"
        echo "  - Check service limits in OCI Console"
        exit 1
    fi

    echo -e "${GREEN}✓ Instance created: ${INSTANCE_ID:0:30}...${NC}"
fi
echo ""

# Get public IP
echo -e "${BLUE}Getting public IP address...${NC}"
PUBLIC_IP=$(oci compute instance list-vnics \
    --instance-id "$INSTANCE_ID" \
    --query 'data[0]."public-ip"' --raw-output 2>/dev/null)

echo -e "${GREEN}✓ Public IP: $PUBLIC_IP${NC}"
echo ""

# Save instance details
INSTANCE_DETAILS_FILE="$SCRIPT_DIR/../instance-details.txt"
cat > "$INSTANCE_DETAILS_FILE" <<EOF
# Restaurant Menu Admin API - OCI Instance Details
# Created: $(date)

INSTANCE_ID=$INSTANCE_ID
INSTANCE_NAME=$INSTANCE_NAME
PUBLIC_IP=$PUBLIC_IP
COMPARTMENT_ID=$COMPARTMENT_ID
AVAILABILITY_DOMAIN=$AVAILABILITY_DOMAIN
VCN_ID=$VCN_ID
SUBNET_ID=$SUBNET_ID

# SSH Connection
ssh opc@$PUBLIC_IP

# Instance Console
https://cloud.oracle.com/compute/instances/$INSTANCE_ID
EOF

echo -e "${GREEN}✓ Instance details saved to: $INSTANCE_DETAILS_FILE${NC}"
echo ""

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Infrastructure Created Successfully!${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${GREEN}Instance Details:${NC}"
echo "  Name: $INSTANCE_NAME"
echo "  Public IP: $PUBLIC_IP"
echo "  Shape: $SHAPE ($OCPUS OCPUs, ${MEMORY_GB}GB RAM)"
echo ""
echo -e "${YELLOW}Cloud-init is running (10-15 minutes)${NC}"
echo "  Docker, Java, and dependencies are being installed"
echo "  Progress: ssh opc@$PUBLIC_IP 'tail -f /var/log/cloud-init-output.log'"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Wait for cloud-init to complete (~10-15 minutes)"
echo "  2. Verify cloud-init: ssh opc@$PUBLIC_IP 'cat /opt/restaurant-menu-admin/cloud-init-completed.txt'"
echo "  3. Run deployment script: ./03-deploy-application.sh"
echo ""
echo -e "${BLUE}SSH into instance:${NC}"
echo "  ssh opc@$PUBLIC_IP"
echo ""
