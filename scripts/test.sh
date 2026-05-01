#!/bin/bash
set -e

echo "========================================"
echo "🧪 Tests de connectivité réseau"
echo "========================================"

PASS=0
FAIL=0

run_test() {
    local desc="$1"
    local cmd="$2"
    echo -n "  ➤ $desc ... "
    if eval "$cmd" &>/dev/null; then
        echo "✅ OK"
        ((PASS++))
    else
        echo "❌ ÉCHEC"
        ((FAIL++))
    fi
}

echo ""
echo "📡 Test connectivité intra-VLAN (VLAN10):"
run_test "PC1 → PC2 (même VLAN)" "docker exec pc1 ping -c 2 -W 2 192.168.10.3"

echo ""
echo "📡 Test connectivité inter-VLAN (via Router):"
run_test "PC1 → Router (gateway VLAN10)" "docker exec pc1 ping -c 2 -W 2 192.168.10.1"
run_test "PC3 → Router (gateway VLAN20)" "docker exec pc3 ping -c 2 -W 2 192.168.20.1"
run_test "PC1 → PC3 (inter-VLAN routing)" "docker exec pc1 ping -c 2 -W 2 192.168.20.2"
run_test "PC3 → PC1 (inter-VLAN routing)" "docker exec pc3 ping -c 2 -W 2 192.168.10.2"

echo ""
echo "🔧 Test configuration IP Forwarding:"
run_test "IP Forwarding activé" "docker exec router sysctl net.ipv4.ip_forward | grep -q 'net.ipv4.ip_forward = 1'"

echo ""
echo "========================================"
echo "📊 Résultats: $PASS réussis / $((PASS + FAIL)) tests"
if [ $FAIL -eq 0 ]; then
    echo "🎉 Tous les tests sont passés!"
else
    echo "⚠️  $FAIL test(s) échoué(s)"
fi
echo "========================================"

[ $FAIL -eq 0 ]
