#!/bin/sh
# GL.iNet WiFi Calling Fix

set -e

echo "=== Updating package lists ==="
opkg update

echo "=== Installing kmod-nf-nathelper-extra ==="
opkg install kmod-nf-nathelper-extra

MODULE_FILE="/etc/modules.d/nf-nathelper-extra"

echo "=== Ensuring module file exists ==="
touch "$MODULE_FILE"

echo "=== Configuring SIP helper modules ==="

# Comment out existing uncommented entries
sed -i 's/^nf_conntrack_sip$/#nf_conntrack_sip/' "$MODULE_FILE"
sed -i 's/^nf_nat_sip$/#nf_nat_sip/' "$MODULE_FILE"

# Add commented entries if they don't exist at all
grep -Eq '^#?nf_conntrack_sip$' "$MODULE_FILE" || echo "#nf_conntrack_sip" >> "$MODULE_FILE"
grep -Eq '^#?nf_nat_sip$' "$MODULE_FILE" || echo "#nf_nat_sip" >> "$MODULE_FILE"

echo "=== Disabling flow offloading ==="
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'
uci commit firewall

echo "=== Restarting firewall ==="
/etc/init.d/firewall restart

echo "=== Configuration complete ==="
echo "Rebooting in 5 seconds..."
sleep 5
reboot
