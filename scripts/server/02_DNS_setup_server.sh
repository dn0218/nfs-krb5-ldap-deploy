#!/bin/bash
# 逻辑：配置 BIND DNS 服务实现内部解析
set -e

echo "[1. Detect] Checking BIND installation..."
rpm -q bind || sudo dnf install -y bind bind-utils

echo "[2. Backup] Backing up named configs..."
sudo cp /etc/named.conf /etc/named.conf.bak

echo "[3. Configure] Setting up zone and listening on all interfaces..."
# 允许监听物理 IP
sudo sed -i 's/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { any; };/' /etc/named.conf
sudo sed -i 's/allow-query     { localhost; };/allow-query     { any; };/' /etc/named.conf

sudo systemctl enable --now named
sudo firewall-cmd --add-service=dns --permanent && sudo firewall-cmd --reload

echo "[4. Verify] Syntax and Port check..."
sudo named-checkconf /etc/named.conf
ss -tulpn | grep :53 | grep -v 127.0.0.1 && echo "DNS Listening on External IP."
