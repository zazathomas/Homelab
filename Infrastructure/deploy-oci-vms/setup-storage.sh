#!/bin/bash
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -t nat -X
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo apt-get install iptables-persistent -y
sudo netfilter-persistent save


# Install nfs for cluster storage
sudo apt-get install nfs-kernel-server -y
sudo mkdir -p /mnt/nfs_share
sudo chown nobody:nogroup /mnt/nfs_share
sudo chmod 0777 /mnt/nfs_share
sudo mv /etc/exports /etc/exports.bak
echo '/mnt/nfs_share 10.0.10.0/24(rw,sync,no_subtree_check,all_squash,anonuid=0,anongid=0)' | sudo tee /etc/exports
sudo systemctl restart nfs-kernel-server

# Install minio
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240922003343.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb && rm minio.deb
sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user
sudo mkdir -p /mnt/minio
sudo chown -R minio-user:minio-user /mnt/minio && sudo chmod u+rxw /mnt/minio
sudo touch /etc/default/minio
sudo chmod 666 /etc/default/minio
echo "MINIO_ROOT_USER=admin" >> /etc/default/minio
echo "MINIO_ROOT_PASSWORD=admin" >> /etc/default/minio
echo "MINIO_VOLUMES=/mnt/minio" >> /etc/default/minio
echo "MINIO_OPTS='--console-address :80'" >> /etc/default/minio
sudo setcap cap_net_bind_service=+ep /usr/local/bin/minio
sudo systemctl enable minio.service
sudo systemctl start minio.service

# Install tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update -y
sudo apt-get install tailscale -y
sudo systemctl enable --now tailscaled
sudo tailscale up --authkey tskey-auth
