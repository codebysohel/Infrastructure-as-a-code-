# OpenStack High Availability Deployment Guide
## Using Kolla-Ansible Automation Scripts

### Overview

This package contains comprehensive automation scripts for deploying a highly available OpenStack environment using Kolla-Ansible on Rocky Linux 9.

### Architecture

**Cluster Nodes:**
- **Controllers (3):** controller01, controller02, controller03 (192.168.142.141-143)
- **Compute (2):** compute01, compute02 (192.168.142.151-152)
- **Network (2):** network01, network02 (192.168.142.161-162)
- **Storage (2):** storage01, storage02 (192.168.142.171-172)

**VIP (Virtual IP):** 192.168.142.250

### Prerequisites

1. All nodes running Rocky Linux 9.4
2. kolla user created on all nodes
3. SSH key-based authentication configured
4. /etc/hosts configured with all node entries
5. Static IP addresses assigned to all nodes
6. Storage nodes configured with LVM volume group (cinder-volumes)
7. Network connectivity between all nodes

### Quick Start

#### Option 1: Run Complete Deployment (Automated)

```bash
cd automation-package
bash scripts/06-master-automation.sh
```

This will execute all phases sequentially with interactive prompts between phases.

#### Option 2: Run Individual Phases

```bash
cd automation-package/scripts

# Phase 1: Install Dependencies
bash 01-install-dependencies.sh

# Phase 2: Install Kolla-Ansible
bash 02-install-kolla-ansible.sh

# Phase 3: Configure Main Files
bash 03-configure-main-files.sh

# Phase 4: Deploy OpenStack
bash 04-deploy-openstack.sh

# Phase 5: Post-Deployment Setup
bash 05-post-deployment.sh

# Optional: Demo Environment
bash 07-demo-environment.sh
```

### Configuration

**Key Configuration Files:**

1. **globals.yml** - Main OpenStack configuration
   - Location: `/etc/kolla/globals.yml`
   - Controls services, networking, storage, monitoring settings

2. **passwords.yml** - Service passwords
   - Location: `/etc/kolla/passwords.yml`
   - Auto-generated, should be kept secure

3. **multinode** - Inventory file
   - Location: `./multinode`
   - Defines node roles and grouping

### Deployment Phases

**Phase 1: Install Dependencies**
- Updates system packages
- Installs Python development tools
- Installs Ansible-core
- Configures PATH

**Phase 2: Install Kolla-Ansible**
- Installs kolla-ansible package
- Creates /etc/kolla directory
- Copies configuration templates
- Installs Ansible Galaxy dependencies

**Phase 3: Configure Main Files**
- Backs up original configurations
- Generates random passwords
- Verifies inventory configuration

**Phase 4: Deploy OpenStack**
- Bootstraps all servers
- Runs pre-deployment checks
- Deploys OpenStack services
- Validates configuration

**Phase 5: Post-Deployment**
- Runs post-deployment scripts
- Installs OpenStack CLI
- Verifies services
- Provides access information

### Post-Deployment

**Access Horizon Dashboard:**
- URL: http://192.168.142.250
- Username: admin
- Password: (from `/etc/kolla/passwords.yml`)

**Using OpenStack CLI:**

```bash
# Source admin credentials
source /etc/kolla/admin-openrc.sh

# List services
openstack service list

# Check compute services
openstack compute service list

# List images
openstack image list
```

### Troubleshooting

**Check Service Status:**

```bash
# On any controller node
docker ps | grep kolla

# Check specific service
docker logs <service_name>
```

**Verify Connectivity:**

```bash
# From deployment node
for host in controller01 controller02 controller03 compute01 compute02 network01 network02 storage01 storage02; do
  ping -c 1 $host
done
```

**Check HAProxy Status:**

```bash
# SSH to any controller node
ssh kolla@controller01
docker exec -it haproxy haproxy -c -f /etc/haproxy/haproxy.cfg
```

### Security Considerations

1. **Backup passwords.yml** in a secure location
2. **Change default passwords** after deployment
3. **Use VPN or private networks** for management traffic
4. **Configure firewall rules** appropriately
5. **Enable SSL/TLS** for API endpoints
6. **Regularly update** base images and packages

### Performance Tuning

- **Adjust memory limits** in globals.yml for resource-constrained environments
- **Enable caching** for frequently accessed data
- **Optimize network** MTU settings
- **Monitor resource usage** on all nodes

### Additional Resources

- OpenStack Documentation: https://docs.openstack.org
- Kolla Documentation: https://docs.openstack.org/kolla-ansible/latest
- Rocky Linux Documentation: https://rockylinux.org/documentation

### Support

For issues or questions:
1. Check the logs in `/var/lib/kolla`
2. Review error messages in script output
3. Consult OpenStack and Kolla documentation
4. Check network connectivity between nodes

---

Last Updated: 2024
Version: 1.0
