#!/bin/bash
# 逻辑：配置 SSSD + 机器票据 + 挂载
set -e

echo "[1. Detect] Checking Mount point and Keytab..."
[ -f /etc/krb5.keytab ] || { echo "ERROR: /etc/krb5.keytab missing!"; exit 1; }
sudo mkdir -p /mnt/secure_nfs

echo "[2. Backup] SSSD Config Backup..."
[ -f /etc/sssd/sssd.conf ] && sudo cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.bak

echo "[3. Configure] Activating SSSD and Mount..."
sudo authselect select sssd with-mkhomedir --force
sudo systemctl enable --now sssd rpc-gssd oddjobd

# 自动挂载测试
sudo mount -t nfs4 -o sec=krb5p rhel.example.com:/shares/project_sec /mnt/secure_nfs

echo "[4. Verify] Permissions and Mount Status..."
mount | grep "sec=krb5p"
ls -ld /mnt/secure_nfs && echo "Client Secure Mount Success."
