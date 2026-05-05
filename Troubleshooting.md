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
Layer 1: Time & NetworkSymptomError MessageRoot CauseResolutionKerberos Auth FailureGSSAPI error: Unspecified GSS failure (minor code: Clock skew too great)System time difference > 5 mins.chronyc tracking on both; restart chronyd.Connection Timeoutmount.nfs4: Connection timed outFirewalld blocking ports.firewall-cmd --list-services (Check nfs, rpc-bind, mountd).
