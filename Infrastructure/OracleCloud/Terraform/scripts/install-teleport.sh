#!/bin/bash
TELEPORT_EDITION="oss"
TELEPORT_VERSION="16.0.0"
curl https://goteleport.com/static/install.sh | bash -s ${TELEPORT_VERSION?} ${TELEPORT_EDITION?}

# Configure Teleport by copying the teleport.yaml file to /etc/teleport.yaml. Generate https keypair & copy to /etc/teleport/privkey.pem and /etc/teleport/fullchain.pem
# sudo systemctl enable teleport
# sudo systemctl start teleport

# Install tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update -y
sudo apt-get install tailscale -y
sudo systemctl enable --now tailscaled
sudo tailscale up --authkey example-auth-key