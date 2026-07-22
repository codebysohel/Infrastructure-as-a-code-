#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Configure Main Files
# Step 3: Configure globals.yml, passwords.yml, and multinode inventory
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "Configuring Main Kolla-Ansible Files"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Verify configuration files exist
if [ ! -f "/etc/kolla/globals.yml" ]; then
    log_error "globals.yml not found. Please run 02-install-kolla-ansible.sh first"
    exit 1
fi

# Step 1: Backup original globals.yml
log_info "Step 1: Creating backup of original globals.yml..."
sudo cp /etc/kolla/globals.yml /etc/kolla/globals.yml.backup
log_info "Backup created at /etc/kolla/globals.yml.backup"

# Step 2: Generate passwords
log_info "Step 2: Generating random passwords..."
kolla-genpwd

if [ $? -eq 0 ]; then
    log_info "Passwords generated successfully in /etc/kolla/passwords.yml"
else
    log_error "Failed to generate passwords"
    exit 1
fi

# Step 3: Update multinode inventory file
log_info "Step 3: Verifying multinode inventory configuration..."

if [ ! -f "./multinode" ]; then
    log_error "multinode file not found in current directory"
    exit 1
fi

log_info "Multinode inventory file is ready for deployment"
log_info "Inventory location: ./multinode"

# Step 4: Display configuration summary
log_info "Step 4: Configuration summary..."
log_info "============================================"
log_info "Main configuration files:"
log_info "  - globals.yml: /etc/kolla/globals.yml"
log_info "  - passwords.yml: /etc/kolla/passwords.yml"
log_info "  - multinode inventory: ./multinode"
log_info "============================================"
log_info "Please ensure the following before proceeding:"
log_info "  1. Review and customize globals.yml if needed"
log_info "  2. Verify all node hostnames in multinode inventory"
log_info "  3. Ensure SSH connectivity to all nodes"
log_info "  4. Backup passwords.yml in a secure location"
log_info "============================================"

exit 0
