#!/bin/bash
set -e

echo "========================================"
echo "Tests de connectivite reseau"
echo "========================================"

PASS=0
FAIL=0

# Recuperer les IPs dynamiquement par reseau
PC1_IP=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc1': print(c['IPv4Address'].split('/')[0])
")

PC2_IP=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc2': print(c['IPv4Address'].split('/')[0])
")

PC3_IP=$(sudo docker network inspect devops-lab_vlan20 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc3': print(c['IPv4Address'].split('/')[0])
")

ROUTER_VLAN10=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='router': print(c['IPv4Address'].split('/')[0])
")

ROUTER_VLAN20=$(sudo docker network inspect devops-lab_vlan20 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='router': print(c['IPv4Address'].split('/')[0])
")

echo ""
echo "IPs detectees :"
echo "  PC1    : $PC1_IP (vlan10)"
echo "  PC2    : $PC2_IP (vlan10)"
echo "  PC3    : $PC3_IP (vlan20)"
echo "  Router : $ROUTER_VLAN10 (vlan10) / $ROUTER_VLAN20 (vlan20)"
echo ""

run_test() {
    local desc="$1"
    local cmd="$2"
    echo -n "  > $desc ... "
    if eval "$cmd" &>/dev/null; then
        echo "OK"
        ((PASS++))
    else
        echo "ECHEC"
        ((FAIL++))
    fi
}

echo "Test intra-VLAN (VLAN10) :"
run_test "PC1 -> PC2" "sudo docker exec pc1 ping -c 2 -W 3 $PC2_IP"

echo ""
echo "Test inter-VLAN (via Router) :"
run_test "PC1 -> PC3" "sudo docker exec pc1 ping -c 2 -W 3 $PC3_IP"
run_test "PC3 -> PC1" "sudo docker exec pc3 ping -c 2 -W 3 $PC1_IP"

echo ""
echo "Test IP Forwarding :"
run_test "ip_forward actif" "sudo docker exec router sysctl net.ipv4.ip_forward | grep -q '= 1'"

echo ""
echo "========================================"
echo "Resultats: $PASS reussis / $((PASS + FAIL)) tests"
if [ $FAIL -eq 0 ]; then
    echo "Tous les tests sont passes!"
else
    echo "$FAIL test(s) echoue(s)"
fi
echo "========================================"

[ $FAIL -eq 0 ]#!/bin/bash
set -e

echo "========================================"
echo "Tests de connectivite reseau"
echo "========================================"

PASS=0
FAIL=0

# Recuperer les IPs dynamiquement par reseau
PC1_IP=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc1': print(c['IPv4Address'].split('/')[0])
")

PC2_IP=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc2': print(c['IPv4Address'].split('/')[0])
")

PC3_IP=$(sudo docker network inspect devops-lab_vlan20 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='pc3': print(c['IPv4Address'].split('/')[0])
")

ROUTER_VLAN10=$(sudo docker network inspect devops-lab_vlan10 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='router': print(c['IPv4Address'].split('/')[0])
")

ROUTER_VLAN20=$(sudo docker network inspect devops-lab_vlan20 | python3 -c "
import sys,json
data=json.load(sys.stdin)[0]['Containers']
for c in data.values():
    if c['Name']=='router': print(c['IPv4Address'].split('/')[0])
")

echo ""
echo "IPs detectees :"
echo "  PC1    : $PC1_IP (vlan10)"
echo "  PC2    : $PC2_IP (vlan10)"
echo "  PC3    : $PC3_IP (vlan20)"
echo "  Router : $ROUTER_VLAN10 (vlan10) / $ROUTER_VLAN20 (vlan20)"
echo ""

run_test() {
    local desc="$1"
    local cmd="$2"
    echo -n "  > $desc ... "
    if eval "$cmd" &>/dev/null; then
        echo "OK"
        ((PASS++))
    else
        echo "ECHEC"
        ((FAIL++))
    fi
}

echo "Test intra-VLAN (VLAN10) :"
run_test "PC1 -> PC2" "sudo docker exec pc1 ping -c 2 -W 3 $PC2_IP"

echo ""
echo "Test inter-VLAN (via Router) :"
run_test "PC1 -> PC3" "sudo docker exec pc1 ping -c 2 -W 3 $PC3_IP"
run_test "PC3 -> PC1" "sudo docker exec pc3 ping -c 2 -W 3 $PC1_IP"

echo ""
echo "Test IP Forwarding :"
run_test "ip_forward actif" "sudo docker exec router sysctl net.ipv4.ip_forward | grep -q '= 1'"

echo ""
echo "========================================"
echo "Resultats: $PASS reussis / $((PASS + FAIL)) tests"
if [ $FAIL -eq 0 ]; then
    echo "Tous les tests sont passes!"
else
    echo "$FAIL test(s) echoue(s)"
fi
echo "========================================"

[ $FAIL -eq 0 ]
