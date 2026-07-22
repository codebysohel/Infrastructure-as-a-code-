# OpenStack Kolla-Ansible Troubleshooting Guide

## Common Issues and Solutions

### 1. SSH Connection Issues

**Problem:** SSH authentication fails between nodes

**Solution:**
```bash
# Verify SSH key is copied to all nodes
for host in controller01 controller02 controller03 compute01 compute02 network01 network02 storage01 storage02; do
  ssh-copy-id kolla@$host
done

# Test SSH without password
ssh kolla@controller03
```

### 2. Hostname Resolution Issues

**Problem:** "Could not resolve hostname" errors

**Solution:**
```bash
# Verify /etc/hosts on deployment node
cat /etc/hosts

# Test DNS resolution
nslookup controller01
dig controller01

# Alternative: Use IP addresses directly in inventory
```

### 3. Docker/Container Issues

**Problem:** Containers failing to start

**Solution:**
```bash
# Check Docker daemon status
sudo systemctl status docker
sudo systemctl restart docker

# View container logs
docker logs <container_id>

# Check image availability
docker images

# Pull base images manually if needed
kolla-ansible pull-images -i ./multinode
```

### 4. Pre-deployment Checks Fail

**Problem:** Prechecks fail with various errors

**Solution:**
```bash
# Run prechecks with verbose output
kolla-ansible prechecks -i ./multinode -vvv

# Check specific requirements:
# - Network MTU: ip link show
# - Disk space: df -h
# - Memory: free -h
# - Python version: python3 --version
```

### 5. Database Issues

**Problem:** Galera cluster synchronization issues

**Solution:**
```bash
# SSH to a controller node
ssh kolla@controller01

# Check Galera status
docker exec mariadb mysql -u root -p<password> -e "SHOW STATUS LIKE 'wsrep%';"

# Check database replication
docker exec mariadb mysql -u root -p<password> -e "SHOW MASTER STATUS\\G"
```

### 6. Memory/Disk Issues

**Problem:** Out of disk space or memory errors

**Solution:**
```bash
# Check available disk space
df -h

# Check available memory
free -h

# Clean up Docker images and volumes
docker system prune -a

# Increase swap if needed
sudo dd if=/dev/zero of=/swapfile bs=1G count=4
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 7. Network Configuration Issues

**Problem:** Network interfaces not configured correctly

**Solution:**
```bash
# Verify NIC naming
ip a
nmcli device status

# Check network interface status
ethtool ens160
ethtool ens192

# Verify network connectivity
ping 8.8.8.8
ping -I ens160 192.168.142.141
```

### 8. HAProxy/Keepalived Issues

**Problem:** VIP not accessible or failing over

**Solution:**
```bash
# SSH to a controller node
ssh kolla@controller01

# Check Keepalived status
docker exec keepalived ps aux | grep keepalived

# Check HAProxy status
docker exec haproxy haproxy -c -f /etc/haproxy/haproxy.cfg

# View HAProxy stats
# Access at http://192.168.142.250:8404/stats (if configured)
```

### 9. Service Startup Failures

**Problem:** Specific OpenStack services fail to start

**Solution:**
```bash
# SSH to appropriate node
ssh kolla@controller01

# Check service logs
docker logs keystone
docker logs nova-api
docker logs neutron-server

# Restart a service
kolla-ansible reconfigure -i ./multinode -t nova

# Detailed logs location
/var/lib/kolla/nova/nova-api.log
```

### 10. Performance Issues

**Problem:** OpenStack services slow to respond

**Solution:**
```bash
# Check CPU usage
top
mpstat

# Check disk I/O
iostat -x 1

# Check network status
netstat -i
ss -s

# Check Docker resource limits
docker stats
```

## Deployment Failure Recovery

### If deployment fails midway:

1. **Identify the failing service:**
   ```bash
   # Check logs
   /var/lib/kolla/<service>/
   ```

2. **Fix the issue** (configuration, network, resources, etc.)

3. **Resume deployment:**
   ```bash
   kolla-ansible deploy -i ./multinode
   ```

### If you need to rollback:

```bash
# Destroy containers and data (CAUTION!)
kolla-ansible destroy -i ./multinode --include-volumes

# Then redeploy from scratch
```

## Useful Commands

```bash
# Verify service status
openstack service list
openstack compute service list
openstack network agent list

# Check resource availability
openstack hypervisor list
openstack flavor list
openstack image list

# Test connectivity
openstack server list
openstack network list

# View detailed logs
kolla-ansible logs -i ./multinode <service_name>

# Generate report
kolla-ansible report -i ./multinode
```

## Contacting Support

When reporting issues:
1. Provide full error messages
2. Include logs from `/var/lib/kolla/`
3. Share configuration files (sanitized)
4. Document deployment environment
5. Describe reproduction steps

---

Last Updated: 2024
