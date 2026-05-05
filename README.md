# 分布式安全存储集成项目 (LDAP + Kerberos + NFSv4)

本项目实现了基于 RHEL 9 和 Rocky Linux 9 的企业级存储方案。通过 LDAP 统一账号，Kerberos 提供强认证，NFSv4 实施全链路加密（krb5p）。

## 架构组成
*   **认证中心 (KDC)**: RHEL 9 (192.168.112.136)
*   **账号服务器 (LDAP)**: RHEL 9
*   **存储服务端**: RHEL 9 (NFS Server)
*   **客户端**: Rocky Linux 9 (NFS Client)

## 部署流程
1. 执行 `server_setup.sh` 配置 KDC 与 NFS 导出。
2. 为客户端生成 Keytab 并通过 SCP 传输。
3. 执行 `client_setup.sh` 完成身份集成与挂载。

## 验证方式
```bash
su - admin
kinit admin
cd /mnt/secure_nfs && touch success.log
```

