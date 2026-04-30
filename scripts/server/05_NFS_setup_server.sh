#!/bin/bash
# 逻辑：配置 Kerberos 加固的 NFS 导出
set -e

echo "[1. Detect] Checking Path and Exports..."
[ -d /shares/project_sec ] || sudo mkdir -p /shares/project_sec
sudo chown 10001:10001 /shares/project_sec

echo "[2. Backup] Backing up /etc/exports..."
sudo cp /etc/exports /etc/exports.bak

echo "[3. Configure] Applying krb5p export and GSSProxy..."
echo "/shares/project_sec 192.168.112.0/24(rw,sec=krb5p,no_root_squash)" | sudo tee /etc/exports

sudo systemctl enable --now nfs-server gssproxy rpc-gssd
sudo exportfs -arv
sudo firewall-cmd --add-service={nfs,mountd,rpc-bind} --permanent && sudo firewall-cmd --reload

echo "[4. Verify] Checking Kernel Export Table..."
sudo exportfs -v | grep "sec=krb5p" && echo "NFS Secure Export Active."
