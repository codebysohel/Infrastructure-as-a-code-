#!/bin/bash

################################################################################
# OpenStack Kolla-Ansible Master Automation Script
# Complete end-to-end deployment orchestration
# Execution Node: controller01 (Deployment Host)
################################################################################

set -e

echo "========================================="
echo "OpenStack HA Deployment - Master Automation"
echo "========================================="
echo ""

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
    echo -e "${BLUE}\n=== $1 ===${NC}\n"
}

# Function to execute a deployment phase
execute_phase() {
    local phase_num=$1
    local phase_name=$2
    local script=$3
    
    log_section "PHASE $phase_num: $phase_name"
    
    if [ -f "$script" ]; then
        bash "$script"
        if [ $? -eq 0 ]; then
            log_info "Phase $phase_num completed successfully"
        else
            log_error "Phase $phase_num failed. Aborting deployment."
            exit 1
        fi
    else
        log_error "Script not found: $script"
        exit 1
    fi
    
    # Wait between phases
    echo ""
    read -p "Press Enter to continue to next phase..."
}

# Pre-deployment checks
log_section "Pre-Deployment Checks"

log_info "Checking if running as kolla user..."
if [ "$USER" != "kolla" ]; then
    log_warn "Current user is $USER. It's recommended to run as 'kolla' user."
fi

log_info "Checking network connectivity..."
for host in controller01 controller02 controller03 compute01 compute02 network01 network02 storage01 storage02; do
    if ping -c 1 $host >/dev/null 2>&1; then
        log_info "  $host: OK"
    else
        log_warn "  $host: Not reachable from this node"
    fi
done

log_info "All pre-deployment checks completed"

# Deployment phases
log_section "Starting Full Deployment"

execute_phase 1 "Install Dependencies" "./scripts/01-install-dependencies.sh"
execute_phase 2 "Install Kolla-Ansible" "./scripts/02-install-kolla-ansible.sh"
execute_phase 3 "Configure Main Files" "./scripts/03-configure-main-files.sh"
execute_phase 4 "Deploy OpenStack" "./scripts/04-deploy-openstack.sh"
execute_phase 5 "Post-Deployment Setup" "./scripts/05-post-deployment.sh"

# Final summary
log_section "Deployment Completed Successfully"

log_info "============================================"
log_info "All deployment phases completed!"
log_info ""
log_info "OpenStack Deployment Summary:"
log_info "  - Base OS: Rocky Linux 9"
log_info "  - OpenStack Version: 2024.2"
log_info "  - Deployment Tool: Kolla-Ansible"
log_info "  - Container Engine: Docker"
log_info ""
log_info "Cluster Nodes:"
log_info "  - Controllers: controller01, controller02, controller03"
log_info "  - Compute: compute01, compute02"
log_info "  - Network: network01, network02"
log_info "  - Storage: storage01, storage02"
log_info ""
log_info "Access Information:"
log_info "  - Horizon Dashboard: http://192.168.142.250"
log_info "  - Admin credentials: /etc/kolla/admin-openrc.sh"
log_info "  - Passwords: /etc/kolla/passwords.yml"
log_info ""
log_info "============================================"
log_info "Thank you for using this deployment script!"
log_info "============================================"

exit 0
