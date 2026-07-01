# Dashboards and Use Cases

TIGARSEC SOCaaS ships with four production dashboards built on Kibana, designed for both day-to-day SOC operations and monthly client reporting. All dashboards use the `filebeat-*` index pattern which captures all Wazuh alerts shipped via Filebeat into Elasticsearch.

---

## Accessing the Dashboards

**URL:** `http://soc.local:8080/kibana/`

Navigate to **Analytics → Dashboards** in the left sidebar. Each dashboard is prefixed with `TIGARSEC -` for easy identification.

If you have multiple client Spaces configured, switch between them using the Space selector (top left avatar) before opening dashboards — each Space shows only that client's data.

---

## Dashboard 1 — Security Overview

**Purpose:** The primary operational view. Shows the full picture of what is happening across all monitored endpoints at a glance.

**Panels:**

| Panel | Type | What it shows |
|-------|------|----------------|
| Total Alerts | Metric | Count of all alerts in the selected time range |
| Critical Alerts | Metric | Count of alerts at level 12 and above |
| Active Agents | Metric | Number of unique agents reporting |
| Alert Volume Over Time | Area chart | Alert trend over time — spikes indicate incidents or scanning activity |
| Alert Severity Distribution | Donut chart | Proportion of alerts by Wazuh level (3, 5, 7, 10, 12+) |
| Top 10 Triggered Rules | Horizontal bar | Most frequently fired detection rules — identifies noisy or high-activity rules |
| Top Source IPs / Users | Horizontal bar | Most active source users or IPs — useful for identifying attack sources or misconfigured accounts |
| MITRE ATT&CK Tactics | Horizontal bar | ATT&CK tactic breakdown across all alerts — shows your detection coverage |

**Common use cases:**

- **Morning review:** Set time range to "Last 24 hours" — review total alert count, check if any critical alerts fired overnight, review any MITRE tactic spikes
- **Incident investigation start point:** Spike in "Alert Volume Over Time" → click the spike to drill down to that time window → identify which rules fired
- **Client monthly report:** Set time range to "Last 30 days" — screenshot for the executive summary section

---

## Dashboard 2 — Authentication Dashboard

**Purpose:** Focused view of all authentication activity. Essential for detecting brute force attacks, credential stuffing, privilege abuse, and after-hours access.

**Panels:**

| Panel | Type | What it shows |
|-------|------|----------------|
| Total Failed Logins | Metric | Failed authentication count — baseline comparison between periods |
| Failed Authentication Attempts | Area chart | Failed login trend — spikes indicate brute force or scanning |
| Most Targeted Users | Horizontal bar | Accounts receiving the most failed login attempts |
| Failed Logins by Agent | Horizontal bar | Which endpoints are experiencing the most authentication failures |

**Common use cases:**

- **Brute force detection:** Spike in "Failed Authentication Attempts" combined with a single user dominating "Most Targeted Users" = brute force in progress — check TheHive for auto-created case
- **Compromised account check:** Successful login appearing in logs after a long period of failures against the same account = potential credential compromise — escalate immediately
- **User behaviour baseline:** Over time, this dashboard establishes what normal authentication patterns look like for a client, making anomalies easier to spot
- **Fintech compliance:** PCI-DSS requirement 10.2.4 and 10.2.5 require logging of invalid access attempts and authentication events — this dashboard provides the evidence

**Key fields in Elasticsearch:**

- `rule.groups: authentication_failed` — all failed authentication events
- `data.dstuser` — target account name
- `data.srcip` — source IP address of the attempt

---

## Dashboard 3 — PCI-DSS Compliance Dashboard

**Purpose:** Maps detected events to PCI-DSS control requirements. The primary dashboard for fintech clients and the centrepiece of quarterly compliance reporting.

**Panels:**

| Panel | Type | What it shows |
|-------|------|----------------|
| PCI-DSS Controls Triggered | Horizontal bar | Which PCI-DSS control references appeared in alerts (e.g. 10.2.4, 2.2, 11.5) |
| PCI-DSS Alert Trend | Area chart | Volume of compliance-relevant alerts over time |
| MITRE Tactics — Compliance Events | Horizontal bar | ATT&CK tactics seen in PCI-DSS tagged alerts |
| Top Compliance Rules Triggered | Horizontal bar | Specific Wazuh rules generating the most compliance-relevant alerts |
| Compliance Alerts by Agent | Horizontal bar | Which endpoints are generating the most compliance events |

