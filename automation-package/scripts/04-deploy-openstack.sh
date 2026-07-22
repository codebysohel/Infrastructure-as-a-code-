#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Deploy OpenStack
# Step 4: Execute full Kolla-Ansible deployment
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "Deploying OpenStack with Kolla-Ansible"
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

# Verify prerequisites
log_section "Verifying Prerequisites"

if [ ! -f "/etc/kolla/globals.yml" ]; then
    log_error "globals.yml not found. Please run configuration scripts first"
    exit 1
fi

if [ ! -f "/etc/kolla/passwords.yml" ]; then
    log_error "passwords.yml not found. Please run configuration scripts first"
    exit 1
fi

if [ ! -f "./multinode" ]; then
    log_error "multinode inventory not found. Please run configuration scripts first"
    exit 1
fi

log_info "All prerequisites verified"

# Step 1: Bootstrap servers
log_section "Step 1: Bootstrap Servers"
log_info "Bootstrapping all OpenStack nodes..."
log_warn "This step may take several minutes..."
kolla-ansible bootstrap-servers -i ./multinode

if [ $? -eq 0 ]; then
    log_info "Servers bootstrapped successfully"
else
    log_error "Failed to bootstrap servers"
    exit 1
fi

# Step 2: Run pre-deployment checks
log_section "Step 2: Pre-deployment Checks"
log_info "Running pre-deployment validation checks..."
log_warn "This step verifies all nodes and configuration..."
kolla-ansible prechecks -i ./multinode

if [ $? -eq 0 ]; then
    log_info "Pre-deployment checks passed"
else
    log_error "Pre-deployment checks failed. Please review the output above"
    exit 1
fi

# Step 3: Deploy OpenStack
log_section "Step 3: Deploy OpenStack Services"
log_info "Starting OpenStack deployment..."
log_warn "This is the longest step and may take 30-60 minutes depending on network and hardware..."
kolla-ansible deploy -i ./multinode

if [ $? -eq 0 ]; then
    log_info "OpenStack deployment completed successfully"
else
    log_error "OpenStack deployment failed. Please review the logs"
    exit 1
fi

# Step 4: Validate configuration
log_section "Step 4: Validate Configuration"
log_info "Validating OpenStack service configurations..."
kolla-ansible validate-config -i ./multinode

if [ $? -eq 0 ]; then
    log_info "Configuration validation passed"
else
    log_warn "Configuration validation completed with warnings. Please review above"
fi

# Summary
log_section "Deployment Summary"
log_info "============================================"
log_info "OpenStack deployment completed!"
log_info "\nNext steps:"
log_info "  1. Run: kolla-ansible post-deploy"
log_info "  2. Source OpenStack credentials: source /etc/kolla/admin-openrc.sh"
log_info "  3. Access Horizon Dashboard: http://192.168.142.250"
log_info "  4. Verify services: openstack service list"
log_info "============================================"

exit 0
