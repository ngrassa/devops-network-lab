#!/bin/bash
set -e

echo "========================================"
echo "Tests de connectivite reseau"
echo "========================================"

PASS=0
FAIL=0

# Recuperer les IPs dynamiquement
PC1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pc1 | head -c -1)
PC2_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pc2 | head -c -1)
PC3_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pc3 | head -c -1)
ROUTER_IPS=$(docker exec router hostname -I)

echo ""
echo "IPs detectees :"
echo "  PC1    : $PC1_IP"
echo "  PC2    : $PC2_IP"
echo "  PC3    : $PC3_IP"
echo "  Router : $ROUTER_IPS"
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
run_test "PC1 -> PC2" "docker exec pc1 ping -c 2 -W 3 $PC2_IP"

echo ""
echo "Test inter-VLAN (via Router) :"
run_test "PC1 -> PC3" "docker exec pc1 ping -c 2 -W 3 $PC3_IP"
run_test "PC3 -> PC1" "docker exec pc3 ping -c 2 -W 3 $PC1_IP"

echo ""
echo "Test IP Forwarding :"
run_test "ip_forward actif" "docker exec router sysctl net.ipv4.ip_forward | grep -q '= 1'"

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