**Common use cases:**

- **Quarterly compliance report:** Set time range to "Last 90 days" — export as PDF or screenshot each panel for the compliance section of your client report
- **Auditor evidence:** When an auditor asks "show me evidence of monitoring for PCI-DSS 10.2.4 (invalid access attempts)", point to this dashboard filtered by that control
- **Gap identification:** If a PCI-DSS control is absent from the "Controls Triggered" panel over a long period, it may indicate either no relevant events (good) or a gap in detection coverage (worth investigating)
- **Incident mapping:** When an incident occurs, check which PCI-DSS controls it touched — required for breach notification assessment

**Key PCI-DSS controls covered:**

| Control | Description | Wazuh rules covering it |
|---------|-------------|--------------------------|
| 2.2 | System configuration standards | SSH config, default settings alerts |
| 10.2.4 | Invalid logical access attempts | Failed authentication rules |
| 10.2.5 | Use of privileged accounts | Sudo, root login rules |
| 10.6.1 | Log review | Agent health, log collection rules |
| 11.5 | File integrity monitoring | FIM alerts on critical paths |
| 6.3.3 | Security vulnerabilities | CVE detection rules |

---

## Dashboard 4 — Agent Health Dashboard

**Purpose:** Operational health view of all monitored endpoints. Answers "are all the machines we're supposed to be monitoring actually reporting?"

**Panels:**

| Panel | Type | What it shows |
|-------|------|----------------|
| Active Agents | Metric | Total number of unique agents that have reported in the selected time range |
| Alert Volume by Agent | Horizontal bar | Which endpoints are generating the most alerts — outliers worth investigating |
| Agent Last Seen | Data table | Each agent name and the timestamp of their most recent event |

**Common use cases:**

- **Daily health check:** Open this dashboard first thing — if an agent's "last seen" timestamp is more than a few hours old and it should be active, investigate why it stopped reporting
- **Client onboarding verification:** After installing agents on a new client's endpoints, use this dashboard to confirm all expected agents are reporting before declaring go-live
- **Incident scoping:** When an incident is detected, check this dashboard to confirm all agents in scope are actively reporting — a silent agent during an incident is itself suspicious
- **SLA evidence:** Screenshot this dashboard monthly to show the client that all their endpoints remained monitored throughout the reporting period

**Agent status interpretation:**

| Last seen | Status | Action |
|-----------|--------|--------|
| < 1 hour | Active | Normal |
| 1 - 24 hours | Possibly idle | Monitor — may be a powered-off workstation |
| > 24 hours | Potentially disconnected | Investigate — check agent service on endpoint |
| Not appearing | Never connected | Agent install may have failed — reinstall |

---

## Time Range Guidance

Kibana's time range selector (top right) controls what period all panels show. Recommended settings:

| Use case | Time range |
|----------|------------|
| Daily monitoring | Last 24 hours |
| Weekly review | Last 7 days |
| Monthly client report | Last 30 days |
| Quarterly compliance | Last 90 days |
| Historical investigation | Custom range |

All four dashboards are saved with "Last 1 year" as the default to ensure historical data is always visible.

---

## Importing Dashboards into a New Client Space

When creating a new client Kibana Space, dashboards must be copied across. See the [Client Onboarding Runbook](../TIGARSEC-Client-Onboarding-Runbook.docx) for the full process. Quick steps:

1. Switch to the Default Space
2. Go to Stack Management → Saved Objects
3. Find the four TIGARSEC dashboards
4. Click `···` → Copy to Space → select the client's Space
5. Switch to the client Space and apply agent filter: `agent.name : [shortname]-*`

---

## Dashboard Exports

The exported dashboard definitions are stored in the repository at:

```
kibana-dashboards/tigarsec-dashboards.ndjson
```

This file can be imported into any fresh Kibana instance via Stack Management → Saved Objects → Import. This makes the dashboards fully reproducible and version-controlled alongside the rest of the platform configuration.
