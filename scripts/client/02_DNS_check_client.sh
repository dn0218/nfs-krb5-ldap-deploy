#!/bin/bash
# 逻辑：校验 FQDN 解析和 NTP 漂移
set -e

echo "[1. Detect] Checking resolv.conf..."
grep -q "rhel.example.com" /etc/resolv.conf || echo "Warning: Server not in resolv.conf"

echo "[2. Verify DNS] Checking forward and reverse..."
host rhel.example.com
host 192.168.112.136

echo "[3. Verify NTP] Checking offset..."
chronyc tracking | grep "System time"
