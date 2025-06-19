#!/bin/bash
set -euo pipefail

echo "=== CHRONO-SWARM SECURITY HARDENING ==="

# Disable unused services
sudo systemctl disable --now bluetooth
sudo systemctl disable --now cups
sudo systemctl disable --now avahi-daemon

# Configure fail2ban
sudo dnf install -y fail2ban
sudo systemctl enable --now fail2ban

# Harden SSH configuration
sudo tee /etc/ssh/sshd_config.d/99-chrono-hardening.conf << 'EOF'
# Chrono-Swarm SSH Hardening
Protocol 2
Port 22
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 2
AllowUsers opc
EOF

# Configure automatic security updates
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic.timer

# Set up audit logging
sudo systemctl enable --now auditd

# Configure firewall rules
sudo firewall-cmd --permanent --remove-service=dhcpv6-client
sudo firewall-cmd --permanent --remove-service=cockpit
sudo firewall-cmd --reload

# File system hardening
echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev,size=1G 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noexec,nosuid,nodev,size=1G 0 0" | sudo tee -a /etc/fstab

# Kernel parameter hardening
sudo tee /etc/sysctl.d/99-chrono-hardening.conf << 'EOF'
# Network security
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# Memory protection
kernel.randomize_va_space = 2
kernel.exec-shield = 1
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
EOF

sudo sysctl -p /etc/sysctl.d/99-chrono-hardening.conf

echo "=== SECURITY HARDENING COMPLETE ==="
