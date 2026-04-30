#!/bin/bash
# Description: Kerberos KDC Server Setup with Strict Security Checks
set -e

# 1. 基础环境校验
echo "[Check] Verifying Hostname and IP..."
[[ $(hostname -f) == "rhel.example.com" ]] || { echo "Hostname mismatch!"; exit 1; }

# 2. 检查依赖服务 (Chrony & DNS)
echo "[Check] Verifying Time Sync..."
chronyc tracking | grep -q "Leap status     : Normal" || { echo "Time not synced!"; exit 1; }

# 3. 安装服务
echo "[Install] Installing Kerberos Packages..."
sudo dnf install -y krb5-server krb5-workstation

# 4. 配置文件幂等修改
KDC_CONF="/var/kerberos/krb5kdc/kdc.conf"
if [ ! -f "$KDC_CONF.bak" ]; then
    sudo cp $KDC_CONF $KDC_CONF.bak
    sudo sed -i 's/EXAMPLE.COM/EXAMPLE.COM/g' $KDC_CONF
fi

# 5. 防火墙策略 (拒绝关闭，仅允许放行)
echo "[Firewall] Updating Rules..."
sudo firewall-cmd --add-service=kerberos --permanent
sudo firewall-cmd --reload

# 6. 核心排错逻辑：校验 Keytab 和 Principal
echo "[Verify] Checking Principal existence..."
if ! sudo kadmin.local -q "list_principals" | grep -q "nfs/$(hostname -f)"; then
    sudo kadmin.local -q "addprinc -randkey nfs/$(hostname -f)"
    sudo kadmin.local -q "ktadd -k /etc/krb5.keytab nfs/$(hostname -f)"
fi

# 7. SELinux 状态检查
echo "[SELinux] Ensuring correct context..."
ls -Z /etc/krb5.keytab | grep -q "krb5_keytab_t" || sudo restorecon -v /etc/krb5.keytab

echo "Server Kerberos Setup Complete."
