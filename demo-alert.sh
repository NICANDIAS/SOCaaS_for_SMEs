#!/bin/bash
# ══════════════════════════════════════════════════════════════
# TIGARSEC SOCaaS — Demo Alert Sequence
# Simulates SSH brute force attack followed by successful breach
# Usage: chmod +x demo-alert.sh && ./demo-alert.sh
# ══════════════════════════════════════════════════════════════

WEBHOOK="http://soc.local:8080/webhook/wazuh-alerts"
AGENT="alpha-server-01"
AGENT_IP="192.168.1.50"
SRC_IP="45.33.32.156"
TARGET_USER="root"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║       TIGARSEC SOCaaS — Live Demo Sequence           ║"
echo "║       Simulating SSH brute force attack...           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── PHASE 1: Failed login attempts ────────────────────────────
echo "▶ Phase 1: SSH authentication failures"
echo "  Source IP: $SRC_IP → Target: $TARGET_USER@$AGENT"
echo ""

for i in 1 2 3 4 5; do
  echo -n "  [Attempt $i/5] Failed login... "
  RESULT=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{
      \"rule\": {
        \"level\": 5,
        \"description\": \"SSH authentication failure (attempt $i)\",
        \"id\": \"5716\",
        \"groups\": [\"authentication_failed\",\"pci_dss_10.2.4\"]
      },
      \"agent\": {\"name\": \"$AGENT\", \"ip\": \"$AGENT_IP\"},
      \"data\": {\"srcip\": \"$SRC_IP\", \"dstuser\": \"$TARGET_USER\"},
      \"timestamp\": \"$TIMESTAMP\"
    }")

  if [ "$RESULT" = "200" ]; then
    echo "✓ logged (level 5)"
  else
    echo "✗ failed (HTTP $RESULT)"
  fi
  sleep 1
done

echo ""
echo "  ⚠ Multiple failures detected — brute force pattern identified"
echo ""
sleep 2

# ── PHASE 2: Brute force rule triggers ────────────────────────
echo "▶ Phase 2: Brute force rule fires (level 10)"
echo -n "  [Rule 5712] SSH brute force threshold reached... "

RESULT=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{
    \"rule\": {
      \"level\": 10,
      \"description\": \"Multiple SSH authentication failures — brute force attack\",
      \"id\": \"5712\",
      \"groups\": [\"authentication_failures\",\"pci_dss_10.2.4\",\"pci_dss_10.2.5\"],
      \"mitre\": {
        \"tactic\": [\"Credential Access\"],
        \"technique\": [\"Brute Force\"]
      }
    },
    \"agent\": {\"name\": \"$AGENT\", \"ip\": \"$AGENT_IP\"},
    \"data\": {\"srcip\": \"$SRC_IP\", \"dstuser\": \"$TARGET_USER\"},
    \"timestamp\": \"$TIMESTAMP\"
  }")

if [ "$RESULT" = "200" ]; then
  echo "✓ alert sent (level 10 — medium)"
else
  echo "✗ failed (HTTP $RESULT)"
fi

echo ""
echo "  → TheHive case created (medium severity)"
echo "  → Analyst notified via WhatsApp ⚠️"
echo ""
sleep 3

# ── PHASE 3: Successful breach ────────────────────────────────
echo "▶ Phase 3: SUCCESSFUL LOGIN — breach in progress"
echo ""
echo "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "  !! CRITICAL: Attacker gained access to $AGENT"
echo "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
sleep 1

echo -n "  [Rule 5758] Firing critical alert (level 14)... "

RESULT=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{
    \"rule\": {
      \"level\": 14,
      \"description\": \"Successful SSH login after multiple failures — possible breach\",
      \"id\": \"5758\",
      \"groups\": [\"authentication_success\",\"pci_dss_10.2.4\",\"pci_dss_10.2.5\"],
      \"pci_dss\": [\"10.2.4\",\"10.2.5\"],
      \"mitre\": {
        \"tactic\": [\"Credential Access\",\"Initial Access\"],
        \"technique\": [\"Brute Force\"]
      }
    },
    \"agent\": {\"name\": \"$AGENT\", \"ip\": \"$AGENT_IP\"},
    \"data\": {\"srcip\": \"$SRC_IP\", \"dstuser\": \"$TARGET_USER\"},
    \"timestamp\": \"$TIMESTAMP\"
  }")

if [ "$RESULT" = "200" ]; then
  echo "✓ CRITICAL alert sent (level 14)"
else
  echo "✗ failed (HTTP $RESULT)"
fi

echo ""
echo "  → AbuseIPDB enrichment running..."
sleep 2
echo "  → IP $SRC_IP scored — threat intelligence attached"
echo "  → TheHive CRITICAL case created automatically"
echo "  → WhatsApp alert fired 🚨"
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  Demo complete. Check:                               ║"
echo "║  • WhatsApp — critical alert message                 ║"
echo "║  • TheHive  — http://soc.local:9001                  ║"
echo "║  • Portal   — http://soc.local:8080 (threat level)   ║"
echo "║  • Kibana   — http://soc.local:8080/kibana           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
