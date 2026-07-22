# High Availability OpenStack Deployment Using Kolla-Ansible
## Complete Automation Package with AI Orchestration

<p align="center">
  <img src="images/OpenStack_Logo.png" alt="OpenStack Logo" width="500"/>
</p>

## 📋 Package Overview

This comprehensive package contains everything needed to deploy a highly available (HA) OpenStack environment using Kolla-Ansible on Rocky Linux 9, with AI-powered orchestration capabilities. It includes automated scripts, configuration templates, and detailed documentation.

## 🚀 Quick Start

### Fastest Way to Deploy

```bash
# Extract the package
git clone https://github.com/codebysohel/High-Availaiblity-OpenStack-AI-Orchestrator-using-Kolla-Ansible.git
cd automation-package

# Run the master automation script
bash scripts/06-master-automation.sh
```

## 📁 Package Structure

```
automation-package/
├── scripts/
│   ├── 01-install-dependencies.sh      # Install system dependencies
│   ├── 02-install-kolla-ansible.sh     # Install Kolla-Ansible
│   ├── 03-configure-main-files.sh      # Configure settings
│   ├── 04-deploy-openstack.sh          # Deploy OpenStack
│   ├── 05-post-deployment.sh           # Post-deployment setup
│   ├── 06-master-automation.sh         # Master orchestration script
│   └── 07-demo-environment.sh          # Optional demo setup
├── configs/
│   ├── globals.yml                     # OpenStack configuration
│   └── multinode-inventory             # Ansible inventory
├── docs/
│   ├── DEPLOYMENT_GUIDE.md             # Detailed deployment guide
│   └── TROUBLESHOOTING.md              # Troubleshooting reference
└── README.md                           # This file
```

## 🎯 Deployment Options

### Option 1: Automated Full Deployment (Recommended)

```bash
cd automation-package
bash scripts/06-master-automation.sh
```

**Features:**
- Interactive prompts between phases
- Automatic error handling
- Network connectivity verification
- Comprehensive logging

### Option 2: Step-by-Step Deployment

```bash
cd automation-package/scripts

# Run each phase individually
bash 01-install-dependencies.sh
bash 02-install-kolla-ansible.sh
bash 03-configure-main-files.sh
bash 04-deploy-openstack.sh
bash 05-post-deployment.sh

# Optional: Setup demo environment
bash 07-demo-environment.sh
```

## 🏗️ Cluster Architecture

### Nodes Configuration

| Hostname    | Role              | IP Address      | vCPU | RAM  | Storage |
|-------------|-------------------|-----------------|------|------|----------|
| controller01 | Controller (HA)   | 192.168.142.141 | 2    | 8GB  | 40GB    |
| controller02 | Controller (HA)   | 192.168.142.142 | 2    | 8GB  | 40GB    |
| controller03 | Controller (HA)   | 192.168.142.143 | 2    | 8GB  | 40GB    |
| compute01   | Compute           | 192.168.142.151 | 2    | 8GB  | 40GB    |
| compute02   | Compute           | 192.168.142.152 | 2    | 8GB  | 40GB    |
| network01   | Network           | 192.168.142.161 | 2    | 8GB  | 40GB    |
| network02   | Network           | 192.168.142.162 | 2    | 8GB  | 40GB    |
| storage01   | Storage (Cinder)  | 192.168.142.171 | 2    | 8GB  | 40GB+10GB |
| storage02   | Storage (Cinder)  | 192.168.142.172 | 2    | 8GB  | 40GB+10GB |

**Virtual IP (VIP):** 192.168.142.250 (For HA access)

## 📋 Prerequisites

### System Requirements
- **OS:** Rocky Linux 9.4 or later
- **User:** `kolla` user created on all nodes
- **Network:** All nodes must be able to reach each other
- **Storage:** Additional disk for storage nodes (for Cinder LVM)

### Network Setup
- **ens160:** Internal/management network
- **ens192:** External network (for floating IPs)
- **Static IPs:** All nodes must have static IP addresses
- **/etc/hosts:** Configured with all node entries

### SSH Configuration
- SSH key-based authentication between nodes
- Passwordless sudo for `kolla` user
- SSH keys copied to all nodes

## 🔧 Configuration

### Key Files to Review

**1. globals.yml** - Main OpenStack configuration
- Located in `configs/globals.yml` or `/etc/kolla/globals.yml`
- Controls enabled services, networking, storage, monitoring
- Customize before deployment if needed

**2. multinode-inventory** - Ansible inventory
- Located in `configs/multinode-inventory` or `./multinode`
- Defines node roles (controllers, compute, network, storage)
- Update with your actual node hostnames/IPs

**3. passwords.yml** - Service passwords
- Auto-generated during deployment
- Keep secure and backed up
- Located at `/etc/kolla/passwords.yml`

## 📊 Deployment Phases

### Phase 1: Install Dependencies
- Updates system packages
- Installs Python development tools
- Installs Ansible-core
- Configures environment PATH

**Duration:** 5-10 minutes

### Phase 2: Install Kolla-Ansible
- Installs kolla-ansible package
- Creates /etc/kolla configuration directory
- Copies configuration templates
- Installs Ansible Galaxy dependencies

**Duration:** 10-15 minutes

### Phase 3: Configure Main Files
- Backs up original configurations
- Generates random service passwords
- Verifies inventory configuration
- Creates configuration directory structure

**Duration:** 2-5 minutes

