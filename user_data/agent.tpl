#!/bin/bash
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
mkdir -p /etc/rancher/rke2/

cat <<EOF > /etc/rancher/rke2/config.yaml
node-name: ${node_name}
token: ${token}
server: https://${server1_ip}:9345
EOF

/bin/systemctl enable rke2-agent.service
/bin/systemctl start rke2-agent.service

