#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Deployment - Install Dependencies
# Step 1: Install all required system packages and dependencies
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "Installing Dependencies for Kolla-Ansible"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Update system packages
log_info "Step 1: Updating system packages..."
sudo dnf update -y
if [ $? -eq 0 ]; then
    log_info "System packages updated successfully"
else
    log_error "Failed to update system packages"
    exit 1
fi

# Step 2: Install Python build dependencies
log_info "Step 2: Installing Python build dependencies..."
sudo dnf install -y \
    git \
    python3-devel \
    libffi-devel \
    gcc \
    openssl-devel \
    python3-libselinux

if [ $? -eq 0 ]; then
    log_info "Python build dependencies installed successfully"
else
    log_error "Failed to install Python build dependencies"
    exit 1
fi

# Step 3: Install Ansible
log_info "Step 3: Installing Ansible-core..."
sudo pip3 install ansible-core

if [ $? -eq 0 ]; then
    log_info "Ansible-core installed successfully"
else
    log_error "Failed to install Ansible-core"
    exit 1
fi

# Step 4: Verify PATH configuration
log_info "Step 4: Verifying PATH configuration..."
if ! echo $PATH | grep -q "/usr/local/bin"; then
    log_warn "PATH does not include /usr/local/bin, updating ~/.bashrc"
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    log_info "PATH updated, please run: source ~/.bashrc"
else
    log_info "PATH is correctly configured"
fi

# Step 5: Verify installations
log_info "Step 5: Verifying installations..."
log_info "Ansible version:"
ansible --version

log_info "Python version:"
python3 --version

log_info "Git version:"
git --version

log_info "============================================"
log_info "Dependencies installation completed!"
log_info "All required packages are ready for deployment"
log_info "============================================"

exit 0
