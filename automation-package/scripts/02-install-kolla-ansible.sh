#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Install Kolla-Ansible
# Step 2: Install Kolla-Ansible and required dependencies
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "Installing Kolla-Ansible"
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

# Step 1: Install kolla-ansible via pip
log_info "Step 1: Installing kolla-ansible via pip3..."
sudo pip3 install kolla-ansible

if [ $? -eq 0 ]; then
    log_info "kolla-ansible installed successfully"
else
    log_error "Failed to install kolla-ansible"
    exit 1
fi

# Step 2: Create configuration directory
log_info "Step 2: Creating Kolla configuration directory..."
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

if [ $? -eq 0 ]; then
    log_info "Kolla configuration directory created at /etc/kolla"
else
    log_error "Failed to create configuration directory"
    exit 1
fi

# Step 3: Copy example configuration files
log_info "Step 3: Copying example Kolla configuration files..."
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/

if [ $? -eq 0 ]; then
    log_info "Configuration files copied successfully"
else
    log_error "Failed to copy configuration files"
    exit 1
fi

# Step 4: Copy multinode inventory file
log_info "Step 4: Copying multinode inventory file..."
cp /usr/local/share/kolla-ansible/ansible/inventory/multinode ./multinode

if [ $? -eq 0 ]; then
    log_info "Multinode inventory file copied to current directory"
else
    log_error "Failed to copy multinode inventory file"
    exit 1
fi

# Step 5: Install Ansible Galaxy dependencies
log_info "Step 5: Installing Ansible Galaxy dependencies..."
kolla-ansible install-deps

if [ $? -eq 0 ]; then
    log_info "Ansible Galaxy dependencies installed successfully"
else
    log_error "Failed to install Galaxy dependencies"
    exit 1
fi

# Step 6: Verify installation
log_info "Step 6: Verifying Kolla-Ansible installation..."
kolla-ansible --version

log_info "============================================"
log_info "Kolla-Ansible installation completed!"
log_info "Configuration directory: /etc/kolla"
log_info "Inventory file location: ./multinode"
log_info "============================================"

exit 0
