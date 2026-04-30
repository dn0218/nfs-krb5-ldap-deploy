#!/bin/bash
# 逻辑：客户端同步到 RHEL Server
set -e

echo "[1. Detect] Chrony Check..."
rpm -q chrony || sudo dnf install -y chrony

echo "[2. Backup] /etc/chrony.conf backup..."
sudo cp /etc/chrony.conf /etc/chrony.conf.bak

echo "[3. Configure] Pointing to Server..."
sudo sed -i '/pool /d' /etc/chrony.conf
echo "server rhel.example.com iburst" | sudo tee -a /etc/chrony.conf
sudo systemctl restart chronyd

echo "[4. Verify] Checking Sync..."
sleep 2
chronyc sources | grep "\*" && echo "Client Synced to RHEL."
