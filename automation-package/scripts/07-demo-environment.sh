#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Demo Environment Setup
# Optional: Setup demo project, networks, and instance
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "Setting Up OpenStack Demo Environment"
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

# Verify admin credentials
log_section "Verifying Admin Credentials"

if [ ! -f "/etc/kolla/admin-openrc.sh" ]; then
    log_error "admin-openrc.sh not found. Please run post-deployment script first"
    exit 1
fi

source /etc/kolla/admin-openrc.sh
log_info "Admin credentials loaded"

# Run init-runonce script
log_section "Running Init-RunOnce Demo Setup"

if [ -f "/usr/local/share/kolla-ansible/init-runonce" ]; then
    log_info "Running init-runonce script..."
    bash /usr/local/share/kolla-ansible/init-runonce
    
    if [ $? -eq 0 ]; then
        log_info "Demo environment setup completed successfully"
    else
        log_error "Demo environment setup encountered issues"
        exit 1
    fi
else
    log_error "init-runonce script not found"
    exit 1
fi

# Verification
log_section "Demo Environment Verification"

log_info "Listing available networks..."
openstack network list

log_info ""
log_info "Listing available images..."
openstack image list

log_info ""
log_info "Listing flavors..."
openstack flavor list

# Summary
log_section "Demo Environment Setup Complete"

log_info "============================================"
log_info "Demo environment has been configured!"
log_info ""
log_info "Demo Resources Created:"
log_info "  - demo project"
log_info "  - demo network and subnet"
log_info "  - demo router (if external network available)"
log_info "  - demo security group"
log_info "  - cirros image for testing"
log_info ""
log_info "Next Steps:"
log_info "  1. Access Horizon: http://192.168.142.250"
log_info "  2. Create instances using demo project"
log_info "  3. Test VM creation and networking"
log_info ""
log_info "============================================"

exit 0
