# Agent Deployment Guide

This document covers installing and enrolling Wazuh agents on Windows, Linux, and macOS endpoints into the TIGARSEC SOCaaS platform.

---

## Prerequisites

Before installing any agent you need:

- The Wazuh manager IP address (ask your TIGARSEC account manager)
- The client agent group name (format: `client-[shortname]`, e.g. `client-alpha`)
- Admin/root access on the endpoint being enrolled
- Ports 1514 and 1515 open outbound from the endpoint to the Wazuh manager

---

## Windows

Run the following in **PowerShell as Administrator**. Replace `MANAGER_IP` and `client-[shortname]` with the values provided by TIGARSEC.

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.13.0-1.msi -OutFile wazuh-agent.msi

$hostname = $env:COMPUTERNAME.ToLower()
Start-Process msiexec.exe -Wait -ArgumentList "/i wazuh-agent.msi /q WAZUH_MANAGER=MANAGER_IP WAZUH_AGENT_GROUP=client-[shortname]  WAZUH_AGENT_NAME=[shortname]-$hostname"

NET START WazuhSvc
```

**Verify the agent is running:**

```powershell
Get-Service WazuhSvc
```

Expected output: `Status: Running`

### Recommended: Install Sysmon for enhanced visibility

Sysmon dramatically improves Windows detection coverage by logging process creation, network connections, and file changes. TIGARSEC recommends deploying it alongside the Wazuh agent.

```powershell
# Download Sysmon
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile Sysmon.zip
Expand-Archive Sysmon.zip -DestinationPath Sysmon

# Install with SwiftOnSecurity config (industry standard)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -OutFile sysmonconfig.xml
.\Sysmon\Sysmon64.exe -accepteula -i sysmonconfig.xml
```

---

## Linux (Ubuntu / Debian)

Run the following as **root or with sudo**. Replace `MANAGER_IP` and `client-[shortname]` accordingly.

```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.13.0-1_amd64.deb

sudo WAZUH_MANAGER=MANAGER_IP \
     WAZUH_AGENT_GROUP=client-[shortname] \
     WAZUH_AGENT_NAME=[shortname]-$(hostname) \
     dpkg -i ./wazuh-agent.deb

sudo systemctl enable --now wazuh-agent
```

**Verify the agent is running:**

```bash
sudo systemctl status wazuh-agent
```

Expected output: `Active: active (running)`

### For ARM64 (e.g. Raspberry Pi, AWS Graviton):

```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.13.0-1_arm64.deb
```

---

## macOS

Run the following in **Terminal**. Replace `MANAGER_IP` and `client-[shortname]` accordingly.

**Apple Silicon (M1/M2/M3):**

```bash
curl -so wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-4.13.0-1.arm64.pkg

sudo launchctl setenv WAZUH_MANAGER 'MANAGER_IP'
sudo launchctl setenv WAZUH_AGENT_GROUP 'client-[shortname]'
sudo launchctl setenv WAZUH_AGENT_NAME "[shortname]-$(hostname -s)"

sudo installer -pkg wazuh-agent.pkg -target /

sudo /Library/Ossec/bin/wazuh-control start
```

**Intel Mac:**

```bash
curl -so wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-4.13.0-1.pkg

sudo launchctl setenv WAZUH_MANAGER 'MANAGER_IP'
sudo launchctl setenv WAZUH_AGENT_GROUP 'client-[shortname]'

sudo installer -pkg wazuh-agent.pkg -target /

sudo /Library/Ossec/bin/wazuh-control start
```

**Verify the agent is running:**

```bash
sudo /Library/Ossec/bin/wazuh-control status
```

Expected output includes: `wazuh-agentd is running`

---

## Verifying agent registration on the manager

After installing an agent, confirm it appears on the Wazuh manager:

```bash
docker exec socaas_for_smes-wazuh-manager-1 \
  /var/ossec/bin/agent_groups -l -g client-[shortname]
```

You should see the agent listed with status `Active`. If it shows `Never connected`, check that ports 1514 and 1515 are open between the endpoint and the manager.

---

## Agent naming convention

TIGARSEC uses a consistent naming convention for all agents. This enables dashboard filtering by client without needing to list individual agent names.

| Format | Example |
|--------|---------|
| `[shortname]-[hostname]` | `alpha-FINANCE-SERVER` |
| `[shortname]-[hostname]` | `alpha-reception-pc` |
| `[shortname]-[hostname]` | `alpha-dc01` |

With this convention, the Kibana dashboard filter `agent.name : alpha-*` automatically includes all of a client's agents regardless of how many exist.

---

## Uninstalling an agent

### Windows
```powershell
msiexec /x wazuh-agent.msi /q
```

### Linux
```bash
sudo apt-get remove wazuh-agent -y
sudo systemctl daemon-reload
```

### macOS
```bash
sudo /Library/Ossec/bin/wazuh-control stop
sudo /bin/sh /Library/Ossec/active-response/bin/agent-upgrade.sh
sudo rm -rf /Library/Ossec
```

---

## Troubleshooting

| Issue | Check |
|-------|-------|
| Agent shows `Never connected` | Confirm ports 1514/1515 are open outbound |
| Agent shows `Disconnected` | Restart the agent service on the endpoint |
| Agent in wrong group | Re-register with correct `WAZUH_AGENT_GROUP` |
| No alerts appearing in Kibana | Check Filebeat is running: `docker logs socaas_for_smes-wazuh-filebeat-1` |

---

*For onboarding a new client organisation, see the [Client Onboarding Runbook](../TIGARSEC-Client-Onboarding-Runbook.docx) (internal staff only).*
