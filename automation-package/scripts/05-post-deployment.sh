#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Post Deployment
# Step 5: Complete post-deployment configuration and validation
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "OpenStack Post-Deployment Configuration"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${BLUE}\n========== $1 ==========${NC}\n"
}

# Step 1: Post-deployment configuration
log_section "Step 1: Post-Deployment Configuration"
log_info "Running post-deployment scripts..."
kolla-ansible post-deploy

if [ $? -eq 0 ]; then
    log_info "Post-deployment configuration completed"
else
    log_error "Post-deployment configuration failed"
    exit 1
fi

# Step 2: Verify clouds.yaml
log_section "Step 2: Verifying OpenStack Credentials File"
if [ -f "/etc/kolla/clouds.yaml" ]; then
    log_info "clouds.yaml file found at /etc/kolla/clouds.yaml"
else
    log_error "clouds.yaml not found"
    exit 1
fi

# Step 3: Install OpenStack CLI
log_section "Step 3: Installing OpenStack CLI"
log_info "Installing python-openstackclient..."
sudo pip3 install python-openstackclient

if [ $? -eq 0 ]; then
    log_info "OpenStack CLI installed successfully"
else
    log_error "Failed to install OpenStack CLI"
    exit 1
fi

# Step 4: Source admin credentials
log_section "Step 4: Testing OpenStack Services"
log_info "Sourcing admin OpenStack credentials..."

if [ ! -f "/etc/kolla/admin-openrc.sh" ]; then
    log_error "admin-openrc.sh not found"
    exit 1
fi

source /etc/kolla/admin-openrc.sh

log_info "Testing service list command..."
openstack service list

if [ $? -eq 0 ]; then
    log_info "OpenStack CLI is working correctly"
else
    log_error "OpenStack CLI test failed"
    exit 1
fi

# Step 5: Verify compute services
log_section "Step 5: Verifying Compute Services"
log_info "Listing compute services..."
openstack compute service list

# Step 6: Horizon Dashboard information
log_section "Step 6: Horizon Dashboard Access"
log_info "OpenStack Horizon Dashboard Information:"
log_info "  URL: http://192.168.142.250"
log_info "  Username: admin"
log_info "  Password: (from /etc/kolla/passwords.yml)"
log_info ""
log_info "To retrieve the admin password:"
log_info "  grep keystone_admin_password /etc/kolla/passwords.yml"

# Step 7: Optional demo environment
log_section "Step 7: Optional Demo Environment Setup"
log_info "To setup a demo environment (optional), run:"
log_info "  /usr/local/share/kolla-ansible/init-runonce"

# Final summary
log_section "Post-Deployment Summary"
log_info "============================================"
log_info "Post-deployment configuration completed!"
log_info ""
log_info "OpenStack is now ready for use."
log_info ""
log_info "Key Information:"
log_info "  - Admin credentials: /etc/kolla/admin-openrc.sh"
log_info "  - Passwords file: /etc/kolla/passwords.yml"
log_info "  - Horizon URL: http://192.168.142.250"
log_info "  - Clouds config: /etc/kolla/clouds.yaml"
log_info ""
log_info "For more information, refer to the documentation"
log_info "============================================"

exit 0
