# High Availability OpenStack Deployment Using Kolla-Ansible
## Complete Automation Package with AI Orchestration

<p align="center">
  <img src="images/OpenStack_Logo.png" alt="OpenStack Logo" width="500"/>
</p>


## 🧱 Environment Overview

- The deployment was performed in a virtualized lab using VMWare Workstation. 
- One base virtual machine (VM) was created and then cloned to spawn additional nodes with the appropriate roles assigned.
- All VMs run **Rocky Linux 9.4** and share the same hardware specs initially, with modifications based on the role.

> 📥 **Download Rocky Linux 9.4 ISO**:  
> [https://rockylinux.org/download](https://rockylinux.org/download)
---

## 🧩 Roles of Each Node in the OpenStack Deployment

This section describes the specific responsibilities and key services hosted on each node type within the HA OpenStack cluster.


### 🧠 Controller Node

**Primary Role:**  
The "brain" of the OpenStack cluster.

**Key Services:**
- `Keystone`: Identity management
- `Glance`: Image storage for VMs
- `Nova API`: Compute API endpoints
- `Horizon`: Web dashboard interface
- `MariaDB/Galera`: Highly available database cluster
- `RabbitMQ`: Message queuing between OpenStack services

**Responsibility:**  
Handles orchestration, authentication, database operations, and API endpoints for all OpenStack components.

---

### 🧮 Compute Node

**Primary Role:**  
Runs virtual machines (VMs) and provides compute resources.

**Key Services:**
- `Nova Compute`: Manages VM lifecycle (create, delete, migrate, etc.)
- `Libvirt/KVM`: Hypervisor interface to run VMs

**Responsibility:**  
Provides vCPUs, RAM, and local storage for VMs. Compute nodes scale horizontally — adding more nodes increases cluster capacity.

---

### 🌐 Network Node

**Primary Role:**  
Manages all networking components of the OpenStack environment.

**Key Services:**
- `Neutron`: Networking service (routers, subnets, floating IPs)
- `L3 Agent`: Routing and NAT for VM networks
- `DHCP Agent`: Dynamic IP assignment to VMs
- `OVS` / `LinuxBridge`: Virtual switch to connect instances

**Responsibility:**  
Ensures full VM connectivity, external access, router/NAT functionality, and applies security group rules.

---

### 💾 Storage Node

**Primary Role:**  
Provides persistent storage to VMs (and optionally object storage).

**Key Services:**
- `Cinder Volume`: Block storage for VMs using LVM as the backend
- *(Optional)* `Swift`: Object storage (not enabled in this deployment)

**Responsibility:**  
Manages volumes, snapshots, and backups. In our setup, LVM aggregates additional disks into a single volume group (`cinder-volumes`) for dynamic block provisioning.


---

## 🖥️ Deployment Architecture

This section outlines the architecture of the OpenStack HA deployment, including the roles assigned to each node, their hardware specifications, and how they are organized to ensure scalability, high availability, and separation of concerns.


| Hostname     | Role                 | IPv4            | vCPU | RAM (GB) | Storage (GB)  | Notes                       |
|--------------|----------------------|-----------------|------|----------|---------------|-----------------------------|
| controller01 | Controller Node      | 192.168.142.141 | 2    | 8        | 40            | Also used to deploy Kolla   |
| controller02 | Controller Node      | 192.168.142.142 | 2    | 8        | 40            |                             |
| controller03 | Controller Node      | 192.168.142.143 | 2    | 8        | 40            |                             |
| compute01    | Compute Node         | 192.168.142.151 | 2    | 8        | 40            | Virtualization enabled      |
| compute02    | Compute Node         | 192.168.142.152 | 2    | 8        | 40            | Virtualization enabled      |
| network01    | Network Node         | 192.168.142.161 | 2    | 8        | 40            |                             |
| network02    | Network Node         | 192.168.142.162 | 2    | 8        | 40            |                             |
| storage01    | Storage (Cinder LVM) | 192.168.142.171 | 2    | 8        | 40 (+10 GB)   | LVM volume for Cinder       |
| storage02    | Storage (Cinder LVM) | 192.168.142.172 | 2    | 8        | 40 (+10 GB)   | LVM volume for Cinder       |

> 📌 **Note:** Each VM was cloned from `controller01` and then customized (hostname, static IP, NICs, etc.).

---

## 🔧 VM Networking

Each VM includes at least two network interfaces:

- `ens160`: Internal/OpenStack management network
- `ens192`: External network for floating IPs and external access

NIC names may vary depending on the hypervisor configuration.

> ⚠️ **Reminder:** Always confirm NIC names using `ip a` after VM creation.


## ⚙️ VM Creation and OS Configuration

This section covers the step-by-step creation of the base Rocky Linux VM, cloning it to form the OpenStack cluster, OS preparation, static IP setup, and SSH key configuration.


### 🖥️ Creating and Installing Base Rocky Linux VM

1. **Create a virtual machine** named `controller01` which will serve as the base image.  
   It will be cloned later to create other nodes, and each clone will be customized.
2. Create the VM using the previously specified hardware (e.g., 2 vCPUs, 8 GB RAM, 40 GB disk).

![Screenshot 1](images/pic1.png)

3. **Add another NIC** to the VM to support internal and external network separation.

![Screenshot 2](images/pic2.png)

![Screenshot 3](images/pic3.png)

![Screenshot 4](images/pic4.png)

4. Confirm the final specifications before finishing the setup.

![Screenshot 5](images/pic5.png)

5. Start the VM and begin installing **Rocky Linux 9.4**.

![Screenshot 6](images/pic6.png)

6. Choose your preferred installation language.

![Screenshot 7](images/pic7.png)

7. Configure installation settings:
   - Partitioning
   - Networking
   - Time zone
   - User creation

![Screenshot 8](images/pic8.png)

8. **Create a user named `kolla`** to be used for Kolla Ansible deployment.


9.  **Network Configuration:**
   - Keep **DHCP enabled** on the first NIC (we’ll assign a static IP later).
   - **Disable IPv4** on the second NIC (e.g., `ens192`).

![Screenshot 9](images/pic9.png)

![Screenshot 10](images/pic10.png)

   - Disable → Enable the NIC to apply settings.

![Screenshot 11](images/pic11.png)

10.  Finish configuration and begin the OS installation.

![Screenshot 12](images/pic12.png)

11.  After reboot, log in as `root` and update the system: 
   ```bash
   sudo dnf update -y
   ```

![Screenshot 13](images/pic13.png)

12.  Add the `kolla` user to the `wheel` group:
   ```bash
   usermod -aG wheel kolla
   grep wheel /etc/group
   ```

![Screenshot 14](images/pic14.png)

13.  Edit the sudoers file to allow passwordless sudo for the `wheel` group:
    
   ```bash
   visudo
   ```
    
   - Find:
   
   ```bash
   %wheel  ALL=(ALL)       ALL
   ```
   
   - Comment that line and uncomment:
   ```bash
   %wheel  ALL=(ALL)       NOPASSWD: ALL
   ```

![Screenshot 15](images/pic15.png)

---

### 📦 Cloning the Base VM

1. Shut down the base VM (`controller01`) before cloning.
2. Use **full independent clone** option.

![Screenshot 16](images/pic16.png)

![Screenshot 17](images/pic17.png)

![Screenshot 18](images/pic18.png)

![Screenshot 19](images/pic19.png)

3. Repeat the process to create the full architecture:
   - `controller02`, `controller03`, `compute01`, `compute02`, `network01`, `network02`, `storage01`, `storage02`.

![Screenshot 20](images/pic20.png)

---

### 🧾 Configure Hostname and Static IP for All VMs

Each VM needs a **unique hostname** and **static IP**.

1. Set the hostname:
    ```bash
    sudo hostnamectl set-hostname <hostname>
    ```
2. Validate:
    ```bash
    hostname
    ```

![Screenshot 21](images/pic21.png)

3. Set static IP for `ens160`:
    ```bash
    nmcli device status
    ```

![Screenshot 22](images/pic22.png)

  ```bash
  sudo nmcli con mod ens160 ipv4.addresses 192.168.142.141/24
  sudo nmcli con mod ens160 ipv4.gateway 192.168.142.2
  sudo nmcli con mod ens160 ipv4.dns 192.168.142.2
  sudo nmcli con mod ens160 ipv4.method manual
  ```

![Screenshot 23](images/pic23.png)

  ```bash
  sudo nmcli con down ens160 && sudo nmcli con up ens160
  ip a show ens160
  ```

![Screenshot 26](images/pic26.png)

Repeat for each VM with appropriate IP and hostname.

---

### 📁 Configure `/etc/hosts` on `controller01`

- This node will act as the Kolla-Ansible deployment host. 
- This file ensures all nodes in the cluster can be referenced by hostname during the Kolla Ansible deployment.
- DNS entries in other nodes will be taken care by Ansible.


1. Open the hosts file:
    ```bash
    sudo nano /etc/hosts
    ```

![Screenshot 27](images/pic27.png)

2. Add these entries:
    ```text
    192.168.142.141 controller01
    192.168.142.142 controller02
    192.168.142.143 controller03
    192.168.142.151 compute01
    192.168.142.152 compute02
    192.168.142.161 network01
    192.168.142.162 network02
    192.168.142.171 storage01
    192.168.142.172 storage02
    ```

![Screenshot 28](images/pic28.png)

3. Test reachability:
    ```bash
    for host in controller01 controller02 controller03 compute01 compute02 network01 network02 storage01 storage02; do
      ping -c 1 $host >/dev/null && echo "$host is reachable" || echo "$host is NOT reachable"
    done
    ```

![Screenshot 29](images/pic29.png)

---

### 🧬 Enable Virtualization on Compute VMs

1. Open VM settings for each **compute node**.

![Screenshot 30](images/pic30.png)

2. Enable virtualization in the hardware settings.

![Screenshot 31](images/pic31.png)

3. Repeat for `compute02`.

---

### 💽 Attach New Disk to Storage VMs (for Cinder LVM)

1. Add a new virtual disk (20GB or more) to each **storage node**.

![Screenshot 32](images/pic32.png)

![Screenshot 33](images/pic33.png)

![Screenshot 34](images/pic34.png)

![Screenshot 35](images/pic35.png)

![Screenshot 36](images/pic36.png)

2. Verify:
    ```bash
    lsblk
    ```

![Screenshot 37](images/pic37.png)

3. Initialize and configure LVM:
    ```bash
    sudo pvcreate /dev/nvme0n2
    sudo vgcreate cinder-volumes /dev/nvme0n2
    sudo vgs
    ```

![Screenshot 38](images/pic38.png)

4. Repeat on `storage02`.

---

### 🔐 Generate SSH Keys for `kolla` User

Now, we will generate an SSH key for the `kolla` user on `controller01` and copy the public key to all other nodes under the same user (`kolla`). This is essential for password less SSH access, which Kolla Ansible uses to operate on remote nodes.


1. Log in as `kolla` on `controller01`.

2. Generate key pair:
    ```bash
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    ```

![Screenshot 39](images/pic39.png)

3. Copy public key to all nodes:
    ```bash
    for host in controller01 controller02 controller03 compute01 compute02 network01 network02 storage01 storage02; do
      ssh-copy-id kolla@$host
    done
    ```

> 📌 You’ll be prompted for the `kolla` user password on each host.

4. Test:
    ```bash
    ssh kolla@controller03
    ```

![Screenshot 40](images/pic40.png)

---

## 🚀 Installing OpenStack with Kolla-Ansible

All the following steps are executed on the **deployment node** (`controller01`), which orchestrates the entire OpenStack environment using **Kolla Ansible**.

---

### 📦 Install Dependencies

1. **Update system packages:**

   ```bash
   sudo dnf update -y
   ```

2. **Install Python build dependencies:**

   ```bash
   sudo dnf install git python3-devel libffi-devel gcc openssl-devel python3-libselinux -y
   ```

![Screenshot 41](images/pic41.png)

3. **Install Ansible:**

   ```bash
   sudo pip3 install ansible-core
   ```

![Screenshot 42](images/pic42.png)

   > ⚠️ If you face a `PATH` warning, update your shell configuration:

![Screenshot 43](images/pic43.png)

   ```bash
   nano ~/.bashrc
   # Add this line
   export PATH="/usr/local/bin:$PATH"
   source ~/.bashrc
   ```

---

### 🧰 Install Kolla Ansible

1. **Install `kolla-ansible` via pip:**

   ```bash
   sudo pip3 install kolla-ansible
   ```

![Screenshot 44](images/pic44.png)

2. **Create the configuration directory:**

   ```bash
   sudo mkdir -p /etc/kolla
   sudo chown $USER:$USER /etc/kolla
   ```

![Screenshot 45](images/pic45.png)

3. **Copy example config files:**

   ```bash
   cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/
   ```

![Screenshot 46](images/pic46.png)

4. **Copy the multinode inventory file to the current directory:**

   ```bash
   cp /usr/local/share/kolla-ansible/ansible/inventory/multinode .
   ```

   > ℹ️ We're using **multinode** to deploy a highly available OpenStack setup across multiple nodes.

![Screenshot 47](images/pic47.png)

5. **Install Ansible Galaxy dependencies:**

   ```bash
   kolla-ansible install-deps
   ```

![Screenshot 48](images/pic48.png)

---

### ⚙️ Configure Main Files

#### `globals.yml`

* **Path:** `/etc/kolla/globals.yml`
* **Purpose:** Main config file for customizing OpenStack deployment.

```bash
nano /etc/kolla/globals.yml
```

Paste the following configuration:

<details>
<summary>🔽 Click to Expand `globals.yml` Example</summary>

```yaml
##########################
# General Configuration
##########################
config_strategy: "COPY_ALWAYS"
kolla_base_distro: "rocky"
openstack_release: "2024.2"
network_address_family: "ipv4"
kolla_container_engine: docker
docker_configure_for_zun: "yes"
containerd_configure_for_zun: "yes"
docker_apt_package_pin: "5:20.*"

##########################
# Network Configuration
##########################
network_interface: "ens160"
neutron_external_interface: "ens192"
kolla_internal_vip_address: "192.168.142.250"

##########################
# OpenStack Core Services
##########################
enable_openstack_core: "yes"
enable_keystone: "{{ enable_openstack_core | bool }}"
enable_glance: "{{ enable_openstack_core | bool }}"
enable_nova: "{{ enable_openstack_core | bool }}"
enable_neutron: "{{ enable_openstack_core | bool }}"
enable_heat: "{{ enable_openstack_core | bool }}"
enable_horizon: "{{ enable_openstack_core | bool }}"

##########################
# Networking Plugin
##########################
neutron_plugin_agent: "openvswitch"
enable_kuryr: "yes"

##########################
# High Availability
##########################
enable_haproxy: "yes"
enable_keepalived: "{{ enable_haproxy | bool }}"

##########################
# Database & Messaging
##########################
enable_mariadb: "yes"
enable_memcached: "yes"
enable_etcd: "yes"

##########################
# Telemetry & Monitoring
##########################
enable_ceilometer: "yes"
enable_aodh: "yes"
enable_gnocchi: "yes"
enable_gnocchi_statsd: "yes"
enable_prometheus: "yes"
enable_grafana: "yes"

##########################
# Block Storage (Cinder)
##########################
enable_cinder: "yes"
enable_cinder_backend_lvm: "yes"
cinder_volume_group: "cinder-volumes"

##########################
# Containerized Application Services
##########################
enable_zun: "yes"
enable_horizon_zun: "{{ enable_zun | bool }}"

##########################
# Image Service Configuration (Glance)
##########################
glance_backend_file: "yes"
glance_file_datadir_volume: "/mnt/glance"
```

</details>

---

#### `passwords.yml`

* **Path:** `/etc/kolla/passwords.yml`
* **Purpose:** Stores auto-generated or custom passwords for all OpenStack services.
* **Generate it with:**

  ```bash
  kolla-genpwd
  ```

![Screenshot 49](images/pic49.png)

---

#### `multinode` Inventory File

* Defines node roles and groups for the Ansible deployment.

```ini
[control]
controller01
controller02
controller03

[network]
network01
network02

[compute]
compute01
compute02

[monitoring]
controller01

[storage]
storage01
storage02

[all:vars]
ansible_user=kolla
ansible_become=True

[deployment]
localhost ansible_connection=local
```

---

### 📤 Deploy OpenStack

1. **Bootstrap the servers:**

   ```bash
   kolla-ansible bootstrap-servers -i ./multinode
   ```

![Screenshot 50](images/pic50.png)

2. **Run pre-deployment checks:**

   ```bash
   kolla-ansible prechecks -i ./multinode
   ```

![Screenshot 51](images/pic51.png)

3. **Deploy OpenStack:**

   ```bash
   kolla-ansible deploy -i ./multinode
   ```

![Screenshot 52](images/pic52.png)

4. **Validate service configurations:**

   ```bash
   kolla-ansible validate-config -i ./multinode
   ```

![Screenshot 53](images/pic53.png)

---

### 🧪 Using OpenStack After Deployment

1. **Post-deployment config (generates `clouds.yaml`):**

   ```bash
   kolla-ansible post-deploy
   ```

![Screenshot 54](images/pic54.png)

2. **Verify clouds.yaml file:**

   ```bash
   ls /etc/kolla/clouds.yaml
   ```

![Screenshot 55](images/pic55.png)

3. **Install OpenStack CLI:**

   ```bash
   pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
   ```

4. **Test the deployment:**

- Try to list the services:

```bash
openstack service list
```

![Screenshot 56](images/pic56.png)

- Source OpenStack admin credentials file (`admin-openrc.sh`) that allows you to interact with the OpenStack CLI

```bash
source /etc/kolla/admin-openrc.sh
```

![Screenshot 57](images/pic57.png)

- Check the status of compute nodes:

```bash
openstack compute service list
```

![Screenshot 58](images/pic58.png)

5. **Access Horizon Dashboard:**
   Open your browser and visit:
   `http://192.168.142.250`

   Login credentials:

   * **Username:** `admin`
   * **Password:** (find it using)

     ```bash
     grep keystone_admin_password /etc/kolla/passwords.yml
     ```

![Screenshot 59](images/pic59.png)

![Screenshot 60](images/pic60.png)

![Screenshot 61](images/pic61.png)

---

### 🧪 (Optional) Setup Demo Environment

```bash
/usr/local/share/kolla-ansible/init-runonce
```

![Screenshot 62](images/pic62.png)

---

### 🖧 Explore Running Services on Nodes

Example Services by Role:

#### Storage Node (`storage02`)

* `cinder_backup`, `cinder_volume`, `iscsid`
* `prometheus_cadvisor`, `fluentd`

![Screenshot 63](images/pic63.png)

#### Network Node (`network01`)

* `neutron_l3_agent`, `neutron_dhcp_agent`, `neutron_openvswitch_agent`
* `keepalived`, `haproxy`

![Screenshot 64](images/pic64.png)

## 🚀Automation Deloyment

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
## 📋 Prerequisites


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
