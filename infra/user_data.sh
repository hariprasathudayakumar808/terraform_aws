#!/bin/bash
apt update -y
apt install -y docker.io awscli jq

# Install and start SSM Agent (Ubuntu 22.04+ uses snap)
snap install amazon-ssm-agent --classic
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

systemctl start docker
usermod -aG docker ubuntu

# Optional: for debugging
echo "User data script executed" > /home/ubuntu/init.log
