#!/bin/bash
# 逻辑：配置本地 NTP 时间源服务器
set -e

echo "[1. Detect] Checking Chrony status..."
rpm -q chrony || sudo dnf install -y chrony

echo "[2. Backup] Backing up /etc/chrony.conf..."
[ -f /etc/chrony.conf ] && sudo cp /etc/chrony.conf /etc/chrony.conf.bak.$(date +%F)

echo "[3. Configure] Setting up local stratum 10 server..."
# 允许指定网段同步
sudo sed -i '/allow /d' /etc/chrony.conf
echo "allow 192.168.112.0/24" | sudo tee -a /etc/chrony.conf
echo "local stratum 10" | sudo tee -a /etc/chrony.conf

sudo systemctl enable --now chronyd
sudo firewall-cmd --add-service=ntp --permanent && sudo firewall-cmd --reload

echo "[4. Verify] Checking synchronization..."
chronyc tracking | grep "Leap status     : Normal" && echo "Chrony Server Ready."
