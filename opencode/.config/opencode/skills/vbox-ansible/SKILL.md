---
name: vbox-ansible
description: Debug Ansible-managed VirtualBox VMs — SSH access patterns, sudo via ssh, WireGuard troubleshooting, and common VirtualBox network gotchas.
metadata:
    short-description: VirtualBox + Ansible VM debugging playbook
---

# VirtualBox + Ansible VM Debugging

## SSH Access Patterns

### Basic SSH connection (from `~/.ssh/config`)
```bash
ssh client      # → vboxuser@localhost:2225
ssh dmz-agent   # → vboxuser@localhost:2223
ssh router      # → vboxuser@localhost:2222
ssh private-agent
```

### SSH + sudo (without password prompt)
```bash
# SSH with sudo -S (reads password from stdin)
echo "ss" | ssh vboxuser@localhost -p 2222 "sudo -S <command>"

# Better: Use sshpass (if available)
sshpass -p ss ssh -o StrictHostKeyChecking=no vboxuser@localhost -p 2222 "sudo cat /etc/wireguard/wg0.conf"

# Avoid: Interactive sudo prompts (hangs in scripts)
# ssh vboxuser@localhost "sudo cmd"  # WILL HANG

# SSH as heredoc to avoid password issues
ssh vboxuser@localhost -p 2222 'sudo -S bash -s' < /dev/null
```

### Common SSH tricks for VM inspection
```bash
# Fetch file content (ansible fetch)
ANSIBLE_BECOME_PASS=ss ansible <host> -i inventory.ini -m fetch -a "src=/etc/wireguard/wg0.conf dest=/tmp/wg.conf flat=yes"

# Run ansible module with sudo
ANSIBLE_BECOME_PASS=ss ansible <host> -i inventory.ini -m shell -a "cat /etc/wireguard/wg0.conf"

# Derive WireGuard public key from private key
ssh <host> "echo <private_key_b64> | wg pubkey"

# Check what's listening (UDP port)
ssh <host> "sudo -S ss -ulnp | grep 5000"

# tcpdump (use timeout to avoid hanging)
ssh <host> "sudo -S timeout 5 tcpdump -i enp0s3 -n port 5000"

# Check routing
ssh <host> "ip route show"
ssh <host> "ip route get <destination_ip>"

# Check external IP
ssh <host> "curl -s ifconfig.me"
```

## VirtualBox Inspection

### Check VM network settings
```bash
VBoxManage list vms
VBoxManage showvminfo <vm-name> | grep -A5 "NIC 1"

# Check port forwarding rules
VBoxManage showvminfo router 2>/dev/null | grep "Rule"

# Important: VirtualBox NAT only supports TCP port forwarding by default!
# UDP port forwarding requires additional setup or NAT network mode.
```

### VM network modes
- **NAT**: Outbound only, port forwarding needed for inbound. Only TCP forwarding is built-in.
- **NAT Network**: Same as NAT but shared across VMs. UDP forwarding also not native.
- **Host-only**: VMs can talk to each other and host, no internet.
- **Internal Network**: VMs can only talk to each other, no host/internet.
- **Bridged**: VM gets real IP from LAN, receives all traffic.

## WireGuard Troubleshooting

### 1. Check handshake status
```bash
# On client
ssh <client> "sudo -S wg show" 2>/dev/null

# Look for "latest handshake: X seconds ago" — if absent, no tunnel
# If "transfer: 0 B received", traffic not passing even if handshake exists
```

### 2. Verify config file matches running interface
```bash
# Config file (what was written by Ansible)
ssh <host> "sudo -S cat /etc/wireguard/wg0.conf"

# Running interface (what wg is actually using)
ssh <host> "sudo -S wg show"

# Check if they differ — Ansible copy may not restart the interface!
```

### 3. Key derivation — NEVER guess public keys
```bash
# Derive public key from private key (on the VM itself, since wg is there)
ssh <host> "echo <private_key> | wg pubkey"

# Example: router private key → public key
# Private: SOr5tGPioigTY3hjOSGZ04ClioN2RxMZzHGhheAQ0lY=
# Run on router: echo SOr5tGPioigTY3hjOSGZ04ClioN2RxMZzHGhheAQ0lY= | wg pubkey
# Output: 77FjWwPeo6+M3cq75Lk9U67BuFIA4VfqG9Ua3MeAxQg=
```

