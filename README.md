# SOCaaS for SMEs – Blue Team Home Lab

**Goal:** Build a scalable, affordable SOC-as-a-Service stack for small & medium enterprises.  
Current stack: **Elasticsearch + Wazuh + Winlogbeat/Filebeat**.  
Planned: **Suricata IDS/IPS integration**.

## Why this matters
- SMEs often lack 24/7 SOC coverage.
- This lab demonstrates how open-source tooling can provide **visibility**, **detection**, and **actionable alerts** without enterprise costs.

## Architecture (current phase)
- **Windows & Linux VMs** -> Winlogbeat & Filebeat -> Elasticsearch (raw telemetry).
- **Wazuh Agents** -> Wazuh Manager (decoders/rules) -> Elasticsearch (curated alerts).
- **Mac Host** runs Elasticsearch, Kibana, and Wazuh Manager.

## Roadmap
- [x] Collect host logs (Windows/Linux).
- [x] Integrate Wazuh alerts into Elastic.
- [ ] Add Suricata for network IDS/IPS.
- [ ] Build correlation dashboards (host <-> network <-> alert).
- [ ] Publish detection rules (Sigma/KQL/Wazuh).

## Next steps
Documentation, architecture diagrams, detection logic, and test results will be added in `docs/`.

---

 *Work in progress. First milestone: baseline SOC ingest + Wazuh curation.*
