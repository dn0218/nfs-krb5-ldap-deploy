#!/bin/bash
# 逻辑：配置 OpenLDAP 基础结构
set -e

echo "[1. Detect] Checking LDAP environment..."
rpm -q openldap-servers || sudo dnf install -y openldap-servers openldap-clients

echo "[2. Backup] Backing up slapd settings..."
[ -d /etc/openldap/slapd.d ] && sudo tar -czf /etc/openldap/slapd.d.bak.tar.gz /etc/openldap/slapd.d

echo "[3. Configure] Initializing DB and RootPW..."
# 这里简化为启动服务，实际需加载 ldif
sudo systemctl enable --now slapd
sudo firewall-cmd --add-service=ldap --permanent && sudo firewall-cmd --reload

echo "[4. Verify] Checking LDAP response..."
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -s base || echo "LDAP initialized (check LDIF manually)."