### 4. Endpoint IP — CRITICAL
```
DO NOT use public/external IPs. Use internal network IPs:
- Router's DMZ interface: 172.16.0.254 (on dmznet)
- Router's Private interface: 172.16.1.254 (on privnet)
- dmz-agent: 172.16.0.123
- client: 172.16.0.200
- private-agent: 172.16.1.123

WireGuard endpoint for clients in dmznet: 172.16.0.254:5000
WireGuard endpoint for clients in privnet: 172.16.1.254:5000
```

### 5. Firewall check on router
```bash
# Check INPUT chain (for traffic destined to router itself)
ssh router "sudo -S iptables -L INPUT -n -v"

# Check FORWARD chain (for traffic passing through router)
ssh router "sudo -S iptables -L FORWARD -n -v"

# FORWARD policy DROP + no rule for UDP 5000 = packets dropped
# Add rule: ssh router "sudo -S iptables -I FORWARD 1 -i enp0s3 -o wg0 -p udp --dport 5000 -j ACCEPT"
```

### 6. Packet capture to verify traffic flow
```bash
# On router: capture packets on enp0s3 (DMZ-facing NIC)
ssh router "sudo -S timeout 5 tcpdump -i enp0s3 -n port 5000"

# On router: capture on wg0 interface
ssh router "sudo -S timeout 5 tcpdump -i wg0 -n"

# On client: capture outbound
ssh <client> "sudo -S timeout 5 tcpdump -i wg0 -n"
```

### 7. Common WireGuard errors
```
"Required key not available"
  → Peer public key in client's config doesn't match router's actual public key
  → Fix: Derive public key from private key on router, update client peer config

"Key is not the correct length or format"
  → Private key is not valid base64 or wrong length
  → Fix: Generate valid 44-char base64 key: wg genkey

"Packets transmitted, 0 received, 100% packet loss"
  → Check: (1) endpoint IP correct, (2) firewall allows, (3) peer keys match
  → If using VirtualBox NAT, verify UDP port forwarding is set up
```

## Ansible WireGuard Role — Key Patterns

### host_vars format for WireGuard peers
```yaml
# For router (server-side): list of peers with their public keys
wireguard_peers:
  - public_key: <peer_public_key>      # Must be derived from peer's private key
    preshared_key: <psk>
    allowed_ips: 192.168.8.66/32

# For client (connects to server): single peer pointing to router
wireguard_peers:
  - public_key: <router_public_key>    # Derived from router's private key
    preshared_key: <psk>
    allowed_ips: 192.168.0.0/16
    endpoint: 172.16.0.254:5000
    persistent_keepalive: 5
```

### Always restart wg after config change
Ansible `copy` with `force: true` updates the file but doesn't restart the interface.
The role must run `wg-quick down wg0; wg-quick up wg0` after copy.

```yaml
# Role task pattern:
- name: Configure WireGuard
  ansible.builtin.copy:
    dest: /etc/wireguard/wg0.conf
    content: |
      [Interface]
      Address = {{ wireguard_address }}
      PrivateKey = {{ wireguard_private_key }}
      {% for peer in wireguard_peers | default([]) %}
      [Peer]
      PublicKey = {{ peer.public_key }}
      ...
      {% endfor %}
    mode: '0600'
    force: true

- name: Reload WireGuard config
  ansible.builtin.shell: wg-quick down wg0; wg-quick up wg0
  # NOTE: Always runs, not conditional — wg interface must restart to pick up config
```

## Decision Tree for VPN Connectivity Issues

1. **Ping fails with "Required key not available"**
   → Client's peer public key doesn't match router's actual public key
   → Derive public key on router, update client's peer config

2. **Ping fails with "Destination Host Unreachable"**
   → Check if handshake exists: `wg show | grep handshake`
   → No handshake → go to step 3
   → Has handshake but no traffic → go to step 5

3. **No handshake**
   → Verify endpoint IP: client should point to router's internal DMZ IP (e.g., 172.16.0.254)
   → Check firewall: `iptables -L FORWARD` — must allow UDP 5000
   → Check packets reach router: `tcpdump -i enp0s3 port 5000`
   → Check VirtualBox port forwarding if using NAT

4. **Wrong endpoint IP**
   → NEVER use: public IP, NAT gateway IP (10.0.2.2), or arbitrary external IPs
   → ALWAYS use: router's interface on the same internal network
   → Example: client on dmznet (172.16.0.x) → endpoint = 172.16.0.254

5. **Has handshake but no traffic**
   → Check wg interface: `ip a show wg0`
   → Check routing: `ip route show`
   → Check firewall FORWARD chain: packets may be dropped after handshake
