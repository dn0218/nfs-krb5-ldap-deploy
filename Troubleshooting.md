# Troubleshooting Guide: Secure Distributed Storage
Environment: RHEL 9 / Rocky Linux 9

Core Stack: Chrony, BIND DNS, OpenLDAP, MIT Kerberos, NFSv4.2 (krb5p)

## Core Troubleshooting Methodology
Always follow the bottom-up approach when debugging this stack:

1. Physical/Network: IP connectivity and Port status.

2. Time: Chrony/NTP synchronization (Critical for Kerberos).

3. Resolution: DNS FQDN and PTR records.

4. Identity: LDAP User/Group visibility.

5. Authentication: Kerberos Ticket Granting (TGT) and Keytabs.

6. Application: NFS Exports and Mounts.

## Error Matrix & Resolutions

### Layer 1: Time & Network

| Symptom              | Error Message                                                              | Root Cause                     | Resolution                                           |
|----------------------|----------------------------------------------------------------------------|--------------------------------|------------------------------------------------------|
| Kerberos Auth Failure | GSSAPI error: Unspecified GSS failure (minor code: Clock skew too great)   | System time difference > 5 mins. | Run `chronyc tracking` on both; restart `chronyd`.  |
| Connection Timeout   | `mount.nfs4: Connection timed out`                                         | Firewalld blocking ports.      | `firewall-cmd --list-services` (Check nfs, rpc-bind, mountd). |

### Layer 2: DNS & FQDN

| Symptom             | Error Message                                      | Root Cause                                   | Resolution                                                   |
|---------------------|----------------------------------------------------|----------------------------------------------|--------------------------------------------------------------|
| KDC Not Found       | `Cannot find KDC for realm "EXAMPLE.COM"`          | Missing SRV records or DNS search suffix.    | Check `/etc/resolv.conf` and `named-checkconf`.             |
| GSS Mapping Error   | `Local lock failed or nobody ownership`            | FQDN mismatch in `/etc/hosts`.               | Ensure `hostname -f` matches the Kerberos SPN.              |

### Layer 3: Kerberos & Identity

| Symptom           | Error Message                                        | Root Cause                                           | Resolution                                                         |
|-------------------|------------------------------------------------------|------------------------------------------------------|--------------------------------------------------------------------|
| Keytab Invalid    | `Preauthentication failed while getting initial credentials` | KVNO (Key Version Number) mismatch.                  | Delete Principal, `addprinc`, and re-export `ktadd`.              |
| Login Failures    | `su: Authentication failure`                         | Missing admin Principal (only `admin/admin` exists). | Run `kadmin.local -q "addprinc admin"`.                            |
| SSH Failure       | `REMOTE HOST IDENTIFICATION HAS CHANGED!`            | Cached SSH keys in `known_hosts`.                    | Run `ssh-keygen -R <IP_ADDRESS>`.                                  |

### Layer 4: NFS & Security

| Symptom            | Error Message                                 | Root Cause                               | Resolution                                         |
|--------------------|-----------------------------------------------|------------------------------------------|----------------------------------------------------|
| Mount Denied       | `mount.nfs4: access denied by server`         | `/etc/exports` is empty or not exported.  | Run `exportfs -rv` and check `sec=krb5p` flag.    |
| Permission Denied  | `mount(2): Permission denied`                 | `rpc.gssd` or `gssproxy` not running.     | Run `systemctl restart gssproxy rpc-gssd`.        |
| Read-Only Access   | `Cannot create file: Permission denied`       | SELinux boolean blocking.                  | Run `setsebool -P nfs_export_all_rw 1`.           |

## Essential Diagnostic Commands
### Time Sync Check
```Bash
# Check if synchronized to a source
chronyc sources -v

# Check system drift
chronyc tracking
```

### Kerberos Verification
```Bash
# Check local keytab principals and KVNO
sudo klist -kt /etc/krb5.keytab

# Test machine credentials manually
sudo kinit -k -t /etc/krb5.keytab nfs/$(hostname -f)

# List KDC database (Server side)
sudo kadmin.local -q "listprincs"
```

### NFS & RPC Inspection
```Bash
# Check what the server is actually exporting
sudo exportfs -v

# Verify RPC services are registered
rpcinfo -p localhost

# Monitor GSS negotiation logs
sudo journalctl -f -u gssproxy -u rpc-gssd
```

### SSSD & PAM
```Bash
# Clear SSSD cache (Fixes "ghost" user issues)
sudo sss_cache -E
sudo systemctl restart sssd

# Verify PAM config for SSSD
authselect current
```
## Maintenance Checklist
1. SELinux: Ensure status is Enforcing but appropriate booleans are set. Do not disable.

2. Firewalld: Verify nfs, mountd, rpc-bind, dns, and kerberos services are allowed.

3. Permissions: Verify /etc/krb5.keytab is 600 and owned by root.

4. Reverse DNS: Ensure PTR records are valid for all nodes.

5. idmapd: Confirm Domain in /etc/idmapd.conf is identical on server and client.</IP_ADDRESS>
