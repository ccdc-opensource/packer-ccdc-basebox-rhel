#!/usr/bin/env bash
set -euo pipefail

# Discard installer networking without interrupting the provisioning connection.
rm -f /etc/cloud/cloud-init.disabled
for config in /etc/sysconfig/network-scripts/ifcfg-*; do
  if [[ "${config##*/}" != "ifcfg-lo" ]]; then
    rm -f -- "$config"
  fi
done
rm -f /etc/NetworkManager/system-connections/*.nmconnection

systemctl enable cloud-init-local.service cloud-init.service \
  cloud-config.service cloud-final.service

install -m 0644 /dev/stdin /etc/cloud/cloud.cfg.d/99-packer-cloud-init.cfg <<'EOF'
datasource_list: [NoCloud, ConfigDrive, None]
preserve_hostname: false
EOF

# Leave instance initialization and machine identity to the clone's first boot.
cloud-init clean --logs --seed --machine-id --configs network