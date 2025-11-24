## 1. Security KPI Dashboard

![Security KPI Dashboard](./images/dashboard-security-kpi.png)

**Purpose**  
Provides a high-level overview of the lab’s overall security posture. It highlights total alerts, high/critical alerts, unique hosts generating alerts, authentication outcomes, and basic coverage metrics.

**Primary audience**  
SOC Lead / SME Owner who needs a quick daily snapshot of risk and operational health rather than raw event logs.

**Key questions it answers**
- Are we under attack?
- Are things getting worse compared to yesterday?
- What has changed in the last 24 hours?
- How quickly are alerts being acknowledged or triaged?

**Data sources**
- **Winlogbeat** (Windows Security & Sysmon) — `ds-winlogbeat-*`
- **Filebeat** (Linux system/auth + Wazuh forwarded alerts) — `ds-filebeat-*`

**Main visualizations (panels)**

1. **Alerts Over Time (rule.level ≥ 7)**  
   Shows the volume and severity of alerts over time.  
   *How to read:* sudden spikes may indicate bursts of suspicious activity or misconfigurations.  
   *Action:* investigate time windows with unusual increases, correlate with host activity.

2. **Critical Alerts (rule.level ≥ 10)**  
   Focuses on the most severe events.  
   *How to read:* one critical alert may matter more than 100 low-severity ones.  
   *Action:* treat red spikes as immediate triage tasks.

3. **Unique Hosts Generating Alerts**  
   Identifies which hosts are producing alerts and how frequently.  
   *How to read:* a single noisy host may indicate compromise, misconfiguration, or an aggressive application.  
   *Action:* pivot into host-level telemetry and Wazuh rules affecting that host.

4. **Authentication Outcomes (Success vs Failure)**  
   Tracks login behavior across Windows/Linux systems.  
   *How to read:* elevated failed logins suggest brute-force attempts or password spraying.  
   *Action:* check SSH/Winlogon logs, correlate with source IP and Wazuh alerts.

5. **EDR Coverage Overview**  
   Shows which hosts have required agents (Wazuh, Beats, Sysmon) and whether logs are arriving as expected.  
   *How to read:* missing hosts indicate coverage gaps.  
   *Action:* verify agent installation or network connectivity.

**Example day / observation**
- On **2025-10-02**, a spike in Wazuh alerts came from `WIN-AVEKJEPJI4` immediately after Sysmon installation.  
- Most alerts were low/medium severity, indicating that tuning and noise reduction are still needed before a production-like setup.

**Limitations / next improvements**
- Suricata IDS/IPS data not yet integrated.  
- Limited user-level aggregation — dashboards currently focus on hosts rather than business roles.  
- No correlation panels yet (e.g., Wazuh alerts + raw logs + network events).
