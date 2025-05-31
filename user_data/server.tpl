#!/bin/bash
curl -sfL https://get.rke2.io | sh -
mkdir -p /etc/rancher/rke2/

SELF_IP=$(hostname -I | awk '{print $1}')

cat <<EOF > /etc/rancher/rke2/config.yaml
disable:
  - rke2-ingress-nginx
cloud-provider-name: aws
EOF

%{ if !is_server1 ~}
echo "token: ${token}" >> /etc/rancher/rke2/config.yaml
echo "server: https://${server1_ip}:9345" >> /etc/rancher/rke2/config.yaml
%{ endif ~}

%{ if is_server1 ~}
echo "tls-san:" >> /etc/rancher/rke2/config.yaml
echo "  - $${SELF_IP}" >> /etc/rancher/rke2/config.yaml
echo "  - ${elastic_ip}" >> /etc/rancher/rke2/config.yaml
%{ endif ~}

/bin/systemctl enable rke2-server.service
/bin/systemctl start rke2-server.service