### Phase 4: Deploy OpenStack
- **Bootstrap:** Prepares all nodes with required packages
- **Prechecks:** Validates network, resources, and configuration
- **Deploy:** Deploys all OpenStack services using Docker
- **Validate:** Verifies service configuration

**Duration:** 30-60 minutes (depending on hardware and network)

### Phase 5: Post-Deployment
- Runs post-deployment configuration
- Installs OpenStack CLI tools
- Verifies service connectivity
- Provides access information

**Duration:** 5-10 minutes

## 🌐 Post-Deployment Access

### Horizon Dashboard (Web UI)
```
URL: http://192.168.142.250
Username: admin
Password: [from /etc/kolla/passwords.yml]
```

To retrieve admin password:
```bash
grep keystone_admin_password /etc/kolla/passwords.yml
```

### OpenStack CLI
```bash
# Source admin credentials
source /etc/kolla/admin-openrc.sh

# List services
openstack service list

# Check compute services
openstack compute service list

# List images
openstack image list

# List compute nodes
openstack hypervisor list
```

## 🛠️ Configuration Customization

### Edit globals.yml Before Deployment

```bash
# Before running scripts
nano automation-package/configs/globals.yml

# Or during deployment at
nano /etc/kolla/globals.yml
```

### Common Customizations

**Enable/Disable Services:**
```yaml
enable_cinder: "yes"           # Block storage
enable_horizon: "yes"          # Web dashboard
enable_prometheus: "yes"       # Monitoring
enable_grafana: "yes"         # Dashboards
```

**Network Configuration:**
```yaml
network_interface: "ens160"    # Management network
neutron_external_interface: "ens192"  # External network
kolla_internal_vip_address: "192.168.142.250"  # Virtual IP
```

## 📚 Documentation

### DEPLOYMENT_GUIDE.md
Comprehensive guide covering:
- Architecture overview
- Prerequisites detailed explanation
- Configuration details
- Post-deployment operations
- Security considerations
- Performance tuning

### TROUBLESHOOTING.md
Solutions for common issues:
- SSH connection problems
- Hostname resolution
- Docker/container issues
- Database synchronization
- Network configuration
- Service startup failures
- Performance issues

## ⚡ Performance Tips

1. **Use SSD storage** for best performance
2. **Adequate RAM** - At least 4GB per node minimum
3. **Network MTU** - Set to 1500 or higher
4. **Disable swap** during deployment if possible
5. **Monitor resources** with Docker stats

## 🔐 Security Best Practices

1. **Backup passwords.yml** in a secure location
2. **Change default passwords** after deployment
3. **Use VPN** for management network
4. **Configure firewall** appropriately
5. **Enable SSL/TLS** for API endpoints
6. **Regular updates** of base images

## 🚨 Troubleshooting

If deployment fails:

1. **Check logs:**
   ```bash
   /var/lib/kolla/  # Service logs
   docker logs <service_name>
   ```

2. **Verify connectivity:**
   ```bash
   ping <node_ip>
   ssh kolla@<node_ip>
   ```

3. **Check resources:**
   ```bash
   df -h  # Disk space
   free -h  # Memory
   docker stats  # Container resources
   ```

4. **Review TROUBLESHOOTING.md** for detailed solutions

## 📞 Support Resources

- **OpenStack Docs:** https://docs.openstack.org
- **Kolla Docs:** https://docs.openstack.org/kolla-ansible/latest
- **Rocky Linux:** https://rockylinux.org/documentation

## 🎓 What You'll Learn

After completing this deployment, you'll understand:
- OpenStack architecture and components
- Kolla containerized deployment
- Ansible orchestration
- High availability cluster setup
- Docker and container management
- Cloud infrastructure deployment
- AI-powered orchestration concepts

## 📋 Deployment Checklist

### Before Deployment
- [ ] All nodes running Rocky Linux 9.4
- [ ] `kolla` user created on all nodes
- [ ] SSH key-based authentication configured
- [ ] `/etc/hosts` configured on all nodes
- [ ] Static IPs assigned to all nodes
- [ ] Network connectivity verified
- [ ] Storage nodes have LVM configured
- [ ] Sufficient disk space on all nodes
- [ ] At least 8GB RAM on each node

### During Deployment
- [ ] Monitor Phase 1 completion
- [ ] Monitor Phase 2 completion
- [ ] Review configuration in Phase 3
- [ ] Monitor Phase 4 (takes 30-60 minutes)
- [ ] Verify Phase 5 completion

### After Deployment
- [ ] Access Horizon dashboard
- [ ] Test OpenStack CLI commands
- [ ] Verify all services are running
- [ ] Create test network and instance
- [ ] Backup passwords.yml file
- [ ] Review HAProxy/Keepalived status

## 📝 Version Information

- **Package Version:** 1.0
- **OpenStack Version:** 2024.2
- **Rocky Linux:** 9.4
- **Kolla-Ansible:** Latest
- **Created:** 2024

## 📜 License and Attribution

This deployment package is based on the official OpenStack and Kolla-Ansible documentation.

For the original documentation, visit:
- https://docs.openstack.org
- https://docs.openstack.org/kolla-ansible/latest

## 🆘 Getting Help

If you encounter issues:

1. **Check the TROUBLESHOOTING.md** guide first
2. **Review deployment logs** in `/var/lib/kolla/`
3. **Verify network connectivity** between nodes
4. **Consult OpenStack documentation**
5. **Check Kolla-Ansible documentation**

---

**Happy Deploying! 🚀**

For questions or improvements to this package, please refer to the documentation files included.
